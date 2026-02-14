# EASY TASK – Using mlr3oml::otsk()

This test demonstrates downloading classification datasets from OpenML
and running a complete mlr3 workflow.

---

## Dataset 1 – Iris (OpenML)
```r
library(mlr3)
library(mlr3oml)
library(mlr3learners)

# Download classification task from OpenML
task <- otsk(59)
task
```

Output:
```
<OMLTask:59>
 * Type: Supervised Classification
 * Data: iris (id: 61; dim: 150x5)
 * Target: class
 * Estimation: crossvalidation (id: 1; repeats: 1, folds: 10)

```

## Train a Model
```r
learner <- lrn("classif.rpart")
learner$train(task)
```

## Make Predictions
```r
prediction <- learner$predict(task)
prediction
```

Output:
```
<PredictionClassif> for 150 observations:
row_ids          truth       response
       1    Iris-setosa    Iris-setosa
       2    Iris-setosa    Iris-setosa
       3    Iris-setosa    Iris-setosa
     ---            ---            ---
     148 Iris-virginica Iris-virginica
     149 Iris-virginica Iris-virginica
     150 Iris-virginica Iris-virginica
```

## Evaluate Accuracy
```r
prediction$score(msr("classif.acc"))
```

Output:
```
classif.acc
       0.96
```

---
## Dataset 2 – Diabetes (OpenML)
```
# Download classification task from OpenML
task2 <- otsk(37)
task2
```
Output:
```
<OMLTask:37>
 * Type: Supervised Classification
 * Data: diabetes (id: 37; dim: 768x9)
 * Target: class
 * Estimation: crossvalidation (id: 1; repeats: 1, folds: 10)
```
## Evaluate Using Holdout Split
```

learner2 <- lrn("classif.rpart")

resampling2 <- rsmp("holdout")

rr2 <- resample(task2, learner2, resampling2)

rr2$aggregate(msr("classif.acc"))

```
Output:
```
classif.acc
  0.7421875
```

This confirms:
* Two classification datasets successfully downloaded using `otsk()`
* Both tasks converted into `mlr3` Task objects
* Models trained successfully
* Predictions generated
* Accuracy computed
* Resampling used for proper evaluation
