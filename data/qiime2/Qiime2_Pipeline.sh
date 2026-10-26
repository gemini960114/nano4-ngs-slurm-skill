#!/bin/bash
#SBATCH --account=GOV115148           # iService Project ID
#SBATCH --job-name=QIIME2             # Job name
#SBATCH --partition=ngscourse8g       # Slurm partition
#SBATCH --nodes=1                     # Maximum number of nodes to be allocated
#SBATCH --ntasks=1                    # Number of MPI tasks on each node
#SBATCH --cpus-per-task=1             # 每個任務分配的CPU核心數
#SBATCH --mem=8G                      # 記憶體量
#SBATCH --time=02:00:00               # 限制最長執行時間，0＝不限時
#SBATCH --output=job-%j.out           # 標準輸出檔案
#SBATCH --error=job-%j.err            # 標準錯誤檔案


# =============================================================================
# QIIME 2 教學資料介紹：造血幹細胞移植病人腸道菌相分析
#
# 【研究背景】
# 異體造血幹細胞移植（allo-HSCT）是部分癌症與血液疾病的根治性療法，但移植前
# 的化療與抗生素會嚴重擾動腸道菌相。治療期間菌相豐富度下降的病人，移植相關
# 死亡率較高。
#
# 自體糞菌移植（auto-FMT）指捐贈者與接受者為同一人：治療前先採集保存自己的
# 糞便菌叢，治療後再回輸，目標是重建治療前的菌相。相較異體 FMT，可降低接觸
# 陌生菌種而產生不良反應的風險。
#
# 本資料來自一項臨床試驗（NCT02269150）：25 位接受 allo-HSCT 的病人隨機分為
# auto-FMT 組與對照組，治療組於移植後 8–27 天（中位數 18 天）接受 FMT。
#
# 【本流程分兩段，資料來源不同】
#   上游：41 個檢體的原始定序資料 → 示範匯入與 DADA2 去噪
#   下游：從 FigShare 取得的 12,546 個檢體 feature table 與 ASV 序列
#         
#   ★ 兩段不承接。
#
# 【QIIME 2 的檔案】
#   .qza  資料檔    .qzv  圖表檔
#   .檔案拖進 https://view.qiime2.org 即可檢視，圖表是互動式的。
#
# 【執行】
#   進入QIIME2資料夾                進入作業環境
#   sbatch Qiime2_Pipeline.sh     投遞作業
#   squeue -u $USER               查看狀態
#   輸出寫入 job-<作業編號>.out / .err
# =============================================================================
# 
# 【輸入檔案】
#   置於Input_Data資料夾內。
#
# ── 上游輸入──────────────────────────────────────────────────────────
#
#   data_to_import/                     82 個 .fastq.gz = 41 檢體 × R1/R2
#                                       原始定序讀序，本流程唯一的原始資料
#
wget \
  -O 'Input_Data/data_to_import.zip' \
  'https://docs.qiime2.org/jupyterbooks/cancer-microbiome-intervention-tutorial/data/020-tutorial-upstream/030-importing/data_to_import.zip'

unzip -d Input_Data/data_to_import Input_Data/data_to_import.zip
#
#   sample-metadata.tsv                 12,548 行、27 欄
#                                       檢體分組、時間軸與臨床資訊，上下游共用
wget \
  -O 'Input_Data/sample-metadata.tsv' \
  'https://docs.qiime2.org/jupyterbooks/cancer-microbiome-intervention-tutorial/data/020-tutorial-upstream/020-metadata/sample-metadata.tsv'
#
# ── 下游輸入──────────────────────────────────────────────────────────
#
#   feature-table.qza                   ASV × 檢體的計數矩陣
#                                       涵蓋研究全部檢體（官方教材載為 12,546 個）
#
wget \
  -O 'Input_Data/feature-table.qza' \
  'https://docs.qiime2.org/jupyterbooks/cancer-microbiome-intervention-tutorial/data/030-tutorial-downstream/010-filtering/feature-table.qza'
#
#   rep-seqs.qza                        17,865 條 ASV 代表序列
#
#     這兩個檔案配套使用：前者是計數矩陣，後者提供矩陣中每個 ASV 對應的
#     實際序列。分類註解與建立系統發生樹都需要後者。
#
wget \
  -O 'Input_Data/rep-seqs.qza' \
  'https://docs.qiime2.org/jupyterbooks/cancer-microbiome-intervention-tutorial/data/030-tutorial-downstream/010-filtering/rep-seqs.qza'
#
# ──  SILVA 分類器 ────────────────────────────────────────────────────
#
#   silva-138.2-ssu-nr99-515f-806r-classifier.qza
#                                       使用Naive Bayes針對515F/806R間序列做的分類器
#
# =============================================================================

# =============================================================================
# 取得QIIME 2
# =============================================================================

module load biology/qiime2/2026.7

# =============================================================================
# 第一段：資料前處理（41 個檢體）
# =============================================================================

# 匯入 FASTQ。--type 宣告語意型別，--input-format 宣告檔案排列方式。
# 檔名結構：<檢體ID>_<序號>_L001_R{1,2}_001.fastq.gz

qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-format CasavaOneEightSingleLanePerSampleDirFmt \
  --input-path Input_Data/data_to_import \
  --output-path Upstream/demultiplexed-sequences.qza

# 產生互動式品質圖，用於決定下一步的截斷位置。

qiime demux summarize \
  --i-data Upstream/demultiplexed-sequences.qza \
  --o-visualization Upstream/demultiplexed-sequences-summ.qzv

# DADA2 去噪。品質控制包含 Q-score 過濾、修剪、嵌合體移除，
# 輸出 ASV（amplicon sequence variant）——相當於 100% 相似度的 OTU 分群，
# 而非傳統以 97% 相似度聚類的 OTU。
#
# 產出兩個核心檔案：
#   feature-table-0.qza   FeatureTable[Frequency]：每個檢體中各 ASV 的計數
#   asv-sequences-0.qza   FeatureData[Sequence]：各 ASV 的代表序列
#
# --p-trunc-len-f / -r：前後讀序的截斷位置（bp）。此數值與資料集相關，
#   須依上一步的品質圖逐一評估，並確保截斷後仍有足夠重疊供雙端合併。
#
#因為耗時，所以教學時不跑，直接提供輸出檔案
#

#qiime dada2 denoise-paired \
#    --i-demultiplexed-seqs Upstream/demultiplexed-sequences.qza \
#    --p-trunc-len-f 204 \
#    --p-trunc-len-r 205 \
#    --o-representative-sequences Upstream/asv-sequences-0.qza \
#    --o-table Upstream/feature-table-0.qza \
#    --o-denoising-stats Upstream/dada2-stats.qza \
#    --o-base-transition-stats Upstream/base-transition-stats.qza

# 檢視結果。dada2-stats 記錄每個檢體在各階段保留多少讀序。

qiime feature-table summarize \
    --i-table Upstream/feature-table-0.qza \
    --o-feature-frequencies Upstream/feature-frequencies.qza \
    --o-sample-frequencies Upstream/sample-frequencies.qza \
    --o-summary Upstream/feature-table-0-summ.qzv

# =============================================================================
# 第二段：建立分類器
#
# 此步驟因耗時很長，所以簡略。
# 此步驟使用的資料並未提供，若有需要，請自行到官網下載。
# 
# 本流程採機器學習法——將序列切成 k-mer 作為特徵，訓練Naive Bayes 分類器。
#
# 注意解析度限制：16S V4 常無法解析到種層級。例如 Lactobacillus helveticus
# 與 L. hamsteri 的 V4 前 90 個核苷酸完全相同，單憑序列無法區分。
#
# =============================================================================

# 移除含過多簡併鹼基或同聚物的參考序列。
# 預設 --p-num-degenerates 5：含 5 個以上 IUPAC 簡併鹼基者移除。
# 預設 --p-homopolymer-length 8：含長度 8 以上同聚物者移除。
#
# ★ 輸入為 RNA 序列時，此步驟會先反轉錄為 DNA 再過濾——這也是為什麼
#   輸入是 rna-seqs.qza，輸出卻是 DNA 序列。
#
#qiime rescript cull-seqs \
#    --i-sequences silva-138.2-ssu-nr99-rna-seqs.qza \
#    --o-clean-sequences silva-138.2-ssu-nr99-seqs-cleaned.qza

# 依分類群設定長度門檻過濾。--p-labels 與 --p-min-lens 數量須一致，
# 序列的分類字串含該標籤時即套用對應門檻；短於門檻者移入 discarded。
# 若一條序列同時符合多個標籤，採用最嚴格的門檻。
# 此處：古菌 900 bp、細菌 1200 bp、真核 1400 bp。
#
#qiime rescript filter-seqs-length-by-taxon \
#    --i-sequences silva-138.2-ssu-nr99-seqs-cleaned.qza \
#    --i-taxonomy silva-138.2-ssu-nr99-tax.qza \
#    --p-labels Archaea Bacteria Eukaryota \
#    --p-min-lens 900 1200 1400 \
#    --o-filtered-seqs silva-138.2-ssu-nr99-seqs-filt.qza \
#    --o-discarded-seqs silva-138.2-ssu-nr99-seqs-discard.qza 

#有需要，可只留取序列相似度97%以下的序列，節省大規模後續分析的計算時間。
#此步驟在此處生成分類器時省略。
#
#qiime rescript dereplicate \
#    --i-sequences silva-138.2-ssu-nr99-seqs-filt.qza \
#    --i-taxa silva-138.2-ssu-nr99-tax.qza \
#    --p-perc-identity 0.97 \
#    --p-mode 'lca' \
#    --o-dereplicated-sequences silva-138.2-ssu-c97-seqs-derep-lca.qza \
#    --o-dereplicated-taxa silva-138.2-ssu-c97-tax-derep-lca.qza

# 對序列與分類同時去重。--p-mode 決定同一條序列對應到不同分類時如何處理：
#   uniq      保留所有具有獨特分類標註的序列——即使序列重複，只要分類不同就都留
#   lca       取這些分類的最小共同祖先
#   majority  取最常見的分類標籤（平手時任意挑選）
# 此處用 uniq，保留最完整的分類資訊。
#
#qiime rescript dereplicate \
#    --i-sequences silva-138.2-ssu-nr99-seqs-filt.qza  \
#    --i-taxa silva-138.2-ssu-nr99-tax.qza \
#    --p-mode 'uniq' \
#    --o-dereplicated-sequences silva-138.2-ssu-nr99-seqs-derep-uniq.qza \
#    --o-dereplicated-taxa silva-138.2-ssu-nr99-tax-derep-uniq.qza
    
# 以實驗所用的引子，從全長參考序列截出對應的 V4 (515F / 806R) 區段。
# 515F: GTGYCAGCMGCCGCGGTAA    806R: GGACTACNVGGGTWTCTAAT
#
#qiime feature-classifier extract-reads \
#    --i-sequences silva-138.2-ssu-nr99-seqs-derep-uniq.qza \
#    --p-f-primer GTGYCAGCMGCCGCGGTAA \
#    --p-r-primer GGACTACNVGGGTWTCTAAT \
#    --p-n-jobs 2 \
#    --p-read-orientation 'forward' \
#    --o-reads silva-138.2-ssu-nr99-seqs-515f-806r.qza \
#    --o-read-extraction-stats silva-138.2-ssu-nr99-seqs-515f-806r_stats.qza

# 截取後再次去重。
#
#qiime rescript dereplicate \
#    --i-sequences silva-138.2-ssu-nr99-seqs-515f-806r.qza \
#    --i-taxa silva-138.2-ssu-nr99-tax-derep-uniq.qza \
#    --p-mode 'uniq' \
#    --o-dereplicated-sequences silva-138.2-ssu-nr99-seqs-515f-806r-uniq.qza \
#    --o-dereplicated-taxa  silva-138.2-ssu-nr99-tax-515f-806r-derep-uniq.qza

# 訓練 Naive Bayes 分類器。輸入為參考序列與其對應分類。
#
#qiime feature-classifier fit-classifier-naive-bayes \
#    --i-reference-reads silva-138.2-ssu-nr99-seqs-515f-806r-uniq.qza \
#    --i-reference-taxonomy silva-138.2-ssu-nr99-tax-515f-806r-derep-uniq.qza \
#    --o-classifier silva-138.2-ssu-nr99-515f-806r-classifier.qza

# =============================================================================
# 第三段：正式資料分析
#
# 此處起改用 FigShare 取得的 12,546 個檢體資料，與第一段的 41 個檢體無關。
# 第二段產生的分類器可於Input_Data中取得
#
# =============================================================================

# 檢視資料規模與每檢體讀序數分布——後續 sampling depth 需參考此分布。

qiime feature-table summarize \
    --i-table Input_Data/feature-table.qza \
    --o-feature-frequencies Downstream/feature-frequencies.qza \
    --o-sample-frequencies Downstream/sample-frequencies.qza \
    --o-summary Downstream/table.qzv

qiime feature-table tabulate-seqs \
  --i-data Input_Data/rep-seqs.qza \
  --o-visualization Downstream/rep-seqs.qzv

# --- 連續篩選：從 12,546 個檢體縮至本次分析對象 -----------------------------

# (1) 保留 autoFmtGroup 有值者，即納入試驗分組的檢體。

qiime feature-table filter-samples \
  --i-table Input_Data/feature-table.qza \
  --m-metadata-file Input_Data/sample-metadata.tsv \
  --p-where 'autoFmtGroup IS NOT NULL' \
  --o-filtered-table Downstream/autofmt-table.qza

# 檢視autoFMT資料成份分析

qiime feature-table summarize \
    --i-table Downstream/autofmt-table.qza \
    --o-feature-frequencies Downstream/feature-frequencies.qza \
    --o-sample-frequencies Downstream/sample-frequencies.qza \
    --o-summary Downstream/autofmt-table-summ.qzv

# (2) 限定移植前 10 天至移植後 70 天的資料。

qiime feature-table filter-samples \
  --i-table Downstream/autofmt-table.qza \
  --m-metadata-file Input_Data/sample-metadata.tsv \
  --p-where 'DayRelativeToNearestHCT BETWEEN -10 AND 70' \
  --o-filtered-table Downstream/filtered-table-1.qza

# (3) 移除只出現於單一檢體的特徵。

qiime feature-table filter-features \
  --i-table Downstream/filtered-table-1.qza \
  --p-min-samples 2 \
  --o-filtered-table Downstream/filtered-table-2.qza

# (4) 以 filtered-table-2.qza 裡的 feature ID為依據，
# 從 rep-seqs.qza 取出對應的序列，使序列檔與特徵表的特徵集合一致。

qiime feature-table filter-seqs \
  --i-data Input_Data/rep-seqs.qza \
  --i-table Downstream/filtered-table-2.qza \
  --o-filtered-data Downstream/filtered-sequences-1.qza

# --- 分類註解 ---------------------------------------------------------------

# 以訓練好的分類器為每條序列指定分類。
#
# 輸出 taxonomy.qza 的型別為 FeatureData[Taxonomy]，是一張三欄的表：
#   Feature ID   ASV 的識別碼
#   Taxon        分類字串，如 d__Bacteria; p__…; g__Haemophilus
#   Confidence   該筆分類的信心值

qiime feature-classifier classify-sklearn \
  --i-classifier Input_Data/silva-138.2-ssu-nr99-515f-806r-classifier.qza \
  --i-reads Downstream/filtered-sequences-1.qza \
  --o-classification Downstream/taxonomy.qza

# 依分類結果篩選：保留有門（p__）層級註解者，排除葉綠體與粒線體。

qiime taxa filter-table \
  --i-table Downstream/filtered-table-2.qza \
  --i-taxonomy Downstream/taxonomy.qza \
  --p-mode contains \
  --p-include p__ \
  --p-exclude 'p__;,Chloroplast,Mitochondria' \
  --o-filtered-table Downstream/filtered-table-3.qza

# 移除總讀序數低於 10,000 的檢體。

qiime feature-table filter-samples \
  --i-table Downstream/filtered-table-3.qza \
  --p-min-frequency 10000 \
  --o-filtered-table Downstream/filtered-table-4.qza

# (4) 以 filtered-table-4.qza 裡的 feature ID為依據，
# 從 rep-seqs.qza 取出對應的序列，使序列檔與特徵表的特徵集合一致。

qiime feature-table filter-seqs \
  --i-data Input_Data/rep-seqs.qza \
  --i-table Downstream/filtered-table-4.qza \
  --o-filtered-data Downstream/filtered-sequences-2.qza

# 產生物種組成堆疊圖。互動功能包含切換分類層級、多層排序、篩選、著色，
# 以及匯出 SVG 與原始數據。

qiime taxa barplot \
  --i-table Downstream/filtered-table-4.qza \
  --i-taxonomy Downstream/taxonomy.qza \
  --m-metadata-file Input_Data/sample-metadata.tsv \
  --o-visualization Downstream/taxa-bar-plots-1.qzv

# =============================================================================
# 多樣性分析
#
# Alpha diversity：單一群落內部的多樣性。
# Beta diversity：兩個群落之間的差異，以距離矩陣表示。
#
# 為什麼需要均勻抽樣（rarefaction）：多樣性指標會受檢體總讀序數影響，
# 定序較深的檢體僅因觀測較多就顯得多樣性較高。rarefaction 以不放回抽樣
# 將所有檢體降到相同總數；總讀序數低於該深度的檢體會被排除。
# 因此 sampling depth 是「保留足夠深度」與「保留足夠檢體」之間的取捨。
# =============================================================================

# 建立系統發生樹。UniFrac 等考慮演化關係的指標需要它。

qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences Downstream/filtered-sequences-2.qza \
  --output-dir Downstream/phylogeny-align-to-tree-mafft-fasttree

# 統整特徵表，產生表格與視覺化摘要。這是 pipeline，一次輸出三個檔案：
#
#   --o-feature-frequencies   每個特徵在各檢體中的次數與總次數
#   --o-sample-frequencies    每個檢體的特徵數與總讀序數
#   --o-summary               互動式摘要圖
#
# 此處統整的是完成全部篩選後的 filtered-table-4.qza，放在多樣性分析之前，
# 用途是決定 sampling depth——sample-frequencies 給出的「每檢體總讀序數」
# 分布，正是判斷該把深度設在哪裡的依據：深度愈高保留的序列愈多，
# 但總讀序數低於該深度的檢體會被整個排除。

qiime feature-table summarize \
    --i-table Downstream/filtered-table-4.qza \
    --o-feature-frequencies Downstream/feature-frequencies.qza \
    --o-sample-frequencies Downstream/sample-frequencies.qza \
    --o-summary Downstream/filtered-table-4-summ.qzv

# 稀釋曲線：觀察多樣性隨抽樣深度的變化，用以選定 sampling depth。

qiime diversity alpha-rarefaction \
  --i-table Downstream/filtered-table-4.qza \
  --p-metrics shannon \
  --m-metadata-file Input_Data/sample-metadata.tsv \
  --p-max-depth 33000 \
  --o-visualization Downstream/shannon-rarefaction-plot.qzv

#基本Beta diversity分析

qiime diversity beta-rarefaction \
  --i-table Downstream/filtered-table-4.qza \
  --p-metric braycurtis \
  --p-clustering-method nj \
  --p-sampling-depth 10000 \
  --m-metadata-file Input_Data/sample-metadata.tsv \
  --o-visualization Downstream/braycurtis-rarefaction-plot.qzv

# 核心多樣性指標。一次計算多個 alpha、beta 指標與 PCoA 排序。
#
# 輸出的四個常用 alpha 指標：
#   observed_features  豐富度：檢體中不同特徵的數量
#   faith_pd           系統發生豐富度：檢體涵蓋的演化樹枝長總和
#   shannon            豐富度與均勻度（以豐度加權）
#   evenness           Pielou 均勻度：僅反映特徵分布是否均勻
#
# beta 指標的兩個面向：
#   質性（unweighted）：只看有無，對稀有類群較敏感。Jaccard、Unweighted UniFrac
#   量性（weighted）：納入相對豐度，對優勢類群較敏感。Bray-Curtis、Weighted UniFrac
#   系統發生型（UniFrac）納入演化親緣，非系統發生型（Jaccard、Bray-Curtis）
#   則視所有特徵彼此等距。沒有單一最佳指標，不同指標反映資料的不同性質。

qiime diversity core-metrics-phylogenetic \
  --i-phylogeny Downstream/phylogeny-align-to-tree-mafft-fasttree/rooted_tree.qza \
  --i-table Downstream/filtered-table-4.qza \
  --p-sampling-depth 10000 \
  --m-metadata-file Input_Data/sample-metadata.tsv \
  --output-dir Downstream/diversity-core-metrics-phylogenetic

# Alpha 多樣性的組間比較。離散變項用 Kruskal-Wallis，連續變項用 Spearman 相關。

qiime diversity alpha-group-significance \
  --i-alpha-diversity Downstream/diversity-core-metrics-phylogenetic/observed_features_vector.qza \
  --m-metadata-file Input_Data/sample-metadata.tsv \
  --o-visualization Downstream/alpha-group-sig-obs-feats.qzv

# 線性混合效應模型：檢驗一個或多個自變項與單一縱向反應變項的關係，
# 適用於同一受試者重複測量、觀測之間不獨立的資料，同時納入固定效應與隨機效應。
#   --p-individual-id-column  受試者識別（處理個體內相關性）
#   --p-state-column          時間軸
#   --p-group-columns         要比較的組別

qiime longitudinal linear-mixed-effects \
  --m-metadata-file Input_Data/sample-metadata.tsv Downstream/diversity-core-metrics-phylogenetic/observed_features_vector.qza \
  --p-state-column day-relative-to-fmt \
  --p-group-columns autoFmtGroup \
  --p-individual-id-column PatientID \
  --p-metric observed_features \
  --o-visualization Downstream/lme-obs-features-treatmentVScontrol.qzv

#Beta diversity
# UMAP 降維，作為 PCoA 之外的另一種排序呈現方式。

qiime diversity umap \
  --i-distance-matrix Downstream/diversity-core-metrics-phylogenetic/unweighted_unifrac_distance_matrix.qza \
  --o-umap Downstream/uu-umap.qza

# 把 metadata 與各項分析結果並列成一張可互動的表格。
# 輸出的 .qzv 支援篩選、排序，以及匯出成常見檔案格式。
#
# 此處一次傳入五個來源：
#   sample-metadata.tsv        檢體的臨床與分組資訊
#   uu-umap.qza                UMAP 的座標
#   faith_pd_vector.qza        Faith's PD（系統發生豐富度）
#   evenness_vector.qza        Pielou 均勻度
#   shannon_vector.qza         Shannon 指數

qiime metadata tabulate \
  --m-input-file Input_Data/sample-metadata.tsv Downstream/uu-umap.qza Downstream/diversity-core-metrics-phylogenetic/faith_pd_vector.qza Downstream/diversity-core-metrics-phylogenetic/evenness_vector.qza Downstream/diversity-core-metrics-phylogenetic/shannon_vector.qza \
  --o-visualization Downstream/expanded-metadata-summ.qzv

#產生物種組成堆疊圖

qiime taxa barplot \
  --i-table Downstream/filtered-table-4.qza \
  --i-taxonomy Downstream/taxonomy.qza \
  --m-metadata-file Input_Data/sample-metadata.tsv Downstream/uu-umap.qza Downstream/diversity-core-metrics-phylogenetic/faith_pd_vector.qza Downstream/diversity-core-metrics-phylogenetic/evenness_vector.qza Downstream/diversity-core-metrics-phylogenetic/shannon_vector.qza \
  --o-visualization Downstream/taxa-bar-plots-2.qzv

# Emperor 排序圖。
#
# --i-pcoa 接受的 PCoAResults。如UMAP 的輸出 uu-umap.qza
#  與 core-metrics 產出的unweighted_unifrac_pcoa_results.qza
#
# --p-custom-axes 將其中一軸換成指定的 metadata 欄位，
# 此處設為移植後週數，可直接觀察菌相隨時間的變化軌跡。
#
# 排序圖為探索性工具，要判斷哪個分組真的有差異，需搭配統計檢定

qiime emperor plot \
  --i-pcoa Downstream/uu-umap.qza \
  --m-metadata-file Input_Data/sample-metadata.tsv Downstream/uu-umap.qza Downstream/diversity-core-metrics-phylogenetic/faith_pd_vector.qza Downstream/diversity-core-metrics-phylogenetic/evenness_vector.qza Downstream/diversity-core-metrics-phylogenetic/shannon_vector.qza \
  --p-custom-axes week-relative-to-hct \
  --o-visualization Downstream/uu-umap-emperor-w-time.qzv
  
# =============================================================================
# 縱向分析
#
# 縱向研究對同一受試者重複取樣，可觀察菌相的發展、穩定性、擾動與恢復，
# 並將個體變異與整個世代比較。
# =============================================================================

# 將 ASV 合併至屬（genus，level 6）層級。

qiime taxa collapse \
  --i-table Downstream/filtered-table-4.qza \
  --i-taxonomy Downstream/taxonomy.qza \
  --p-level 6 \
  --o-collapsed-table Downstream/genus-table.qza

# 保留在至少 10% 檢體中相對豐度達 1% 以上的類群。
qiime feature-table filter-features-conditionally \
  --i-table Downstream/genus-table.qza \
  --p-prevalence 0.1 \
  --p-abundance 0.01 \
  --o-filtered-table Downstream/filtered-genus-table.qza

#將特徵表中的計數轉換為相對頻率
qiime feature-table relative-frequency \
  --i-table Downstream/filtered-genus-table.qza \
  --o-relative-frequency-table Downstream/genus-rf-table.qza

#產生波動圖（volatility chart）：呈現指標隨時間在受試者之間與之內的變化，
# 結合管制圖與 spaghetti plot。圖中虛線為警告界限（平均 ±2 SD）、
# 點線為管制界限（平均 ±3 SD），用來辨識明顯偏離平均的觀測值。

qiime longitudinal volatility \
  --i-table Downstream/genus-rf-table.qza \
  --p-state-column week-relative-to-hct \
  --m-metadata-file Input_Data/sample-metadata.tsv Downstream/uu-umap.qza Downstream/diversity-core-metrics-phylogenetic/faith_pd_vector.qza Downstream/diversity-core-metrics-phylogenetic/evenness_vector.qza Downstream/diversity-core-metrics-phylogenetic/shannon_vector.qza \
  --p-individual-id-column PatientID \
  --p-default-group-column autoFmtGroup \
  --o-visualization Downstream/volatility-plot-1.qzv

# Feature volatility：探索性方法，以監督式迴歸找出能預測時間點的類群。
# 與其他方法不同之處在於它也能辨識出低豐度但具預測力的類群。

qiime longitudinal feature-volatility \
  --i-table Downstream/filtered-genus-table.qza \
  --m-metadata-file Input_Data/sample-metadata.tsv Downstream/uu-umap.qza Downstream/diversity-core-metrics-phylogenetic/faith_pd_vector.qza Downstream/diversity-core-metrics-phylogenetic/evenness_vector.qza Downstream/diversity-core-metrics-phylogenetic/shannon_vector.qza \
  --p-state-column week-relative-to-hct \
  --p-individual-id-column PatientID \
  --output-dir Downstream/longitudinal-feature-volatility
