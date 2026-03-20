
# 1. Listing OpenML Data
 ```r
 dt = list_oml_data(limit = 5)
 dt
```
output: 
```
    data_id            name version status MajorityClassSize
      <int>          <char>   <int> <char>             <int>
 1:       2          anneal       1 active               684
 2:       3        kr-vs-kp       1 active              1669
 3:       4           labor       1 active                37
 4:       5      arrhythmia       1 active               245
 5:       6          letter       1 active               813
```

## Understanding
```
Its only fetch the metadata(JSON) using api.
NO dataset is download (in .cache or tmp).
It is just a openml dataset catalogue.
```
### Same behavior shown by list_oml_tasks() 

# 2. list_oml_tasks() 
I am using the data anneal from the list.
```r
> list_oml_tasks(data_id="2",limt=5)
```
output:
```r
INFO  [18:03:35.994] Retrieving JSON {url: `https://www.openml.org/api/v1/json/task/list/data_id/2/limit/1000`, authenticated: `FALSE`}
    task_id                             task_type data_id   name status
      <int>                                <char>   <int> <char> <char>
 1:       2             Supervised Classification       2 anneal active
 2:      62                        Learning Curve       2 anneal active
 3:     232             Supervised Classification       2 anneal active
 4:    1701                        Learning Curve       2 anneal active
 5:    1766             Supervised Classification       2 anneal active
```
for sturying i am taking task_id= 232
### we can directly list the task also.


# 3. Creating OMLTask( supervised classification)
 ```r
 dt=otsk(232) or task=OMLTask$new(232)
 dt #task is the object of OMLTask
```
output:
```r
INFO  [18:27:13.553] Retrieving JSON {url: `https://www.openml.org/api/v1/json/task/232`, authenticated: `FALSE`}
INFO  [18:27:15.124] Retrieving JSON {url: `https://www.openml.org/api/v1/json/data/qualities/2`, authenticated: `FALSE`}
INFO  [18:27:15.539] Retrieving JSON {url: `https://www.openml.org/api/v1/json/data/features/2`, authenticated: `FALSE`}
INFO  [18:27:15.924] Retrieving JSON {url: `https://www.openml.org/api/v1/json/data/2`, authenticated: `FALSE`}
<OMLTask:232>
 * Type: Supervised Classification
 * Data: anneal (id: 2; dim: 898x39)
 * Target: class
 * Estimation: holdout (id: 6; test size: 33%)
```

### Understanding
```
Full dataset is not download yet it fetch the metadata only.
Only metadata in qs2 format is download in the tmp or .cache depends on `mlr3oml.cache=TRUE/FALSE`
At first time when object(dt) is created meta data is fetched into ram and then it will stored into disk as .qs2. and later it will use from RAM or cached will fetch into ram from the disk `qs_read'.
```

# 4. Active Binding (lazy access)

```r
> dt$data_name
[1] "anneal"
> dt$target_names
[1] "class"
> dt$nrow
[1] 898
```
# 5. Resampling
```r
resampling=as_resampling(dt)
resampling
```

output:
```r
── <ResamplingCustom> : Custom Splits ──────────────────────────────────────────────────────────────────────────────────
• Iterations: 1
• Instantiated: TRUE
• Parameters: list()
```
### Understanding 
Input: OMLTask
Output: ResamplingCustom

# 6. ML Pipeline
```r
> learner = lrn("classif.rpart")
> task=as_task(dt)
> rr = resample(task, learner, resampling)
INFO  [22:33:38.893] [mlr3] Applying learner 'classif.rpart' on task 'anneal' (iter 1/1)
> rr
```
output: 
```
── <ResampleResult> with 1 resampling iterations ───────────────────────────────────────────────────────────────────────
 task_id    learner_id resampling_id iteration     prediction_test warnings
  anneal classif.rpart        custom         1 <PredictionClassif>        0
 errors
      0
```
```r
> rr$aggregate(msr("classif.acc"))
```
output:
```
classif.acc
  0.8851351
```
### Understanding
```
as_task() → converts to mlr3 TaskClassif
resample() → training + prediction
aggregate() → accuracy
```
# 7.S3 Method
`as_resampling.OMLTask()`
```
`as_resampling()` is a generic function from mlr3. When we pass an `OMLTask` object to it, R first checks the class of the object. Since the object is of class `OMLTask`, it automatically calls the method `as_resampling.OMLTask()`. This method creates a custom resampling based on the OpenML task splits. This behavior is part of R’s S3 method system, where the function used depends on the class of the input.
 Takes default target if user not specify.
```
# 8. When Data Actually Downloads
```
`as_task(dt)` or `dt$data$data` # When this is called
```
# 9. ARFF Flow 
```
API
 ↓
/tmp/file.arff
 ↓
read_arff()
 ↓
RAM (data.table)
 ↓
(optional) qs2
```
Proof:
```
path = tempfile(fileext = ".arff")
download_file(url, path)
tab = read_arff(path)
```
# 10. Parquet Flow
```
API
 ↓
disk (tmp or cache)
 ↓
DuckDB (parquet_scan)
 ↓
DataBackendDuckDB
 ↓
(on demand) RAM
```
## ARFF do the eager loading and Parquet do the lazy loading. ARFF have high ram usage not good for large dataset.

# 11. Backend Understanding
```
# for arff
data.table → DataBackendDataTable
```

```
# for parquet
```

# 12. Code Understanding
### Files studied:
```
utils.R
OMLObject.R
OMLData.R
download_parquet.R
download_arff.R
cache.R
```
### Key Functions

```
.get_backend() → decide backend
as_duckdb_backend_character() → parquet handling
cached() → cache logic
as_task() → mlr3 conversion
as_resampling() → splits
```
# for 2nd classification 
I am taking the task_id(236)
```r
library(mlr3)
library(mlr3oml)
library(mlr3learners)
options(mlroml.cache=TRUE)
dt=OMLTask$new(236)
dt
```
output:
```
INFO  [09:17:35.676] Retrieving JSON {url: `https://www.openml.org/api/v1/json/task/236`, authenticated: `FALSE`}
INFO  [09:17:36.544] Retrieving JSON {url: `https://www.openml.org/api/v1/json/data/qualities/6`, authenticated: `FALSE`}
INFO  [09:17:36.989] Retrieving JSON {url: `https://www.openml.org/api/v1/json/data/features/6`, authenticated: `FALSE`}
INFO  [09:17:37.449] Retrieving JSON {url: `https://www.openml.org/api/v1/json/data/6`, authenticated: `FALSE`}
<OMLTask:236>
 * Type: Supervised Classification
 * Data: letter (id: 6; dim: 20000x17)
 * Target: class
 * Estimation: holdout (id: 6; test size: 33%)
```
```r
task=as_task(dt)
task
```
output:
```
── <TaskClassif> (20000x17) ────────────────────────────────────────────────────────────────────────────────────────────
• Target: class
• Target classes: U (4%), D (4%), P (4%), T (4%), M (4%), A (4%), X (4%), Y (4%), N (4%), Q (4%) + 16 more
• Properties: multiclass
• Features (16):
  • int (16): high, onpix, width, x.bar, x.box, x.ege, x2bar, x2ybr, xegvy, xy2br, xybar, y.bar, y.box, y.ege, y2bar,
  yegvx
```

```r
> resampling=as_resampling(dt)
> resampling
```
output:
```
INFO  [09:18:38.352] Retrieving ARFF {url: `https://openml.org/api_splits/get/236/Task_236_splits.arff`, authenticated: `FALSE`}
── <ResamplingCustom> : Custom Splits ──────────────────────────────────────────────────────────────────────────────────
• Iterations: 1
• Instantiated: TRUE
• Parameters: list()
```
```r
learner = lrn("classif.rpart")
rr = resample(task, learner, resampling)
rr$aggregate(msr("classif.acc"))
```
output:
```
INFO  [09:19:31.297] [mlr3] Applying learner 'classif.rpart' on task 'letter' (iter 1/1)
  0.4683333
```
