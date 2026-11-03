# 範例 2：Slurm 基礎練習與自訂 Skill —— 讀取官方文件、練習派送 Slurm，最後濃縮成專屬技能

本單元先在終端機熟悉幾個 Linux 與 Nano4 基本指令，並親手派送第一個 Slurm 作業，了解「登入節點派送、計算節點執行」的流程。

接著換 AI 上場：一般情況下，剛連上一台新的 HPC 超級電腦時，AI 並不曉得這台機器的佇列名稱（例如 `ngs62g`）、計畫代號規定或軟體模組載入方式。後半段示範如何從讀取國網官方網頁開始，經過實作練習，最後請 AI 將重點濃縮成專屬 Skill。

> 📥 **本單元上課簡報**：[下載 2_Slurm基礎練習與自訂Skill.pptx](https://github.com/gemini960114/nano4-ngs-slurm-skill/raw/main/PPTX/2_Slurm%E5%9F%BA%E7%A4%8E%E7%B7%B4%E7%BF%92%E8%88%87%E8%87%AA%E8%A8%82Skill.pptx)（19 頁，含講者備註）

| 步驟 | 內容 | 預估時間 |
| :--- | :--- | :---: |
| **第 1 步** | [終端機暖身：Linux 與 Nano4 基本指令](#第-1-步終端機暖身linux-與-nano4-基本指令) | 5 分鐘 |
| **第 2 步** | [親手派送第一個 Slurm 作業 (`Case 00`)](#第-2-步親手派送第一個-slurm-作業) | 5 分鐘 |
| **第 3 步** | [請 AI 讀取國網 GP1 官方線上說明文件](#第-3-步請-ai-讀取國網-gp1-官方線上說明文件) | 3 分鐘 |
| **第 4 步** | [請 AI 編寫並派送基礎 Slurm 作業 (`Case 01` ~ `Case 05`)](#第-4-步請-ai-編寫並派送基礎-slurm-作業) | 25 分鐘 |
| **第 5 步** | [請 AI 擷取文件重點與實作經驗，自動編寫 Skill](#第-5-步請-ai-擷取文件重點與實作經驗自動編寫-skill) | 5 分鐘 |

```mermaid
flowchart LR
    T1["第 1 步：終端機暖身"] --> T2["第 2 步：親手派送第一個作業 (Case 00)"]
    T2 --> S1["第 3 步：讀取國網 GP1 官方網頁"]
    S1 --> S2["第 4 步：實作練習 Slurm 作業 (Case 01~05)"]
    S2 --> S3["第 5 步：擷取重點自動編寫 Skill"]
```

> [!NOTE]
> **💡 讀者疑問：為什麼剛剛 `git clone` 下來的資料夾裡已經有 `AGENTS.md` 與 `.agents/skills/`，這裡還要教怎麼從官方網頁產生？**
> - 為了讓大家上課操作穩定，本教材資料夾已經**預先內建好一份完成版**的 `AGENTS.md` 與 `nano4-ngs-slurm` 技能。
> - 但為了讓您學會**「未來面對新主機或新軟體時，如何自己做一個 Skill」**，本單元帶您完整體驗一次從「讀官方網頁 ➔ 實作練習 ➔ 自動濃縮成 Skill」的過程！

---

## 第 1 步：終端機暖身：Linux 與 Nano4 基本指令

請點選上方選單「**終端機 → 新增終端機**」（`Terminal → New Terminal`）。連上 Nano4 後開啟的終端機就是 Nano4 的 Linux 環境，請逐行輸入下列指令並觀察輸出。

### 1. Linux 基本指令

```bash
hostname                               # 目前所在的主機名稱（登入節點為 25a-lgn*）
pwd                                    # 目前所在的目錄
ls                                     # 列出目錄內的檔案
ls -al                                 # 列出全部檔案（含 . 開頭的隱藏檔）與權限、大小、日期
cd /work/$USER/nano4-ngs-slurm-skill   # 切換到教材根目錄
pwd
ls -al data/fastq_4samples             # 範例 1-1 用過的 4 個 FASTQ 檔
df -h /home/$USER                      # 確認 /home 目前可用空間（上限 100G，只放腳本與設定）
df -h /work/$USER                      # 確認 /work 目前可用空間（資料、暫存、.sif 放這裡）
```

### 2. Nano4 與 Slurm 查詢指令

```bash
wallet            # 我有哪些計畫代號與剩餘額度（只能在登入節點執行）
sinfo -p ngs62g   # ngs62g 分區的節點與狀態（idle 閒置、mix 部分使用、alloc 已滿）
squeue            # 所有使用者正在排隊 (PD) 或執行中 (R) 的作業
squeue -u $USER   # 只看自己的作業（目前應該是空的）
```

> [!TIP]
> `sinfo` 不加 `-p` 會列出所有分區，輸出很長；`squeue` 同理，只想看自己的作業請加 `-u $USER`。查詢作業時**單次執行即可**，不要用 `watch` 或迴圈反覆刷新（見 `AGENTS.md`）。

---

## 第 2 步：親手派送第一個 Slurm 作業

用範例 1-1 同樣的 4 個 FASTQ 檔，計算 read 數、平均長度與 GC 含量，這次改送到計算節點執行。這個計算幾秒就完成，因此腳本開頭刻意先 `sleep 30`，讓您有時間用 `squeue` 看到作業。

腳本已放在教材中（[`first_gc_job.slurm`](./first_gc_job.slurm)），內容如下：

```bash
#!/bin/bash
#SBATCH --account=GOV115088                  # 計畫代號（課程計畫）
#SBATCH --job-name=first-gc                  # 作業名稱（日誌檔名的 %x）
#SBATCH --partition=ngs62g                   # 分區
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8                    # ngs62g 固定 8 核心
#SBATCH --mem=62G                            # ngs62g 固定 62G，漏寫會排不上
#SBATCH --time=00:10:00                      # 最長執行時間
#SBATCH --output=tutorial/case00/%x-%j.out   # 標準輸出（%j 為 Job ID）
#SBATCH --error=tutorial/case00/%x-%j.err    # 錯誤訊息

set -euo pipefail

echo "計算節點：$(hostname)"
echo "開始時間：$(date)"

# 刻意等 30 秒，讓您有時間用 squeue -u $USER 看到這個作業
sleep 30

# 對 4 個 FASTQ 檔計算 read 數、平均長度與 GC 含量（每 4 行的第 2 行是序列）
printf "file\treads\tmean_len\tgc_pct\n"
for f in data/fastq_4samples/*.fastq.gz; do
    zcat "$f" | awk -v name="$(basename "$f")" '
        NR % 4 == 2 { n++; len += length($0); gc += gsub(/[GCgc]/, "") }
        END { printf "%s\t%d\t%.2f\t%.2f\n", name, n, len / n, 100 * gc / len }'
done

echo "結束時間：$(date)"
```

在終端機依序執行（一律在教材根目錄送出）：

```bash
cd /work/$USER/nano4-ngs-slurm-skill
mkdir -p tutorial/case00                           # 日誌目錄要先建立，否則作業會直接失敗
sbatch 03-basic-slurm-and-qc/first_gc_job.slurm    # 送出後會顯示 Submitted batch job <Job ID>
squeue -u $USER                                    # 30 秒內可看到作業狀態 PD（排隊）或 R（執行中）
```

約 1 分鐘後作業結束，`squeue -u $USER` 就看不到它了。查看結果：

```bash
ls tutorial/case00
cat tutorial/case00/first-gc-*.out
```

觀察兩件事：

1. **`計算節點` 的主機名稱**（`25a-cpn*`）和第 1 步 `hostname` 看到的登入節點不同：作業是在計算節點上執行的。
2. **4 個檔案的數值**：可以和範例 1-1 在本機算出的 CSV 對照，結果應該一致。

> [!NOTE]
> - **`.out` 是空的或內容不完整**：用 `cat tutorial/case00/first-gc-*.err` 查看錯誤訊息。
> - **`tutorial/case00/` 裡什麼都沒有**：通常是送出前忘了 `mkdir -p tutorial/case00`。Slurm 找不到日誌目錄時，作業會直接失敗，連 `.err` 都不會產生；請用 `sacct -j <Job ID>` 確認狀態是否為 `FAILED`，補建目錄後重新 `sbatch` 即可。

---

## 第 3 步：請 AI 讀取國網 GP1 官方線上說明文件

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

## 第 4 步：請 AI 編寫並派送基礎 Slurm 作業

讀完官方手冊後，我們用 `data/fastq_4samples/` 裡面的 **4 個輕量 FASTQ 檔**（2 個檢體的 R1/R2 正反向讀序），依序請 AI 幫我們編寫並派送 5 種常見的批次作業。

> [!IMPORTANT]
> **💬 人機協同操作方式（兩階段確認）**：
> 當您把下方任一練習的指令貼給 AI 後：
> 1. **第一階段（AI 擬定計畫）**：AI 會先寫好腳本，並在對話框向您報告預計使用的**計畫代號（`GOV115088`）、分區（`ngs62g`）與資源設定（8 核心 / 62G）**，然後停下來等您確認。
> 2. **第二階段（您確認派送）**：請在對話框輸入 **`好，請送出`**（或 **`同意`**），AI 才會真正執行 `sbatch` 將工作送到計算節點！（若跳出終端機執行權限詢問，請點擊 **Allow / Approve**。）
>
> 所有作業都在教材根目錄送出，腳本、日誌（`*.out` / `*.err`）與結果會放在各練習的 `tutorial/caseXX/`。

---

### 練習 1 (`tutorial/case01`)：請 AI 把 Case 00 改寫成 Python 版（單一批次作業）

```text
請參考 03-basic-slurm-and-qc/first_gc_job.slurm（我在第 2 步親手送過的 Case 00），改寫成 Python 版：
用 Python 程式對 data/fastq_4samples/ 的 4 個 FASTQ 檔計算 read 數、平均長度與 GC 含量，
並寫成 Slurm 腳本送到計算節點執行（課程計畫 GOV115088，分區 ngs62g 固定 8 核心與 62G 記憶體）。
腳本、日誌與結果都放在 tutorial/case01/。送出前先跟我說你的設定，跑完後把結果和 tutorial/case00/ 的輸出對照給我看。
```

---

### 練習 2 (`tutorial/case02`)：4 個檔案同時計算（Slurm 陣列作業 Array Job）

```text
data/fastq_4samples/ 有 4 個 FASTQ 檔（.fastq.gz），請用 Slurm 陣列作業（Array Job）讓 4 個檔案同時計算 read 數、平均長度與 GC 含量，
全部完成後彙整成一張表，並和 tutorial/case00/ 逐一處理的結果對照。
腳本、日誌與結果都放在 tutorial/case02/。送出前先給我看計畫。
```

---

### 練習 3 (`tutorial/case03`)：FastQC 與 MultiQC 品質檢查流水線（前後相依作業 Dependency）

```text
請幫我對 data/fastq_4samples/ 裡面的 4 個 FASTQ 檔做品質檢查流水線：
- 第一步：用 FastQC 檢查這 4 個檔案的品質，結果放在 tutorial/case03/qc/fastqc_out/。
- 第二步：等第一步確定成功跑完後，自動啟動 MultiQC 把結果彙整成一份 HTML 報告，放在 tutorial/case03/qc/multiqc_out/。
腳本與日誌放在 tutorial/case03/。先告訴我你打算怎麼送，我同意後再送出。
```

- **💡 如何查看產出的 MultiQC 網頁報告？**
  跑完後，在左側檔案總管展開 `tutorial/case03/qc/multiqc_out/`，在 **`multiqc_report.html`** 上按**滑鼠右鍵 ➔ `Download...`** 下載回個人電腦，雙擊即可用瀏覽器打開互動式品管圖表！

---

### 練習 4 (`tutorial/case04`)：檢查作業狀態與資源使用率（`sacct` / `seff`）

```text
練習 3 的 FastQC 與 MultiQC 作業跑完了嗎？如果跑完了，請用 seff（或 sacct）檢查這兩個作業的資源使用率，並用白話文跟我說跑得順不順、這 4 個檔案的品質結果如何。
報告放在 tutorial/case04/。
```

> [!TIP]
> 這些練習作業幾秒就跑完，`squeue -u $USER` 很快就看不到了（第 2 步已經看過）。查詢已完成的作業請用 `sacct -u $USER -S today`。

---

### 練習 5 (`tutorial/case05`)：改用 Apptainer 容器執行，並將快取設在 `/work/$USER/`

```text
這次不要用 module load，請改寫一個用 Apptainer 容器執行的 Slurm 工作：
1. 在計算節點直接從 Docker Hub 下載 multiqc/multiqc:v1.35 映像檔，.sif 檔存在 /work/$USER/containers/，Apptainer 快取也設在 /work/$USER/（home 空間有限）。
2. 用這個容器去掃描剛剛 tutorial/case03/qc/fastqc_out/ 的結果，產生 MultiQC 報告到 tutorial/case05/multiqc_out/。
3. 腳本、日誌與報告都放在 tutorial/case05/。
```

---

## 第 5 步：請 AI 擷取文件重點與實作經驗自動編寫 Skill

剛剛的練習之所以順利，是因為 HPC 上常見的坑，AI 都替您避開了（例如：不能在登入節點跑運算、漏寫 `--mem` 會預設申請 1024G 卡死、提交子目錄日誌前要先 `mkdir -p`、Apptainer 快取要指到 `/work/$USER`、不能用迴圈狂刷 `squeue`）。這是因為教材內建的 `AGENTS.md` 與 Skill 裡寫了這些規則；現在換您把它們寫成自己的 Skill。

現在，您可以直接下達以下指令，**請 AI 把剛剛讀過的國網官方文件與實作經驗，自動編寫成您自己的 `.agents/skills/my-nano4-slurm/SKILL.md` 技能，並立即呼叫使用它**（教材內建的 `AGENTS.md`，就是把這類規則中最核心的幾條，濃縮成每次對話都會載入的版本）：

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
> - 同時，它不會覆蓋掉教材原本內建的 `.agents/skills/nano4-ngs-slurm/`（受 `AGENTS.md` 規則保護），讓您隨時都有一份官方標準版可以對照與保底。

---

👉 有了專屬的 Nano4 Slurm Skill 後，接下來請進入 **[範例 3：管線派送與監控 —— 以 QIIME 2 腸道菌相分析為例](../04-qiime2-microbiome-pipeline/README.md)**！
