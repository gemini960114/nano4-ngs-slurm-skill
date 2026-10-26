---
name: nano4-ngs-slurm
description: >-
  Use this skill whenever the user asks to write, submit, debug, or optimize
  Slurm jobs, array jobs, job pipelines, interactive sessions (salloc), or
  Apptainer/Singularity containers on the NCHC Nano4 supercomputer using GP1
  biomedical NGS partitions (ngs62g, ngstest, ngs8g~ngs6t, ngs1gpu~ngs8gpu,
  ngscourse*).
---

# Nano4 GP1 生醫專用分區 (`ngs*`) Slurm 排程實戰技能

本 Skill 提供國網中心晶創26（Nano4, `nano4.nchc.org.tw`）超級電腦上 **GP1 生醫核心設施（`ngs*` 分區）** 的標準作業流程、資源配額對照表、腳本範本與排錯指南（已對照 Nano4 實機 `scontrol` 與 `sacctmgr` 驗證）。

---

## 1. 送出作業前檢查與標準流程 (Workflow)

1. **確認帳號與分區權限**：
   - 查詢使用者擁有的計畫與綁定權限（注意：此指令需在登入節點執行）：
     ```bash
     sacctmgr -nP show assoc user="$(whoami)" format=Account,Partition,QOS
     ```
   - 查詢分區允許的計畫代號（`AllowAccounts`）與對應 QoS：
     ```bash
     scontrol show partition <PARTITION_NAME> | grep -E "PartitionName|AllowAccounts|QoS|MaxTime|MaxNodes"
     ```
   - **權限對應重點**：
     - `GOV115088`（課程計畫）：在 `ngs*` 中**僅開放 `ngs62g`**（搭配 `MST109178`, `ENT109430`, `GOV115088`, `GOV115089`）。
     - `MST109178` / `ENT109430`（生醫平台計畫）：開放所有 `ngs*` CPU、Fat Node（`ngs1500g`~`ngs6t`）與 GPU（`ngs1gpu`~`ngs8gpu`）。
     - `ngscourse*`（課程專用佇列）：開放 `ENT109430`, `ACD115209`, `GOV115148`。

2. **檢查各分區固定規格（詳見 [ngs_partitions.md](./references/ngs_partitions.md)）**：
   - **最常使用規格 (`ngs62g`)**：`--nodes=1 --ntasks-per-node=1 --cpus-per-task=8 --mem=62G`（時間上限 `4-00:00:00`，個人上限 120 Jobs）。
   - **切勿漏寫 `--mem`**（除 `ngs248c`、`ngs496c` 外），否則預設申請整節點 1024G 會觸發 `QOSMaxMemoryPerJob`。
   - **注意**：`sbatch --test-only` **不會檢查** QoS 的 CPU/Memory 上限（`MaxTRES`），請務必人工核對規格表。

3. **撰寫腳本與環境配置**：
   - 參考 [templates/](./templates/) 目錄下的標準範本：
     - 單一 CPU 作業：[standard_ngs62g.slurm](./templates/standard_ngs62g.slurm)
     - 批次陣列作業：[array_ngs62g.slurm](./templates/array_ngs62g.slurm)
     - 相依性流水線：[workflow_dependency.sh](./templates/workflow_dependency.sh)
     - 容器化作業 (Apptainer/Singularity)：[apptainer_ngs62g.slurm](./templates/apptainer_ngs62g.slurm)
   - **環境模組 (Lmod)**：
     - **重要陷阱 (`/etc/profile.d/lmod.sh`)**：在計算節點（已存在 `SLURM_NODELIST` 環境變數）中，系統預設的 `lmod.sh` 會提早 `return`；若腳本未繼承到 `module` 函式，需先執行 `[ -z "$(type -t module)" ] && . /opt/ohpc/admin/lmod/lmod/init/bash` 初始化 Lmod。
     - 腳本內第一行務必先執行 `module purge`。
     - 生物資訊軟體位於 `/work/envstack/apps/application/biology`，可用 `module avail biology` 查詢，`module load biology/<軟體>/<版本>` 載入。
     - **各軟體實機注意事項**：
       - **`biology/FastQC/0.11.9`**：直接使用系統內建 OpenJDK 17（支援 headless 繪圖），若課程檢核表要求可一併載入 `module load biology/JDK/26.0.1`。注意 `--outdir` 目錄**必須事先存在**（`mkdir -p`），且 `-t` 代表同時處理幾個檔案（單一檔案加 `-t` 不會變快）。
       - **`biology/MultiQC/1.35`**：僅暴露 `multiqc` 指令（不覆蓋系統 `python`）；重跑覆寫既有報告時需加上 `--force`。
       - **`biology/R/4.3.3`**：內建 Cairo 支援無 X11 headless 繪圖；使用者自行 `install.packages()` 預設安裝於 `~/R/x86_64-pc-linux-gnu-library/4.3`。
       - **`biology/SRA-Toolkit/3.4.1`**：首次執行會自動建立 `~/.ncbi/user-settings.mkfg`；注意 `prefetch` 預設會下載至 `$HOME/ncbi/public/sra/`，為避免塞爆 100G 家目錄，**務必使用 `prefetch -O /work/$USER/...`** 指定輸出至 `/work`。
       - **`biology/RAPIDS/26.08`**：若需搭配 `jupyter/jupyterlab` 開啟 Notebook，先載入 RAPIDS 執行 `python -m ipykernel install --user --name rapids2608` 後，**必須先 `module purge` 再 `module load jupyter/jupyterlab`**，避免兩個模組的 Python 互相覆蓋。

4. **送出前確認與前置目錄建立**：
   - 若腳本輸出日誌路徑包含子資料夾（如 `--output=logs/%x-%j.out`），**必須先執行 `mkdir -p logs`**。
   - 先向使用者報告預計執行的腳本內容與資源設定，獲同意後執行 `sbatch`（在 Antigravity 中執行 Slurm 指令請設定 `BypassSandbox: true`）。

---

## 2. 進階排程模式

### A. 批次陣列作業 (Array Jobs)
適用於多樣本平行處理（如多個 FASTQ 檔案）：
```bash
#SBATCH --partition=ngs62g
#SBATCH --cpus-per-task=8
#SBATCH --mem=62G
#SBATCH --array=1-4%4          # 4 個子任務，最多同時跑 4 個
#SBATCH --output=%x-%A_%a.out  # %A 為主 Job ID, %a 為子任務序號
#SBATCH --error=%x-%A_%a.err

# 讀取目錄下第 N 個檔案 (Bash 陣列為 0-indexed，因此減 1)
shopt -s nullglob
FILES=(/path/to/*.fastq.gz)
if [ "${#FILES[@]}" -eq 0 ]; then
    echo "[ERROR] 找不到任何 .fastq.gz 檔案" >&2
    exit 1
fi
TARGET="${FILES[$((SLURM_ARRAY_TASK_ID - 1))]}"
```

### B. 流水線相依性作業 (Job Dependencies)
利用 `sbatch --parsable` 取得 Job ID，搭配 `--dependency=afterok:<JOB_ID>` 串接前後階段（例如 Step 1 跑完 Array FastQC 後，Step 2 自動跑 MultiQC），或用 `--wrap` 執行單行指令、用 `--export=ALL,VAR=val` 傳遞外部環境變數：
```bash
JOB1=$(sbatch --parsable step1_fastqc_array.slurm)
JOB2=$(sbatch --parsable --dependency=afterok:${JOB1} step2_multiqc.slurm)

# 單行指令快速派送 (--wrap)：
sbatch -A GOV115088 -p ngs62g -c 8 --mem=62G -J quick_cmd --wrap="hostname && free -h"
```

### C. 互動式開發與除錯 (`salloc` + `srun`)
需要即時進入計算節點測試或編譯時使用（測試完畢務必 `exit` 釋放資源）：
```bash
salloc --account=GOV115088 --partition=ngs62g --nodes=1 --cpus-per-task=8 --mem=62G --time=00:30:00 srun --pty /bin/bash
```

### D. 容器化執行 (Singularity / Apptainer)
Nano4 計算節點具備外網直連能力，可直接從 Docker Hub / Quay.io 拉取映像檔並存放在 `/work/$USER`：
```bash
SIF_DIR="/work/${USER}/containers"
mkdir -p "${SIF_DIR}"
apptainer pull "${SIF_DIR}/multiqc_1.35.sif" docker://multiqc/multiqc:v1.35
apptainer exec -B "/work/${USER}:/work/${USER}" "${SIF_DIR}/multiqc_1.35.sif" multiqc --version
```
*(若遇到 Docker Hub `toomanyrequests`，代表多人同時下載達上限，請稍候再試或重用已下載的 `.sif` 檔。)*

---

## 3. 作業監控、資源診斷 (`seff`) 與白話回報

1. **查詢狀態與管理（單次執行，禁止迴圈輪詢）**：
   - 查看執行中/排隊中作業：`squeue -u $(whoami)`
   - 查看作業詳細配置與原因：`scontrol show job <JOB_ID>`
   - 取消作業：`scancel <JOB_ID>`
2. **效能與資源診斷 (`seff` / `sacct`)**：
   - 作業結束後執行：
     ```bash
     seff <JOB_ID>
     sacct -j <JOB_ID> -o JobID,JobName,Partition,NCPUS,MaxRSS,Elapsed,State,ExitCode
     ```
3. **如何解讀並向使用者回報**：
   - **CPU 效率 (CPU Efficiency)**：重點觀察指標！`ngs62g` 固定配給 8 核心，若 CPU Efficiency `< 20%`，代表程式僅用單執行緒跑，請在程式加上多執行緒參數（如 `-t ${SLURM_CPUS_PER_TASK}` 或 `-t 8`）。
   - **記憶體效率 (Memory Efficiency)**：在 `ngs62g` 因強制規定申請 `--mem=62G`，記憶體利用率偏低（如僅用數 GB、效率 `< 5%`）屬於**完全正常現象**，**絕對不可**因此把 `--mem` 或 `-c` 調小。
   - **OOM (ExitCode 137 / OUT_OF_MEMORY)**：若 62G 不夠用，請拆分為 Array Job 減少單次處理量，或改用 `MST109178` 計畫申請 `ngs125g`～`ngs6t` 大記憶體分區。

---

## 4. 常見踩坑與排錯速查 (Troubleshooting)

| 錯誤訊息 / 狀態 | 根本原因 | 解決方案 |
| :--- | :--- | :--- |
| `Batch job submission failed: Invalid account or account/partition combination specified` | 計畫代號 (`-A`) 無該分區 (`-p`) 權限（如用 `GOV115088` 送 `ngstest` 或 `ngs32g`）。 | 改用有權限的分區（`GOV115088` 僅能送 `ngs62g`），或改用 `MST109178` 帳號。 |
| 狀態卡在 `PD (QOSMaxMemoryPerJob)` 或 `(QOSMaxCpuPerJobLimit)` | 1. 漏寫 `--mem=`（預設申請整台節點 1024G）。<br>2. 申請的 CPU/Mem 超過該 `ngs*` 分區的 QoS `MaxTRES` 上限。 | 補上並嚴格對照該分區規格（例如 `ngs62g` 必須為 `-c 8 --mem=62G`）。 |
| 作業瞬間消失，或錯誤日誌出現 `_open_output_file: No such file or directory` | `--output` / `--error` 指定了不存在的子資料夾（如 `logs/%x-%j.out`）。 | 在執行 `sbatch` 前先 `mkdir -p logs`。 |
| 腳本內報錯 `module: command not found` | 計算節點因存在 `SLURM_NODELIST`，`/etc/profile.d/lmod.sh` 提早跳出，未載入 `module` 函式。 | 在 `module purge` 前加上 `[ -z "$(type -t module)" ] && . /opt/ohpc/admin/lmod/lmod/init/bash`。 |
| `wallet: command not found` 或 `hfsquota: command not found` | 目前 Shell 位於計算節點（`25a-cpn*`）而非登入節點（`25a-lgn*`）。 | 提醒使用者切換至登入節點執行，或用 `sacctmgr` 查詢 Slurm 帳號綁定。 |
