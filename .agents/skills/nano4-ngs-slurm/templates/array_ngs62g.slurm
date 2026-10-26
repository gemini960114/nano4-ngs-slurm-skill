#!/bin/bash
#SBATCH --account=GOV115088
#SBATCH --job-name=array_fastq
#SBATCH --partition=ngs62g
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=62G
#SBATCH --time=01:00:00
#SBATCH --array=1-4%4
#SBATCH --output=%x-%A_%a.out
#SBATCH --error=%x-%A_%a.err

set -euo pipefail

[ -z "$(type -t module)" ] && . /opt/ohpc/admin/lmod/lmod/init/bash
module purge
# module load biology/JDK/26.0.1
# module load biology/FastQC/0.11.9

# 1. 取得當前子任務對應的樣本檔案 (Bash 陣列從 0 開始，故減 1)
FASTQ_DIR="${1:-./fastq_raw}"
shopt -s nullglob
FASTQ_FILES=("${FASTQ_DIR}"/*.fastq.gz)
if [ "${#FASTQ_FILES[@]}" -eq 0 ]; then
    echo "[ERROR] 在 ${FASTQ_DIR} 中找不到任何 .fastq.gz 檔案" >&2
    exit 1
fi
FASTQ="${FASTQ_FILES[$((SLURM_ARRAY_TASK_ID - 1))]}"

# 2. 計算 Read 數或執行單樣本分析
READS=$(( $(gzip -dc "${FASTQ}" | wc -l) / 4 ))
echo "子任務 ${SLURM_ARRAY_TASK_ID} | 節點 $(hostname) | 樣本 $(basename "${FASTQ}") | reads = ${READS}"
