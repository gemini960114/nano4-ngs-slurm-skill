#!/bin/bash
#SBATCH --account=GOV115088
#SBATCH --job-name=first-gc
#SBATCH --partition=ngs62g
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=62G
#SBATCH --time=00:10:00
#SBATCH --output=tutorial/case00/%x-%j.out
#SBATCH --error=tutorial/case00/%x-%j.err

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
