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

## 範例 1：環境建置 —— 本機暖身與連線 Nano4

### 步驟 1-1-4（本機）：用自然語言安裝 Git 與 uv
```text
請判斷我的作業系統，檢查 Git 與 uv 是否已安裝，缺少的請安裝：
- Windows：用 WinGet 安裝。
- macOS：Git 用系統內建的命令列開發者工具，uv 用官方安裝指令（不需 Homebrew）。
安裝後若找不到指令，請開新的終端機再確認，最後回報版本。
```

### 步驟 1-1-4（本機）：4 個樣本的小型分析
```text
請從 https://github.com/gemini960114/nano4-ngs-slurm-skill/tree/main/data/fastq_4samples 下載 4 個 FASTQ 檔到 data/，
用 uv 在這個資料夾建立 .venv 並安裝需要的套件，對每個樣本計算 read 數、平均長度與 GC 含量，
整理成一張 CSV 表格，再畫一張 4 個樣本的比較圖存成 PNG。
```

### 步驟 1-2-6（Nano4）：安裝 uv、建立 .venv、確認計畫代號並檢查 AGENTS.md
```text
請在 Nano4 上準備 Python 環境（不需 sudo）：
1. 檢查是否有 uv，沒有的話安裝到我的家目錄；uv 快取與 uv 下載的 Python 都放在 /work/$USER。
2. 在教材目錄用 uv 建立 Python 3.12 的 .venv。
3. 用 wallet 確認我有哪些計畫代號，是否包含課程計畫 GOV115088。
最後用三句話告訴我，你從 AGENTS.md 讀到在 Nano4 上最重要的規則。
```

---

## 範例 2：Slurm 基礎練習與自訂 Skill —— 讀取官方文件、練習基礎 Slurm 作業，最後濃縮成 Skill

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
幫我寫 Slurm 腳本送到計算節點去跑（用課程計畫 GOV115088，分區 ngs62g 固定 8 核心與 62G 記憶體）。
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
這次不要用 module load，請改寫一個用 Apptainer 容器執行的 Slurm 工作：
1. 在計算節點直接從 Docker Hub 下載 multiqc/multiqc:v1.35 映像檔，.sif 檔存在 /work/$USER/containers/，Apptainer 快取也設在 /work/$USER/（home 空間有限）。
2. 用這個容器去掃描剛剛 qc/fastqc_out/ 的結果，產生 MultiQC 報告到 tutorial/case05/multiqc_out/。
3. 腳本報告放在目前目錄 tutorial/case05
```

---

### 步驟 2-6：把官方文件重點與實作經驗濃縮成自己的 `my-nano4-slurm` Skill 並實測
```text
經過剛剛的練習，請幫我擷取國網 GP1 官方說明文件（https://man.twcc.ai/xOYzPATVS_aDlbuqMrwhyg）的重點，以及我們剛剛實作 Slurm 單一作業、Array Job、相依流水線與 Apptainer 容器的經驗，在 .agents/skills/my-nano4-slurm/SKILL.md 建立一份我自己的 Slurm 排程技能：

0. YAML Frontmatter 設定（防衝突）：
   - name 設為 my-nano4-slurm
   - description 設為「學員自訂之 Nano4 Slurm 排程練習技能；僅在使用者於對話中明確點名使用 my-nano4-slurm 時載入」（避免與專案預設的 nano4-ngs-slurm 自動觸發衝突）。
1. 執行環境與安全規範：
   - 嚴禁在登入節點運算，必須透過 sbatch / salloc 派送至計算節點。
   - 嚴禁使用 watch 或無窮迴圈每秒高頻輪詢 squeue（長時作業若需自動監控，應使用定時排程工具每 5 分鐘低頻檢查一次單次 squeue / sacct）。
   - 提交 sbatch 前必須先向使用者說明預計使用的計畫代號、分區與資源配置，獲確認後才送出。
2. 腳本必填參數與環境設定：
   - 明確指定 --cpus-per-task 與 --mem（例如課程計畫 GOV115088 固定使用 ngs62g：-c 8 --mem=62G），防範預設申請整台節點記憶體卡死。
   - 腳本內先執行 module purge 再載入模組；大量資料與 Apptainer 快取一律放在 /work/$USER。
3. 單一作業、Array Job、afterok 相依流水線與 Apptainer 容器的標準腳本範本。
```

**實測自己建立的 `my-nano4-slurm` 技能並與內建版比對：**
```text
請載入我剛建立的 my-nano4-slurm 技能，幫我檢查並產生一個測試作業（在計算節點印出 hostname、CPU 核心數與記憶體大小，輸出至 tutorial/test_my_skill/），同時幫我比較看看我寫的 my-nano4-slurm 跟專案內建的 nano4-ngs-slurm 技能有哪些異同或還可以補充的地方？
```

---

## 範例 3：管線派送與監控 —— QIIME 2 腸道菌相分析 (`tutorial/case06` ~ `case07`)

### 🔹 步驟 3-1：請 AI 讀懂分析腳本（研究背景與三段流程）
```text
請閱讀 data/qiime2/Qiime2_Pipeline.sh（先不要送出任何作業），用白話文告訴我：
1. 這份資料的研究背景，以及想回答什麼問題。
2. 流程分成哪幾段、各段的輸入與產出，以及哪些段落彼此相依。
3. 預計會產生哪些 .qzv 圖表，各自可以看出什麼。
```

### 🔹 步驟 3-2 (`tutorial/case06`)：上游 82 個雙端 FASTQ 匯入與品質評估（Upstream）
```text
請參考 data/qiime2/Qiime2_Pipeline.sh 的上游段落，寫一支 Slurm 作業送到計算節點，結果放在 tutorial/case06/qiime2_run/Upstream/：
1. 載入 biology/qiime2/2026.7 模組（資料已在 data/qiime2/，不需 wget）。
2. 把 data/qiime2/Input_Data/data_to_import/ 的 82 個雙端 FASTQ 匯入成 demultiplexed-sequences.qza，並產生品質摘要圖 demultiplexed-sequences-summ.qzv。
3. 讀取現成的 data/qiime2/Upstream/feature-table-0.qza，產出 feature-table-0-summ.qzv。
送出後每 5 分鐘檢查一次狀態，跑完通知我。
```

### 🔹 步驟 3-3 (`tutorial/case06`)：下游篩選分類 ➔ 多樣性分析，afterok 串接一次送出
```text
請參考 data/qiime2/Qiime2_Pipeline.sh 的下游段落，寫兩支 Slurm 腳本，用 --dependency=afterok 串接後一次送出（同樣載入 biology/qiime2/2026.7）：
1. 篩選與分類，結果放在 tutorial/case06/qiime2_run/Downstream/：
   - 讀取 data/qiime2/Input_Data/ 的 sample-metadata.tsv、feature-table.qza、rep-seqs.qza 與 silva-138.2-ssu-nr99-515f-806r-classifier.qza。
   - 照腳本條件篩選檢體（autoFmtGroup 有值、移植前後 -10 到 70 天、至少出現在 2 個檢體、排除葉綠體與粒線體、總讀序數 >= 10,000）。
   - 菌種分類加上 --p-n-jobs 8，並產生物種組成堆疊圖 taxa-bar-plots-1.qzv。
2. 多樣性與縱向分析，結果放在 tutorial/case06/qiime2_run/Diversity_Longitudinal/：
   - 用第 1 支篩選後的序列建立演化樹（MAFFT / FastTree，加上 --p-n-threads 8）。
   - 以抽樣深度 10,000 計算 Alpha 與 Beta 多樣性、稀釋曲線與組間顯著性檢定。
   - 跑 UMAP、Emperor 排序圖、線性混合效應模型（LME）與菌屬波動圖（Volatility）。
送出後每 5 分鐘檢查一次狀態（全部約 13 分鐘），跑完後確認所有 .qzv 都有產生，並用白話文說明產出了哪些圖表。
```

### 🔹 選做 (`tutorial/case07`)：整合成單一完整版 Slurm 腳本
```text
請把 data/qiime2/Qiime2_Pipeline.sh 改寫成一份拿掉 wget、改讀本地 data/qiime2/ 資料，且符合 ngs62g 規範的單一完整版 Qiime2_Pipeline_ngs62g.slurm，放在 tutorial/case07。先不要送出。
```

---

## 範例 4：結果解讀與報告 (`nano4-ngs-report` Skill)

### 讀取分析結果，自動整理成圖文報告（`.md` + 單一獨立 `.html`）
```text
請啟用 nano4-ngs-report 技能，掃描 tutorial/case01 ~ case06 下的所有 Slurm 腳本、執行日誌（*.out / *.err）與分析產出檔案，為我撰寫一份結合「Runbook 操作手冊」與「生醫 Methods & Results 數據解讀」的完整分析報告，並使用技能內建的轉換腳本同步輸出 .md 與單一獨立 .html 報告至 tutorial/report01/。
```

---

