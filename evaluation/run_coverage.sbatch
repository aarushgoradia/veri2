#!/bin/bash -l
#SBATCH --job-name=veri2-cover
#SBATCH --output=veri2-cover.%A_%a.out
#SBATCH --error=veri2-cover.%A_%a.err
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
set -euo pipefail
cd "${SLURM_SUBMIT_DIR:?Submit from package root}"
# Make JasperGold 2021.03 available here, for example:
#   module load <your JasperGold module>
#   export PATH="$PATH:<JasperGold installation>/bin"
package="${1:?Supply coverage package}"
mode="${2:-coi}"
selection=()
if [[ "${3:-full}" == pilot ]]; then
    selection=(--pilot)
fi
python3 evaluation/run_coverage.py run --package "$package" --mode "$mode" \
    --shard "${SLURM_ARRAY_TASK_ID:-0}" --shards "${SLURM_ARRAY_TASK_COUNT:-1}" "${selection[@]}"
if [[ -z "${SLURM_ARRAY_TASK_ID:-}" ]]; then
    python3 evaluation/run_coverage.py summarize --package "$package" --mode "$mode" "${selection[@]}"
fi
