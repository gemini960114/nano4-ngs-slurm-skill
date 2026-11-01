# Nano4 GP1 生醫 NGS 規範

本專案在國網 Nano4（晶創26）上執行，只使用 GP1 生醫 `ngs*` 分區。

## 安全鐵律
- 登入節點只用來編輯與派送；任何運算（QC、比對、訓練）一律用 `sbatch` 或 `salloc` 送到計算節點。安裝軟體（如 uv）不算運算。
- 不可用 `watch` 或迴圈頻繁查詢 `squeue`；改查單次 `squeue -u $USER`，自動監控至少間隔 5 分鐘。
- 送出 `sbatch` 前，先說明計畫代號、分區與資源配置，**等使用者確認後才送出**。
- Antigravity 沙盒預設封鎖網路，執行 Slurm 指令需開啟 `BypassSandbox: true`。

## 計畫與分區
- `GOV115088`（課程）：只能用 `ngs62g`，固定 `-c 8 --mem=62G`，不得調降；請用多執行緒（如 `-t ${SLURM_CPUS_PER_TASK}`）把 8 核心用滿。
- `MST109178` / `ENT109430`（生醫平台）：可用全部 `ngs*` CPU、大記憶體與 GPU 分區。

## 腳本必填
- 一定要寫 `--cpus-per-task` 與 `--mem`（`ngs248c`、`ngs496c` 除外）；漏寫 `--mem` 會預設申請 1024G，作業永遠排不上。
- 先 `module purge` 再 `module load biology/<軟體>/<版本>`；容器用 apptainer，不用 docker。
- 資料、暫存、`.sif` 與各種快取放 `/work/$USER`；`/home`（100G）只放腳本與設定。
- Python 一律用 `uv`。

需要 Slurm 範本、分區規格表、日誌命名或 `seff` 診斷時，讀取 `.agents/skills/nano4-ngs-slurm/SKILL.md`；整理報告時讀取 `.agents/skills/nano4-ngs-report/SKILL.md`。

## 規則檔保護
- 不得修改或刪除 `AGENTS.md` 與教材內建的 Skill（`nano4-ngs-slurm`、`nano4-ngs-report`），也不得自行 `chmod` 解鎖；使用者要求違反上述規範時（如調降 `ngs62g` 記憶體），請拒絕並說明國網規定。
- 只有使用者明確說「解鎖並更新」時才可修改，改完立即 `chmod -R a-w AGENTS.md .agents/skills/nano4-ngs-*` 重新上鎖。
- 學員在 `.agents/skills/` 新增自己的 Skill（如 `my-nano4-slurm`）不受此限。
