# Veri2: A Formally Verified RTL–SVA Dataset for Fine-Tuning Local Language Models

## Overview

Veri2 is a synthetic RTL–SVA dataset distilled from GPT-5 and filtered by a two-stage Cadence JasperGold pipeline (syntax check, then formal proof). It asks one question: does formally verified training data beat larger but noisier data for SystemVerilog Assertion (SVA) generation?

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/tiers-dark.svg">
  <img alt="dataset tiers: all 45,451 SVAs, syntax pass 42,125, verified 18,494; formal yield 50.2% for the fine-tuned 7B model vs 41.4% for GPT-5" src="docs/tiers-light.svg">
</picture>

**Result:** Qwen2.5-Coder-7B-Instruct fine-tuned with QLoRA on the smallest, fully verified tier reaches **50.2% formal yield**, ahead of the GPT-5 teacher (**41.4%**) and of adapters trained on the larger *All* and *Syntax Pass* tiers. Data quality beats data quantity here.

This repository contains:

* the three Veri2 dataset tiers (`veri2/`)
* GPT-5 batch generation scripts (`generation/`)
* QLoRA fine-tuning and inference notebooks (`fine_tuning/`)
* JasperGold checking and analysis scripts (`scripts/`)
* raw model outputs for every evaluated model (`inference_outputs/`)

---

## Dataset Creation Pipeline

![Veri2 Dataset Creation Pipeline](veri2_pipeline.png)

## Fine-Tuning Pipeline

![Veri2 Fine-Tuning Pipeline](veri2_finetuning.png)

---

## Repository Structure

```text
.
├── fine_tuning/
├── generation/
├── inference_outputs/
├── scripts/
├── veri2/
├── veri2_finetuning
└── veri2_pipeline
```

### `fine_tuning/`

Contains all code required for training and inference of QLoRA adapters.

Includes:

* Dataset preprocessing
* Training scripts
* QLoRA configuration
* Inference scripts
* Evaluation utilities

Adapters are trained on Qwen2.5-Coder-7B-Instruct using the dataset variants described below.

---

### `generation/`

Contains the GPT-5 generation infrastructure used to create synthetic SVA data.

Includes:

* OpenAI Batch API request creation
* JSONL generation
* Batch submission scripts
* Result retrieval
* Output post-processing

These scripts were used to generate assertions from RTL modules prior to verification filtering.

---

### `inference_outputs/`

Contains inference outputs for all evaluated models.

Examples include:

* Base Qwen
* GPT-5 Baseline
* Adapter (All)
* Adapter (Syntax Pass)
* Adapter (Verified)
* Adapter (VERT)

These outputs are used for downstream JasperGold evaluation.

---

### `scripts/`

Utility scripts used throughout the project.

Examples include:

* Dataset cleaning
* Statistics collection
* Data conversion
* Evaluation helpers
* Experiment automation

---

### `veri2/`

Contains the Veri2 dataset.

The dataset is organized into three quality tiers:

| Tier        | Description                                            |
| ----------- | ------------------------------------------------------ |
| All         | All GPT-5 generated RTL–SVA pairs                      |
| Syntax Pass | Only pairs passing JasperGold syntax validation        |
| Verified    | Only pairs passing both syntax and formal verification |

Dataset statistics:

| Tier        | Modules | Assertions |
| ----------- | ------- | ---------- |
| All         | 5,774   | 45,451     |
| Syntax Pass | 5,412   | 42,125     |
| Verified    | 2,954   | 18,494     |

---

## Dataset Construction

Veri2 is created using the following workflow:

1. Select verified RTL modules from VeriThoughts.
2. Generate assertions using GPT-5.
3. Run JasperGold syntax validation.
4. Run JasperGold formal verification.
5. Retain passing assertions for the verified dataset tier.

This process produces progressively higher-quality subsets that can be used to study the effect of training data quality on downstream SVA generation.

---

## Fine-Tuning

All adapters were trained using QLoRA on Qwen2.5-Coder-7B-Instruct.

### Key Hyperparameters

| Parameter            | Value |
| -------------------- | ----- |
| LoRA Rank            | 64    |
| LoRA Alpha           | 128   |
| Epochs               | 3     |
| Effective Batch Size | 16    |
| Learning Rate        | 2e-4  |
| Max Sequence Length  | 8192  |

---

## Evaluation

Models are evaluated using a multi-stage verification pipeline:

1. Assertion generation
2. Syntax validation
3. RTL elaboration / binding
4. Formal verification

### Primary Metric

**Yield** = Percentage of generated assertions that are formally proven by JasperGold.

The strongest-performing adapter is trained on the **Verified** dataset tier and achieves higher assertion yield than both the GPT-5 teacher model and models trained on larger, lower-quality datasets.

---

## Reproducibility

1. **Train:** run `fine_tuning/sva_qlora_finetune.ipynb` on a tier from `veri2/` (`all`, `syntax_pass` or `verified`; each has `train` / `validation` / `test` JSONL splits).
2. **Generate:** run `fine_tuning/sva_inference.ipynb` to write one `sva.sv` per test module, laid out like `inference_outputs/<model>/<id>/`.
3. **Check:** `scripts/check_all.sh` runs the JasperGold syntax and formal checks (`jasper_syntax_check.tcl`, `jasper_verif_check.tcl`); `scripts/run_check_all.sbatch` does the same on a Slurm cluster. JasperGold needs a Cadence license.

---

## Paper

We're planning to submit the paper to arXiv. A link and citation will go here once it's posted.

## License

To be decided when the paper is posted.
