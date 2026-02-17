<!-- badges: start -->
  [![R-CMD-check](https://github.com/anjaninandan001/mlr3hf/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/anjaninandan001/mlr3hf/actions/workflows/R-CMD-check.yaml)
  <!-- badges: end -->

# mlr3hf

**mlr3hf** is a lightweight R package that allows you to download tabular datasets from the Hugging Face Hub and convert them directly into `mlr3` Task objects.
## This package is currently a minimal prototype. Ongoing development focuses on improving scalability and ensuring controlled memory (RAM) usage.
It acts as a simple bridge between:
- 🤗 Hugging Face datasets  
- 📊 The `mlr3` machine learning framework in R  

---

## ✨ Why mlr3hf?

The Hugging Face Hub hosts thousands of publicly available datasets.

However, to use them in `mlr3`, you normally need to:
1. Download the dataset manually  
2. Load it into R  
3. Inspect the columns  
4. Create an `mlr3` Task yourself  

`mlr3hf` simplifies this entire process into a single function call.

---

## 🚀 Installation

Install from GitHub:
```r
devtools::install_github("anjaninandan001/mlr3hf")
library(mlr3hf)
```
---

## 🛠️ Development

For developers working on the package:
```r
# Load all package functions for development
devtools::load_all()

# Run package tests
devtools::test()
```

---

## 📦 Main Function: htsk()
```r
htsk(repo_id, filename, target)
```

### Arguments

- `repo_id` — Hugging Face dataset repository ID
- `filename` — File inside the dataset repository
- `target` — Name of the target column

The function:
- Downloads the dataset from Hugging Face
- Loads it into R
- Detects the target column type
- Creates either:
  - `TaskClassif` (for classification)
  - `TaskRegr` (for regression)

---

## 📊 Example: Classification
```r
library(mlr3hf)
library(mlr3)

task <- htsk(
  repo_id = "scikit-learn/iris",
  filename = "Iris.csv",
  target = "Species"
)

task
```

Output:
```
<TaskClassif>
```

You can now train a model:
```r
learner <- lrn("classif.rpart")
learner$train(task)
```

---

## 📈 Example: Regression

If the target column is numeric, a regression task is created automatically.
```r
task <- htsk(
  repo_id = "scikit-learn/iris",
  filename = "Iris.csv",
  target = "SepalLengthCm"
)

task
```

Output:
```
<TaskRegr>
```

---

## ⚠️ Current Limitations

- Supports tabular datasets only (CSV, JSON, Parquet, RDS)
- Requires explicit target column
- Does not support image datasets
- Does not use the Hugging Face Python datasets library
- No automatic train/test split handling yet

---

## 🧠 Design Philosophy

- Pure R implementation
- No Python
- No reticulate
- Minimal dependencies
- Simple and explicit behavior

---

## 📁 Project Structure
```
R/           → Core implementation  
tests/       → Unit tests  
vignettes/   → Usage guide  
man/         → Function documentation  
```

---

## 📜 License

MIT License

---

## 🙌 Contribution

This is a minimal prototype package demonstrating how Hugging Face datasets can be integrated into the mlr3 ecosystem.

Future improvements may include:
- Split handling
- Metadata inference
- Better error diagnostics
