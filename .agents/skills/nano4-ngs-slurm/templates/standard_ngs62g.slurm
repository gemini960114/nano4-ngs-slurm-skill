#!/bin/bash
#SBATCH --account=GOV115088
#SBATCH --job-name=ngs_cpu_job
#SBATCH --partition=ngs62g
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=62G
#SBATCH --time=01:00:00
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

set -euo pipefail

# 1. 確保計算節點已初始化 Lmod，再清理並載入環境模組
[ -z "$(type -t module)" ] && . /opt/ohpc/admin/lmod/lmod/init/bash
module purge
# 如需使用 FastQC / MultiQC 可取消註解以下行：
# module load biology/JDK/26.0.1
# module load biology/FastQC/0.11.9
# module load biology/MultiQC/1.35

echo "[INFO] Job ID: ${SLURM_JOB_ID}"
echo "[INFO] Node: $(hostname)"
echo "[INFO] CPUs: ${SLURM_CPUS_PER_TASK}"
echo "[INFO] Start Time: $(date '+%Y-%m-%d %H:%M:%S')"

# 2. 執行主要分析任務 (請開啟多執行緒以充分利用 8 核心)
# 例如：fastqc -t "${SLURM_CPUS_PER_TASK}" --outdir qc_out/ input.fastq.gz

echo "[INFO] End Time: $(date '+%Y-%m-%d %H:%M:%S')"
