#!/bin/bash
# 自動化相依流水線串接範例 (Job Dependency Pipeline)
# 用法：bash workflow_dependency.sh [ACCOUNT]
set -euo pipefail

ACCOUNT="${1:-GOV115088}"

# 步驟 1：送出第一階段任務 (例如 FastQC 陣列作業)，--parsable 只回傳 Job ID
JOB1=$(sbatch --parsable --account="${ACCOUNT}" step1_fastqc_array.slurm)
echo "[Pipeline] 已提交階段 1 (FastQC Array): Job ID = ${JOB1}"

# 步驟 2：只有當 JOB1 所有子任務皆成功結束 (afterok) 時，才啟動階段 2 (例如 MultiQC 彙整)
JOB2=$(sbatch --parsable --dependency=afterok:"${JOB1}" --account="${ACCOUNT}" step2_multiqc.slurm)
echo "[Pipeline] 已提交階段 2 (MultiQC, 等待 ${JOB1} 完成): Job ID = ${JOB2}"

echo "[Pipeline] 單次檢查佇列狀態："
squeue -u "$(whoami)"
