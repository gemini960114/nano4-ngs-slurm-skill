#!/bin/bash
#SBATCH --account=GOV115088
#SBATCH --job-name=apptainer_multiqc
#SBATCH --partition=ngs62g
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=62G
#SBATCH --time=00:30:00
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

set -euo pipefail

# 不載入任何軟體模組，完全依賴 Apptainer / Singularity 容器執行
[ -z "$(type -t module)" ] && . /opt/ohpc/admin/lmod/lmod/init/bash
module purge

LAB_DIR="/work/${USER}/apptainer_lab"
SIF_PATH="${LAB_DIR}/multiqc_1.35.sif"
INPUT_DIR="${1:-./fastqc_out}"
OUT_DIR="${LAB_DIR}/multiqc_out"

mkdir -p "${LAB_DIR}" "${OUT_DIR}"

# 1. 若映像檔尚未下載，直接於計算節點從 Docker Hub 拉取
if [ ! -f "${SIF_PATH}" ]; then
    echo "[INFO] 正在拉取映像檔 docker://multiqc/multiqc:v1.35 ..."
    apptainer pull "${SIF_PATH}" docker://multiqc/multiqc:v1.35
fi

# 2. 掛載高速目錄並在容器內執行 MultiQC
echo "[INFO] 容器內版本：$(apptainer exec "${SIF_PATH}" multiqc --version)"
apptainer exec -B "/work/${USER}:/work/${USER}" "${SIF_PATH}" \
    multiqc "${INPUT_DIR}" -o "${OUT_DIR}" --force

echo "[INFO] 報告已產出至：${OUT_DIR}/multiqc_report.html"
