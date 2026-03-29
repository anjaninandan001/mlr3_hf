

# mlr3hf


```r
source("R/sugar.R")
source("R/cache.R")
source("R/download_parquet.R")
source("R/HFObject.R")
source("R/HFData.R")
librar(mlr3)
```
## Now it can make task

```r
dt=htsk(dataset=scikit-learn/iris", config="default", target="Species")
task=as_task(dt)
task
```
Output:
```
Loading required namespace: DBI
Downloading: https://huggingface.co/api/datasets/scikit-learn/iris/parquet/default/train/0.parquet
Saved: /tmp/Rtmp9sv6IH/scikit-learn/iris/default/train/0.parquet
Initializing DuckDB backend...
Loading required namespace: duckdb
Loading required namespace: mlr3db
── <TaskClassif> (150x6) ───────────────────────────────────────────────────────────────────────────────────────────────
• Target: Species
• Target classes: Iris-setosa (33%), Iris-versicolor (33%), Iris-virginica (33%)
• Properties: multiclass
• Features (5):
  • dbl (5): Id, PetalLengthCm, PetalWidthCm, SepalLengthCm, SepalWidthCm
```
