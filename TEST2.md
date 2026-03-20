# My Work on mlr3hf 

For this hard task, I first studied the mlr3oml package in depth. After understanding its internal working (especially caching, backend handling, and lazy loading), I designed a similar package called mlr3hf.

This is currently an MVP (Minimum Viable Product), and I plan to extend it with more features later.

## What I Have Built So Far

I have implemented and tested the following core modules:
```
cache.R
utils.R
HFObject.R
HFData.R
download_parquet.R
sugar.R
```

# Core Idea of My Package
The user provides:
```
dataset
config
target
cache option
```

## Internally:
Data fetching
Backend creation
Split handling 
are managed automatically.

The user can also access split data for training, as I have inserted split logic inside the backend.
Data Handling Design

By default → data is downloaded to /tmp

If caching is enabled → data is stored in:
~/.cache/R/mlr3hf
## Data Source (MVP)
I am using Hugging Face dataset API:
```
https://huggingface.co/api/datasets/{dataset}/parquet
```
this mvp is currently almost every dataset which is less than 5GB and letter i will make functional even for larger dataset .
why 5 gb? according to HF documentation this parquet url can give some time partial dataset for larger than 5 gb. later i will add partial function in backend that user can know the download data is full or not.

Backend Design

I use `DuckDB` + `parquet_scan()`

This enables lazy loading
```
Only required data is loaded into RAM (not full dataset)
No Metadata Approach
```

In this MVP:

I am not using metadata

Data is downloaded only when $data  or $as_task() is called
yet data is active binding and as_task is public function in the `HFData.R` i am working to make S3. i.e `as_task.HFData`
### and downoad happen in cache or tmp as per user choice.
This ensures:
simplicity
lazy execution

Lazy Data Function
```
data = function(rhs) {

  if (!missing(rhs)) {
    stop("data is read-only", call. = FALSE)
  }

  backend <- private$.get_backend()

  n <- min(10L, backend$nrow)

  data <- backend$data(
    rows = seq_len(n),
    cols = backend$colnames
  )

  drop_cols <- intersect(private$.hidden_cols, colnames(data))

  data[, !drop_cols, with = FALSE]
}
If data is larger for example we are loading ibm/duorc config: ParaphraseRC so to protect ram we are loading only few row , 
although user can use head but implemented in the code.
```

```
Only first 10 rows fetched → lazy preview
Hidden columns (like primary key, split) removed for clarity
hidden columns i use this internally so i can later extend and add some `as_resample`(custom)
```
```
options(mlr3hf.cache = TRUE)

dtt = HFData$new(
  dataset = "scikit-learn/iris",
  config = "default",
  target = "Species"
) # or
dtt=htsk( dataset = "scikit-learn/iris",
  config = "default",
  target = "Species"
) #htsk is in sugar.R
```

Output:

```
Cache initialized at: ~/.cache/R/mlr3hf
```
##Data Access
```r
dtt$data
```

Output :
```
Downloading: https://huggingface.co/api/datasets/scikit-learn/iris/parquet/default/train/0.parquet
Saved: /home/anjani/.cache/R/mlr3hf/scikit-learn/iris/default/train/0.parquet
Initializing DuckDB backend...
       Id SepalLengthCm SepalWidthCm PetalLengthCm PetalWidthCm     Species
    <num>         <num>        <num>         <num>        <num>      <fctr>
 1:     1           5.1          3.5           1.4          0.2 Iris-setosa
 2:     2           4.9          3.0           1.4          0.2 Iris-setosa
 3:     3           4.7          3.2           1.3          0.2 Iris-setosa
 4:     4           4.6          3.1           1.5          0.2 Iris-setosa
 5:     5           5.0          3.6           1.4          0.2 Iris-setosa
 6:     6           5.4          3.9           1.7          0.4 Iris-setosa
 7:     7           4.6          3.4           1.4          0.3 Iris-setosa
 8:     8           5.0          3.4           1.5          0.2 Iris-setosa
 9:     9           4.4          2.9           1.4          0.2 Iris-setosa
10:    10           4.9          3.1           1.5          0.1 Iris-setosa
```

> parquet downloaded

> DuckDB backend initialized

> only partial data loaded

## Column Info
```r
dtt$colnames
```
output:
```
dtt$target_names
🔹 Convert to mlr3 Task
task = dtt$as_task()

Output:
```
[1] "Id"            "SepalLengthCm" "SepalWidthCm"  "PetalLengthCm"
[5] "PetalWidthCm"  "Species"
> dtt$target_names
[1] "Species"
```

```r
task=dtt$as_task()
task
```
output:
```

── <TaskClassif> (150x6) ───────────────────────────────────────────────────────────────────────────────────────────────
• Target: Species
• Target classes: Iris-setosa (33%), Iris-versicolor (33%), Iris-virginica (33%)
• Properties: multiclass
• Features (5):
  • dbl (5): Id, PetalLengthCm, PetalWidthCm, SepalLengthCm, SepalWidthCm
```
```r
class(task)
```
output:
```
[1] "TaskClassif"    "TaskSupervised" "Task"           "R6"
```
```r

library(mlr3learners)
learner <- lrn("classif.rpart")
learner$train(task)
prediction_classif <- learner$predict(task)
prediction_classif
```
```
── <PredictionClassif> for 150 observations: ───────────────────────────────────────────────────────────────────────────
 row_ids          truth       response
       1    Iris-setosa    Iris-setosa
       2    Iris-setosa    Iris-setosa
       3    Iris-setosa    Iris-setosa
     ---            ---            ---
     148 Iris-virginica Iris-virginica
     149 Iris-virginica Iris-virginica
     150 Iris-virginica Iris-virginica
```


```r
prediction_classif$score(msr("classif.acc"))
```
output:
```
classif.acc
          1
```


