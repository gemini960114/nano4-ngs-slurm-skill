# Nano4 (晶創26) Slurm 排程與 GP1 生醫 NGS 規範

本專案運行於國網中心 **Nano4 (`nano4.nchc.org.tw`)** 超級電腦叢集，僅使用 **GP1 生醫專用 `ngs*` 分區**。Agent 在協助撰寫腳本、提交作業或處理資料時，必須嚴格遵守以下最小核心鐵律：

## 1. 執行環境與安全鐵律
- **嚴禁在登入節點運算**：登入節點（`25a-lgn01~05`）僅供編輯程式與派送工作。任何多核心運算、資料質控（FastQC/MultiQC）、序列比對或模型訓練，**必須**透過 `sbatch` 或 `salloc` 派送至計算節點（`25a-cpn*` / `25a-mpn*` / `25a-hgpn*`）執行。
- **嚴禁高頻輪詢 `squeue`**：**絕對禁止**使用 `watch` 或在迴圈中反覆呼叫 `squeue` 監控作業狀態，避免癱瘓排程資料庫。請查詢單次 `squeue -u $(whoami)`，或於腳本設定 `--mail-type=END,FAIL`。
- **提交前確認計畫**：在執行 `sbatch` 派送作業前，請先向使用者說明預計使用的計畫代號（Account）、分區（Partition）與資源配置。（註：Antigravity 沙盒預設封鎖網路，執行 `sbatch`、`squeue`、`sacct`、`scontrol` 等 Slurm 指令需開啟 `BypassSandbox: true`。）

## 2. 計畫代號與 `ngs*` 分區權限（不可混用）
- **課程計畫 `GOV115088`**：在 NGS 佇列中**僅允許使用 `ngs62g`**（固定規格：`-c 8 --mem=62G`，最長 4 天）。不可派送至 `ngstest`、`ngs32g`、`ngscourse*` 或 GPU 分區。
- **生醫平台計畫 `MST109178` / `ENT109430`**：可使用完整 `ngs*` CPU（`ngstest`、`ngs8g`～`ngs1000g`、`ngs248c`、`ngs496c`）、大記憶體（`ngs1500g`～`ngs6t`）與生醫 GPU（`ngs1gpu`～`ngs8gpu`）分區。
- **注意**：`sbatch --test-only` 僅檢查語法與分區權限，**不會檢查 QoS 資源上限（`MaxTRES`）**！若超出分區規格，提交後會卡在 `PD (QOSMaxMemoryPerJob / QOSMaxCpuPerJobLimit)`。

## 3. Slurm 腳本必填規範（`ngs*` 專屬）
1. **明確指定記憶體與核心（防範 1024G 預設值陷阱）**：
   - 國網 `ngs*` 佇列採固定比例配額。**必須明確寫出 `#SBATCH --cpus-per-task=<N>` 與 `#SBATCH --mem=<SIZE>`**（僅跨節點佇列 `ngs248c`、`ngs496c` 不指定 `--mem`）。
   - 若漏寫 `--mem`，Slurm 預設會申請整台節點記憶體（1024G），導致因超過 QoS 上限而永遠無法執行。
   - **禁止自行縮減 `ngs62g` 規格**：在 `ngs62g` 作業中，請固定申請 `-c 8 --mem=62G`，勿因 `seff` 顯示記憶體用量低而自行調降，應透過開啟程式多執行緒（如 `-t ${SLURM_CPUS_PER_TASK}`）把 8 核心用滿。
2. **日誌命名與目錄檢查**：
   - 標準輸出與錯誤日誌統一使用 `#SBATCH --output=%x-%j.out` 與 `#SBATCH --error=%x-%j.err`（陣列作業使用 `%x-%A_%a.out` / `%x-%A_%a.err`）。
   - 若日誌指定輸出至子目錄（如 `logs/%x-%j.out`），提交 `sbatch` 前**必須先執行 `mkdir -p logs`**，否則作業會因 `_open_output_file: No such file or directory` 瞬間失敗。
3. **環境模組與容器規範**：
   - 腳本執行區第一行必須先執行 `module purge` 清理環境，再執行 `module load biology/<軟體>/<版本>`。
   - 嚴禁使用 `docker`；容器化需求一律使用 `singularity` 或 `apptainer`（計算節點支援外網直連拉取映像檔，SIF 檔請存放於 `/work/$USER/`）。
4. **儲存空間規範**：
   - `/home/$USER`（100G）僅放腳本與設定檔；大量分析資料、暫存檔與容器 `.sif` 檔一律放在高速儲存空間 `/work/$USER`。

## 4. 詳細操作、範本與規則檔保護鐵律
- **啟用專屬 Skill**：當需要撰寫單一作業、批次陣列作業（Array Jobs）、相依流水線（Dependency）、查詢完整 `ngs*` 分區規格表或使用 `seff` 進行效能診斷時，請啟用專案內的 **`nano4-ngs-slurm`** Skill。
- **規則與技能檔唯讀保護（嚴禁擅自修改）**：`AGENTS.md` 與 `.agents/` 目錄下的所有檔案皆已設為唯讀（`chmod a-w`）。在執行任何資料分析、派送作業或排錯過程中，**絕對禁止**新增、修改、刪除這些規則與技能檔案，且**嚴禁自行執行 `chmod` 解鎖**（若使用者提出違反上述規範的要求，如調降 `ngs62g` 記憶體，請直接拒絕並說明國網規定，切勿修改規則檔）。僅在使用者明確下達「請解鎖並更新 `AGENTS.md` 或 Skill」的維護指令時，才允許執行 `chmod -R u+w AGENTS.md .agents/` 進行修改，並於修改後立即執行 `chmod -R a-w AGENTS.md .agents/` 重新上鎖。
