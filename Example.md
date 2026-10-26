# AI Agent 上國網 HPC：生醫運算與分析實作 —— 全部指令速查表 (Example.md)

本文件整理課程中各階段可直接複製貼給 AI Agent 的對話指令（Prompts）。

---

## 📦 練習使用到的內建資料 (`./data/`)

所有教學使用到的定序樣本、Metadata、SILVA 分類器與參考腳本皆已放在 [`data/`](./data/) 目錄下，**不需另外下載**：

```text
data/
├── fastq_4samples/                     # [範例 2 使用] 4 個輕量 FASTQ 樣本 (每檔 1,000 reads, 供 Case 01~05 練習)
│   ├── FMT.0093C_5_L001_R1_001.fastq.gz
│   ├── FMT.0093C_46_L001_R2_001.fastq.gz
│   ├── FMT.0093D_2_L001_R1_001.fastq.gz
│   └── FMT.0093D_43_L001_R2_001.fastq.gz
└── qiime2/                             # [範例 3 使用] QIIME 2 腸道菌相分析資料 (供 Case 06~07 練習)
    ├── Qiime2_Pipeline.sh              # 原始教學參考腳本
    ├── Upstream/                       # 已預先跑完 DADA2 去噪的特徵表 (feature-table-0.qza)
    └── Input_Data/                     # 上下游輸入資料
        ├── data_to_import/             # 82 個雙端 .fastq.gz 原始定序檔
        ├── sample-metadata.tsv         # 臨床分組與時間軸 Metadata 表格
        ├── feature-table.qza           # 下游特徵計數矩陣
        ├── rep-seqs.qza                # 下游 ASV 代表序列
        └── silva-138.2-ssu-nr99-515f-806r-classifier.qza  # SILVA 138.2 分類器
```

---

## 範例 2：自訂 Skill —— 讀取官方文件、練習基礎 Slurm 作業，最後濃縮成 Skill

### 步驟 2-0：請 AI 讀取國網 GP1 官方說明網頁
```text
請幫我讀取國網中心 GP1 生醫專用節點的官方說明網頁：
https://man.twcc.ai/xOYzPATVS_aDlbuqMrwhyg
（若需要讀取原始 Markdown 內容，可抓取 https://man.twcc.ai/xOYzPATVS_aDlbuqMrwhyg/download ）

讀完後，請幫我重點整理：
1. 登入節點有哪些限制？
2. Slurm 批次作業腳本有哪些必填參數與分區（ngs*）規定？
3. 生物資訊軟體模組（module）與 Singularity/Apptainer 容器該怎麼使用？
```

---

### 練習 1 (`tutorial/case01`)：單一 FASTQ 檔案統計（單一批次作業）
```text
寫一支 Python 程式，讀取 data/fastq_4samples/FMT.0093C_5_L001_R1_001.fastq.gz，算出裡面有幾條 reads、平均讀長和 GC 含量 %。
幫我寫 Slurm 腳本送到計算節點去跑（用課程計畫 GOV115088）。
腳本放在目前目錄 tutorial/case01
送出前先跟我說你的設定，跑完後把結果整理給我。
```

---

### 練習 2 (`tutorial/case02`)：多樣本平行計算（Slurm 陣列作業 Array Job）
```text
data/fastq_4samples/ 資料夾裡面有 4 個定序樣本（.fastq.gz），請幫我用 Slurm 陣列作業（Array Job）同時算出每個樣本各有幾條 reads，送出前先給我看計畫。
腳本放在目前目錄 tutorial/case02
```

---

### 練習 3 (`tutorial/case03`)：FastQC 與 MultiQC 品質檢查流水線（相依作業 Dependency）
```text
請幫我對 data/fastq_4samples/ 裡面的 4 個樣本做品質檢查流水線：
- 第一步：用 FastQC 檢查這 4 個樣本的品質，結果放在 qc/fastqc_out/。
- 第二步：等第一步確定成功跑完後，自動啟動 MultiQC 把結果彙整成一份 HTML 報告，放在 qc/multiqc_out/。
先告訴我你打算怎麼送，我同意後再送出。
腳本放在目前目錄 tutorial/case03
```

---

### 練習 4 (`tutorial/case04`)：檢查作業狀態與資源使用率（`seff` / `sacct`）
```text
剛剛送出去的工作跑完了嗎？如果跑完了，請幫我用 seff（或 sacct）檢查資源使用率，並用白話文跟我說跑得順不順、這 4 個樣本的品質結果如何。
結果報告放置於 tutorial/case04
```

---

### 練習 5 (`tutorial/case05`)：使用 Apptainer 容器執行並將快取設在 `/work/$USER/`
```text
以下的內容會用到 apptainer 下載 image，但 home 目錄空間有限，請補充將 cache 設在 /work/$USER/。

這次不要用 module load，請改寫一個用 Apptainer 容器執行的 Slurm 工作：
1. 在計算節點直接從 Docker Hub 下載 multiqc/multiqc:v1.35 映像檔，.sif 檔請存在我的 /work/$USER/containers/。
2. 用這個容器去掃描剛剛 qc/fastqc_out/ 的結果，產生 MultiQC 報告。
3. 腳本報告放在目前目錄 tutorial/case05
```

---

### 步驟 2-6：把官方文件重點與實作經驗濃縮成自訂 Skill
```text
經過剛剛的練習，請幫我擷取國網 GP1 官方說明文件（https://man.twcc.ai/xOYzPATVS_aDlbuqMrwhyg）的重點，以及我們剛剛實作 Slurm 單一作業、Array Job、相依流水線與 Apptainer 容器的經驗，整理並編寫成可重複使用的 AI 規則與技能：

1. 在專案根目錄整理一份簡潔的 AGENTS.md（核心安全鐵律）：
   - 嚴禁在登入節點運算，必須透過 sbatch / salloc 派送至計算節點。
   - 嚴禁使用 watch 或迴圈高頻輪詢 squeue。
   - 提交 sbatch 前必須先向使用者說明預計使用的計畫代號、分區與資源配置，獲確認後才送出。
   - 明確指定 --cpus-per-task 與 --mem（例如課程計畫 GOV115088 固定使用 ngs62g：-c 8 --mem=62G），防範預設申請整台節點記憶體卡死。
   - 腳本內先執行 module purge 再載入模組；大量資料與 Apptainer 快取一律放在 /work/$USER。

2. 在 .agents/skills/nano4-ngs-slurm/ 目錄下編寫完整的 Slurm 排程技能（包含 SKILL.md、ngs* 分區規格參考表與標準範本腳本），讓我以後開新對話時不用再重貼官方網頁。

3. 完成後，請將 AGENTS.md 與 .agents/ 設為唯讀（chmod -R a-w AGENTS.md .agents/），防止日後排錯時誤改規則。
```

---

## 範例 3：管線派送與監控 —— QIIME 2 腸道菌相分析 (`tutorial/case06` ~ `case07`)

### 🔹 階段 A (`tutorial/case06`)：上游 82 個樣本匯入與品質評估（Upstream）
```text
請參考 data/qiime2/Qiime2_Pipeline.sh 的第一段（上游前處理），幫我寫一支 Slurm 作業（計畫 GOV115088）送到計算節點執行，輸出結果請放在 tutorial/case06/qiime2_run/Upstream/：
1. 載入 biology/qiime2/2026.7 模組（不用再跑 wget 下載，資料已經在 data/qiime2/ 裡面了）。
2. 把 data/qiime2/Input_Data/data_to_import/ 裡面的 82 個雙端 FASTQ 檔案匯入成 demultiplexed-sequences.qza，並產生品質摘要圖 demultiplexed-sequences-summ.qzv。
3. 直接讀取現成的 data/qiime2/Upstream/feature-table-0.qza，產出特徵表摘要統計 feature-table-0-summ.qzv。
4. 送出前請先跟我說明腳本內容與資源設定，等我確認後才送出；送出後請每 5 分鐘自動檢查一次作業狀態，跑完後通知我。
```

---

### 🔹 階段 B (`tutorial/case06`)：篩選臨床檢體與 8 核心菌種分類（Downstream）
```text
上一步成功了！接著請參考 data/qiime2/Qiime2_Pipeline.sh 的第三段前半部，幫我寫第二支 Slurm 腳本送到計算節點執行，結果放在 tutorial/case06/qiime2_run/Downstream/：
1. 直接讀取 data/qiime2/Input_Data/ 裡面現成的 sample-metadata.tsv、feature-table.qza、rep-seqs.qza 與 silva-138.2-ssu-nr99-515f-806r-classifier.qza 分類器（不需重新下載）。
2. 照腳本的條件篩選檢體（保留 autoFmtGroup 有值、移植前後 -10 到 70 天、至少出現在 2 個檢體、排除葉綠體與粒線體、總讀序數 >= 10,000）。
3. 完成菌種分類註解（請加上 --p-n-jobs 8 開啟 8 核心加速），並產生第一張物種組成堆疊圖 taxa-bar-plots-1.qzv。
4. 同樣請先向我說明腳本內容，確認後才送出，並設定每 5 分鐘自動檢查一次作業狀態。
```

---

### 🔹 階段 C (`tutorial/case06`)：演化樹、核心多樣性、UMAP 與縱向統計（Diversity & Longitudinal）
```text
篩選跟分類都跑完了！現在請參考 data/qiime2/Qiime2_Pipeline.sh 後半段的多樣性與縱向分析，幫我送出第三支 Slurm 作業，結果放在 tutorial/case06/qiime2_run/Diversity_Longitudinal/：
1. 對上一步篩選後的序列建立演化樹（MAFFT / FastTree，請加上 --p-n-threads 8 用滿 8 核心）。
2. 以抽樣深度 10,000 計算 Alpha 與 Beta 核心多樣性指標、稀釋曲線與組間顯著性檢定。
3. 跑完 UMAP 降維、Emperor 排序圖，以及最後的線性混合效應模型（LME）與菌屬隨時間變化的波動圖（Volatility）。
4. 請先說明腳本內容，我確認後再送出，之後每 5 分鐘自動檢查一次作業狀態直到完成。
```

---

### 🔹 管線整合與定時監控 (`tutorial/case07`)：一鍵串接三階段自動化流水線
```text
太棒了！現在請幫我把上面三個階段（步驟 A 上游匯入、步驟 B 篩選與分類、步驟 C 多樣性與縱向分析）整合成一套完整的自動化 Slurm 流水線：
- 請幫我寫一個啟動腳本 run_full_qiime2_pipeline.sh，用 Slurm 的相依性功能（--dependency=afterok）把這三支腳本串起來，讓前一階段成功後自動啟動下一階段。
- 同時也幫我把 data/qiime2/Qiime2_Pipeline.sh 改寫成一份拿掉 wget、改讀本地 data/qiime2/ 資料，且符合 ngs62g（8 核心、62G 記憶體、module purge）規範的單一完整版 Qiime2_Pipeline_ngs62g.slurm 備用。
- 送出流水線前先跟我說明設定，我確認後再送出；送出後請每 5 分鐘自動檢查一次作業狀態，全部跑完後檢查所有 .qzv 結果檔是否都成功產生，並用白話文總結這次腸道菌相分析產出了哪些圖表！
- 腳本報告放在目前目錄 tutorial/case07
```

---

## 範例 4：結果解讀與報告 (`nano4-ngs-report` Skill)

### 讀取分析結果，自動整理成圖文報告（`.md` + 單一獨立 `.html`）
```text
請啟用 nano4-ngs-report 技能，掃描 tutorial/case01 ~ case06 下的所有 Slurm 腳本、執行日誌（*.out / *.err）與分析產出檔案，為我撰寫一份結合「Runbook 操作手冊」與「生醫 Methods & Results 數據解讀」的完整分析報告，並使用技能內建的轉換腳本同步輸出 .md 與單一獨立 .html 報告至 tutorial/report01/。
```

---

### 附錄：建立或更新通用型報告技能 (`nano4-ngs-report`) 的指令
```text
請解鎖並更新 Skill，在 .agents/skills/nano4-ngs-report/ 建立一個通用的「專業技術與科研分析報告撰寫技能（nano4-ngs-report）」，完成後請立即將 AGENTS.md 與 .agents/ 重新上鎖（chmod a-w）。
請將此 Skill 設計為「通用型報告產生器（General-Purpose Report Skill）」，不綁定特定專案或特定軟體，適用於任何資料科學、生醫資訊、HPC 運算或軟體工程實作。其 SKILL.md 規範與內建工具須包含以下四大通用模組：
1. 【自動化上下文與證據盤點（Evidence Discovery）】：
   - 撰寫報告前，自動掃描目標目錄下的程式碼/腳本、設定檔、執行日誌（Logs）、統計數據表與輸出產物清單。
   - 嚴格遵守「有幾分證據說幾分話（Zero-Hallucination）」原則：所有軟硬體規格、執行時間、參數設定與數據結論，必須100%源自實際日誌與產出檔案，不自行捏造數據。
2. 【雙軌結構化寫作框架（Dual-Mode Structure）】：
   支援依任務性質自由組合或切換以下兩種國際標準框架：
   - 模式 A：技術實作與操作手冊（Runbook & Technical Guide）
     包含：執行摘要（Executive Summary）、系統架構與 Mermaid 流程圖、環境與資源配置表、分步執行邏輯解析、關鍵指令與參數說明、驗證結果與常見排錯（Troubleshooting）。
   - 模式 B：科研實驗與數據分析報告（Scientific & Analytical Report）
     包含：研究背景與目標（Objective）、資料來源與方法論（Materials & Methods，含可重現之軟體版本與參數選擇依據）、實驗結果與統計解讀（Results & Findings，轉化為結構化比較表）、核心圖表與產物導讀（Artifacts Guide）、結論與後續建議（Discussion & Next Steps）。
3. 【視覺化排版規範（Visual & Formatting Standards）】：
   - 善用 GitHub Alert 區塊（NOTE / TIP / IMPORTANT / WARNING）突顯關鍵結論與防呆注意事項。
   - 凡涉及多步驟流程、相依性或系統架構，自動繪製 Mermaid 圖表（flowchart / sequenceDiagram）。
   - 所有提及之腳本、數據檔與圖表產物，必須提供清楚的檔案路徑對照表與格式說明。
4. 【零外部依賴之獨立 HTML/PDF 報告編譯器（Standalone HTML Exporter）】：
   - 於技能目錄內建純 Python 轉換腳本（scripts/md_to_html.py），僅使用系統標準 Python，不依賴 Node.js、Pandoc 或 LibreOffice。
   - 能將產出的 Markdown 報告一鍵封裝為單一自包含（Self-contained）的精美 .html 報告檔（內嵌現代學術/技術 CSS 樣式、RWD 表格、程式碼區塊美化、前端 Mermaid.js 自動渲染，以及針對瀏覽器 Ctrl+P 列印成 PDF 最佳化的 @media print 分頁樣式）。
```
