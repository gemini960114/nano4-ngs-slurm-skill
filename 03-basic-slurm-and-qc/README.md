# 範例 2：自訂 Skill —— 讀取官方文件、練習派送 Slurm，最後濃縮成專屬技能

在一般情況下，剛連上一台新的 HPC 超級電腦時，AI 並不曉得這台機器的佇列名稱（例如 `ngs62g`）、計畫代號規定或軟體模組載入方式。本單元示範如何從讀取國網官方網頁開始，經過實作練習，最後請 AI 將重點濃縮成專屬 Skill。

| 步驟 | 內容 | 預估時間 |
| :--- | :--- | :---: |
| **第 1 步** | [請 AI 讀取國網 GP1 官方線上說明文件](#第-1-步請-ai-讀取國網-gp1-官方線上說明文件) | 3 分鐘 |
| **第 2 步** | [請 AI 編寫並派送基礎 Slurm 作業 (`Case 01` ~ `Case 05`)](#第-2-步請-ai-編寫並派送基礎-slurm-作業) | 15 分鐘 |
| **第 3 步** | [請 AI 擷取文件重點與實作經驗，自動編寫 `AGENTS.md` 與 Skill](#第-3-步請-ai-擷取文件重點與實作經驗自動編寫-skill) | 5 分鐘 |

```mermaid
flowchart LR
    S1["第 1 步：讀取國網 GP1 官方網頁"] --> S2["第 2 步：實作練習 Slurm 作業 (Case 01~05)"]
    S2 --> S3["第 3 步：擷取重點自動編寫 AGENTS.md 與 Skill"]
```

> [!NOTE]
> **💡 讀者疑問：為什麼剛剛 `git clone` 下來的資料夾裡已經有 `AGENTS.md` 與 `.agents/skills/`，這裡還要教怎麼從官方網頁產生？**
> - 為了讓大家上課操作穩定，本教材資料夾已經**預先內建好一份完成版**的 `AGENTS.md` 與 `nano4-ngs-slurm` 技能。
> - 但為了讓您學會**「未來面對新主機或新軟體時，如何自己做一個 Skill」**，本單元帶您完整體驗一次從「讀官方網頁 ➔ 實作練習 ➔ 自動濃縮成 Skill」的過程！

---

## 第 1 步：請 AI 讀取國網 GP1 官方線上說明文件

不用自己從頭背手冊！請直接複製下方指令貼給右側的 AI Agent，讓它先讀懂國網 Nano4 生醫節點的使用規範：

### 📋 請複製以下指令貼給 AI Agent：

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

## 第 2 步：請 AI 編寫並派送基礎 Slurm 作業

讀完官方手冊後，我們用 `data/fastq_4samples/` 裡面的 **4 個輕量定序樣本**，依序請 AI 幫我們編寫並派送 5 種常見的批次作業。

> [!IMPORTANT]
> **💬 人機協同操作方式（兩階段確認）**：
> 當您把下方任一練習的指令貼給 AI 後：
> 1. **第一階段（AI 擬定計畫）**：AI 會先寫好腳本，並在對話框向您報告預計使用的**計畫代號（`GOV115088`）、分區（`ngs62g`）與資源設定（8 核心 / 62G）**，然後停下來等您確認。
> 2. **第二階段（您確認派送）**：請在對話框輸入 **`好，請送出`**（或 **`同意`**），AI 才會真正執行 `sbatch` 將工作送到計算節點！（若跳出終端機執行權限詢問，請點擊 **Allow / Approve**。）

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

### 練習 3 (`tutorial/case03`)：FastQC 與 MultiQC 品質檢查流水線（前後相依作業 Dependency）

```text
請幫我對 data/fastq_4samples/ 裡面的 4 個樣本做品質檢查流水線：
- 第一步：用 FastQC 檢查這 4 個樣本的品質，結果放在 qc/fastqc_out/。
- 第二步：等第一步確定成功跑完後，自動啟動 MultiQC 把結果彙整成一份 HTML 報告，放在 qc/multiqc_out/。
先告訴我你打算怎麼送，我同意後再送出。
腳本放在目前目錄 tutorial/case03
```

- **💡 如何查看產出的 MultiQC 網頁報告？**
  跑完後，在左側檔案總管展開 `qc/multiqc_out/`，在 **`multiqc_report.html`** 上按**滑鼠右鍵 ➔ `Download...`** 下載回個人電腦，雙擊即可用瀏覽器打開互動式品管圖表！

---

### 練習 4 (`tutorial/case04`)：檢查作業狀態與資源使用率（`sacct` / `seff`）

```text
剛剛送出去的工作跑完了嗎？如果跑完了，請幫我用 seff（或 sacct）檢查資源使用率，並用白話文跟我說跑得順不順、這 4 個樣本的品質結果如何。
結果報告放置於 tutorial/case04
```

> [!TIP]
> **常見問題：為什麼在終端機打 `squeue -u $USER` 沒看到剛剛送出的工作？**
> 因為 `squeue` 只會顯示「正在排隊 (`PD`)」或「執行中 (`R`)」的作業。練習用的 4 個 FASTQ 檔案很小（每檔 1,000 reads），計算節點約 **8 秒鐘** 就跑完 FastQC 與 MultiQC 並離開佇列了！若要查詢已完成的作業，請使用 `sacct -u $USER -S today`。

---

### 練習 5 (`tutorial/case05`)：改用 Apptainer 容器執行，並將快取設在 `/work/$USER/`

```text
以下的內容會用到 apptainer 下載 image，但 home 目錄空間有限，請補充將 cache 設在 /work/$USER/。

這次不要用 module load，請改寫一個用 Apptainer 容器執行的 Slurm 工作：
1. 在計算節點直接從 Docker Hub 下載 multiqc/multiqc:v1.35 映像檔，.sif 檔請存在我的 /work/$USER/containers/。
2. 用這個容器去掃描剛剛 qc/fastqc_out/ 的結果，產生 MultiQC 報告到 tutorial/case05/multiqc_out/。
3. 腳本報告放在目前目錄 tutorial/case05
```

---

## 第 3 步：請 AI 擷取文件重點與實作經驗自動編寫 Skill

在完成上面一連串練習後，我們已經清楚哪些地方最容易踩坑（例如：不能在登入節點跑運算、漏寫 `--mem` 會預設申請 1024G 卡死、提交子目錄日誌前要先 `mkdir -p`、Apptainer 快取要指到 `/work/$USER`、不能用迴圈狂刷 `squeue`）。

現在，您可以直接下達以下指令，**請 AI 把剛剛讀過的國網官方文件與實作經驗，自動編寫成您自己的 `.agents/skills/my-nano4-slurm/SKILL.md` 技能，並立即呼叫使用它**：

### 📋 1. 請複製以下指令貼給 AI Agent（建立您自己的 `my-nano4-slurm` Skill）：

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

### 📋 2. 立即實測您剛建立的 `my-nano4-slurm` 技能（並與內建標準版比對）：

建立完成後，您可以直接用下面這段話**實際呼叫您剛寫好的 `my-nano4-slurm` 技能**，並請 AI 與教材預先準備的 `nano4-ngs-slurm` 對照：

```text
請載入我剛建立的 my-nano4-slurm 技能，幫我檢查並產生一個測試作業（在計算節點印出 hostname、CPU 核心數與記憶體大小，輸出至 tutorial/test_my_skill/），同時幫我比較看看我寫的 my-nano4-slurm 跟專案內建的 nano4-ngs-slurm 技能有哪些異同或還可以補充的地方？
```

> [!TIP]
> **為什麼用 `my-nano4-slurm` 這個新名稱？**
> - 存放在 `.agents/skills/my-nano4-slurm/SKILL.md` 後，它就是一個**正式生效的技能**，在接下來的**範例 3（QIIME 2 分析）**中您也可以直接指定使用它！
> - 同時，它不會覆蓋掉教材原本內建的 `.agents/skills/nano4-ngs-slurm/`（唯讀保護中），讓您隨時都有一份官方標準版可以對照與保底。

---

👉 有了專屬的 Nano4 Slurm Skill 後，接下來請進入 **[範例 3：管線派送與監控 —— 以 QIIME 2 腸道菌相分析為例](../04-qiime2-microbiome-pipeline/README.md)**！
