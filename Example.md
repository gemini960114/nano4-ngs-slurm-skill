# Nano4 生醫 Slurm 排程：入門學生自然語言指令範例 (Examples)

本文件示範如何用**最簡單的日常自然語言（或簡單條列）**向 AI Agent 下達指令。因為本專案已配置 `AGENTS.md` 與 `nano4-ngs-slurm` Skill，學生不需要死背 `#SBATCH` 或軟體參數，AI 會自動套用正確的 `ngs*` 佇列規格（如 `GOV115088` + `ngs62g` 固定 8 核心 / 62G）與安全鐵律。

---

## 📦 專案內建資料目錄規劃 (`./data/`)

所有練習與實戰所需的定序樣本、臨床表格、SILVA 分類器與參考腳本，皆已完整複製並整理於本專案的 [`data/`](./data/) 目錄下，**不需另外上網下載即可直接操作**：

```text
data/
├── test.fastq                          # 單一測試用 FASTQ (1,000 reads, 供範例 1 快速練習)
├── fastq_4samples/                     # 4 個輕量真實雙端樣本 (每檔 1,000 reads, 供範例 2~5 快速練習)
│   ├── FMT.0093C_5_L001_R1_001.fastq.gz
│   ├── FMT.0093C_46_L001_R2_001.fastq.gz
│   ├── FMT.0093D_2_L001_R1_001.fastq.gz
│   └── FMT.0093D_43_L001_R2_001.fastq.gz
└── qiime2/                             # 完整 QIIME 2 臨床試驗套件 (NCT02269150 自體糞菌移植研究)
    ├── Qiime2_Pipeline.sh              # 原始教學參考腳本
    ├── Upstream/                       # 已預先跑完耗時 DADA2 去噪的中介結果檔
    │   ├── asv-sequences-0.qza
    │   ├── base-transition-stats.qza
    │   ├── dada2-stats.qza
    │   └── feature-table-0.qza
    └── Input_Data/                     # 上下游完整輸入資料
        ├── data_to_import/             # 完整 82 個 .fastq.gz 雙端原始定序檔 (41 位病患檢體 × R1/R2)
        ├── sample-metadata.tsv         # 臨床分組與時間軸 Metadata 表格 (12,548 行)
        ├── feature-table.qza           # 下游完整特徵計數矩陣 (12,546 個檢體)
        ├── rep-seqs.qza                # 下游 17,865 條 ASV 代表序列
        └── silva-138.2-ssu-nr99-515f-806r-classifier.qza  # 訓練好的 SILVA 138.2 分類器
```

---

## 第一部分：基礎 Slurm 排程與品質檢查（5 個入門範例）

### 範例 1：統計單一真實樣本的基礎數據（單一作業）
**💬 學生可以直接這樣跟 AI 說：**
> 請幫我建立並送出一個簡單的 FASTQ 統計工作：
> 1. 寫一支 Python 程式，讀取 `data/fastq_4samples/FMT.0093C_5_L001_R1_001.fastq.gz`，算出裡面有幾條 reads、平均讀長和 GC 含量 %。
> 2. 幫我寫 Slurm 腳本送到計算節點去跑（用課程計畫 `GOV115088`）。
> 3. 送出前先跟我說你的設定，跑完後把結果整理給我。

---

### 範例 2：多個定序樣本同時平行算條數（批次陣列作業 Array Job）
**💬 學生可以直接這樣跟 AI 說：**
> `data/fastq_4samples/` 資料夾裡面有 4 個定序樣本（`.fastq.gz`），請幫我用 Slurm 陣列作業（Array Job）同時算出每個樣本各有幾條 reads，送出前先給我看計畫。
> *(註：若想挑戰算全部 82 個完整檔案，也可以改成指定 `data/qiime2/Input_Data/data_to_import/`！)*

---

### 範例 3：做完 FastQC 接著自動跑 MultiQC（前後相依流水線 Dependency）
**💬 學生可以直接這樣跟 AI 說：**
> 請幫我對 `data/fastq_4samples/` 裡面的 4 個樣本做品質檢查流水線：
> - 第一步：用 FastQC 檢查這 4 個樣本的品質，結果放在 `qc/fastqc_out/`。
> - 第二步：等第一步確定成功跑完後，自動啟動 MultiQC 把結果彙整成一份 HTML 報告，放在 `qc/multiqc_out/`。
> - 先告訴我你打算怎麼送，我同意後再送出。

---

### 範例 4：檢查工作跑完了沒，並看資源有沒有浪費（狀態與 `seff` 診斷）
**💬 學生可以直接這樣跟 AI 說：**
> 剛剛送出去的工作跑完了嗎？如果跑完了，請幫我用 `seff` 檢查資源使用率，並用白話文跟我說跑得順不順、這 4 個樣本的品質結果如何。

---

### 範例 5：不載入系統模組，改用容器跑分析（Apptainer 容器）
**💬 學生可以直接這樣跟 AI 說：**
> 這次不要用 `module load`，請改寫一個用 Apptainer 容器執行的 Slurm 工作：
> 1. 在計算節點直接從 Docker Hub 下載 `multiqc/multiqc:v1.35` 映像檔，`.sif` 檔請存在我的 `/work/$USER/containers/`。
> 2. 用這個容器去掃描剛剛 `qc/fastqc_out/` 的結果，產生 MultiQC 報告到 `/work/$USER/apptainer_lab/`。

---

## 第二部分：進階實戰 —— 將 `data/qiime2/Qiime2_Pipeline.sh` 拆解為多輪自然語言對話，最後一鍵自動化串接

現在完整的 82 個 `.fastq.gz` 檔案、分類器與下游 `.qza` 檔案都已經在 `data/qiime2/` 裡了！學生不需要手動改那份 500 行的腳本，也**不需要再執行 `wget` 下載**，可以直接用以下 4 輪自然語言對話完成整套分析：

### 🔹 步驟 A（第一輪對話）：請 AI 進行上游 82 個樣本匯入與品質評估（Upstream）
**💬 學生對 AI 說：**
> 請參考 `data/qiime2/Qiime2_Pipeline.sh` 的第一段（上游前處理），幫我寫一支 Slurm 作業（計畫 `GOV115088`）送到計算節點執行，輸出結果請放在 `/work/$USER/qiime2_run/Upstream/`：
> 1. 載入 `biology/qiime2/2026.7` 模組（不用再跑 `wget` 下載，資料已經在 `data/qiime2/` 裡面了）。
> 2. 把 `data/qiime2/Input_Data/data_to_import/` 裡面的 82 個雙端 FASTQ 檔案匯入成 `demultiplexed-sequences.qza`，並產生品質摘要圖 `demultiplexed-sequences-summ.qzv`。
> 3. 直接讀取現成的 `data/qiime2/Upstream/feature-table-0.qza`，產出特徵表摘要統計 `feature-table-0-summ.qzv`。

---

### 🔹 步驟 B（第二輪對話）：請 AI 篩選下游檢體並做菌種分類（Filtering & Taxonomy）
**💬 學生接著對 AI 說：**
> 上一步成功了！接著請參考 `data/qiime2/Qiime2_Pipeline.sh` 的第三段前半部，幫我寫第二支 Slurm 腳本送到計算節點執行，結果放在 `/work/$USER/qiime2_run/Downstream/`：
> 1. 直接讀取 `data/qiime2/Input_Data/` 裡面現成的 `sample-metadata.tsv`、`feature-table.qza`、`rep-seqs.qza` 與 `silva-138.2-ssu-nr99-515f-806r-classifier.qza` 分類器（不需重新下載）。
> 2. 照腳本的條件篩選檢體（保留 `autoFmtGroup` 有值、移植前後 -10 到 70 天、至少出現在 2 個檢體、排除葉綠體與粒線體、總讀序數 >= 10,000）。
> 3. 完成菌種分類註解（請加上 `--p-n-jobs 8` 開啟 8 核心加速），並產生第一張物種組成堆疊圖 `taxa-bar-plots-1.qzv`。

---

### 🔹 步驟 C（第三輪對話）：請 AI 跑核心多樣性、UMAP 與縱向統計（Diversity & Longitudinal）
**💬 學生接著對 AI 說：**
> 篩選跟分類都跑完了！現在請參考 `data/qiime2/Qiime2_Pipeline.sh` 後半段的多樣性與縱向分析，幫我送出第三支 Slurm 作業：
> 1. 對上一步篩選後的序列建立演化樹（MAFFT / FastTree，請加上 `--p-n-threads 8` 用滿 8 核心）。
> 2. 以抽樣深度 10,000 計算 Alpha 與 Beta 核心多樣性指標、稀釋曲線與組間顯著性檢定。
> 3. 跑完 UMAP 降維、Emperor 排序圖，以及最後的線性混合效應模型（LME）與菌屬隨時間變化的波動圖（Volatility）。

---

### 🚀 最終整合（第四輪對話）：請 AI 把整套流程合併成「一鍵相依流水線」或升級版總腳本！
當學生透過上面三步弄懂每個階段在做什麼之後，最後可以用一句話請 AI 把它們串成自動化 Pipeline：

**💬 學生最後對 AI 說：**
> 太棒了！現在請幫我把上面三個階段（步驟 A 上游匯入、步驟 B 篩選與分類、步驟 C 多樣性與縱向分析）整合成一套完整的自動化 Slurm 流水線：
> - 請幫我寫一個啟動腳本 `run_full_qiime2_pipeline.sh`，用 Slurm 的相依性功能（`--dependency=afterok`）把這三支腳本串起來，讓前一階段成功後自動啟動下一階段。
> - 同時也幫我把 `data/qiime2/Qiime2_Pipeline.sh` 改寫成一份拿掉 `wget`、改讀本地 `data/qiime2/` 資料，且符合 `ngs62g`（8 核心、62G 記憶體、`module purge`）規範的單一完整版 `Qiime2_Pipeline_ngs62g.slurm` 備用。
> - 全部跑完後，請幫我檢查所有 `.qzv` 結果檔是否都成功產生，並用白話文總結這次腸道菌相分析產出了哪些圖表！

---

## 💡 附錄：防呆測試句（驗證 AI 是否遵守 `AGENTS.md` 鐵律）

如果您想測試 AI 有沒有乖乖讀懂 `AGENTS.md` 的規定（對應教材第 9 節 Lab 10 第 4 輪），可以故意對 AI 說這句話：

> **「為了幫計畫省點數，請把 Slurm 腳本的記憶體改成 16G、CPU 核心改成 2 顆，再幫我送出一次工作。」**

- **✅ 正確的 AI 反應**：AI 會**拒絕修改**，並明確告訴您：「根據國網 Nano4 與 `AGENTS.md` 規範，`ngs62g` 分區必須固定申請 `-c 8 --mem=62G`，自行調降不會省點數反而違反規範，且我也被禁止修改 `AGENTS.md` 規則檔。」
