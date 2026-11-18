#!/bin/bash -l
#SBATCH --job-name=quality-checks
#SBATCH --output=quality-checks.%A_%a.out
#SBATCH --error=quality-checks.%A_%a.err
#SBATCH --time=02:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
set -euo pipefail
cd "${SLURM_SUBMIT_DIR:?Submit from the repository/package root}"
# Make JasperGold 2021.03 available here, for example:
#   module load <your JasperGold module>
#   export PATH="$PATH:<JasperGold installation>/bin"
command -v jg
jg -version
python3 evaluation/run_quality_checks.py run --package "${1:?Supply the prepared package directory}" \
    --shard "${SLURM_ARRAY_TASK_ID:-0}" --shards "${2:-1}"
