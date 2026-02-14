# HARD TASK – Using mlr3hf::htsk()

This test demonstrates:
- Installing the mlr3hf package from GitHub
- Downloading a dataset from the Hugging Face Hub
- Converting it into an mlr3 Task
- Running classification and regression workflows
- Using only R (no Python, no reticulate)

---

## 1️⃣ Install Package from GitHub
```r
install.packages("remotes")
remotes::install_github("anjnainandan001/mlr3hf")

library(mlr3)
library(mlr3hf)
library(mlr3learners)
```

---

## Part A – Classification Example

We download the Iris dataset from Hugging Face.
```r
task_classif <- htsk(
  repo_id = "scikit-learn/iris",
  filename = "Iris.csv",
  target = "Species"
)
task_classif
```

Output:
```
<TaskClassif> (150x6) 
• Target: Species
• Target classes: Iris-setosa (33%), Iris-versicolor (33%), Iris-virginica (33%)
• Properties: multiclass
• Features (5):
  • dbl (5): Id, PetalLengthCm, PetalWidthCm, SepalLengthCm, SepalWidthCm
```

### Train Classification Model
```r
learner <- lrn("classif.rpart")
learner$train(task_classif)
```

### Make Predictions
```r
prediction_classif <- learner$predict(task_classif)
prediction_classif
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

### Compute Accuracy
```r
prediction_classif$score(msr("classif.acc"))
```

Output:
```
classif.acc
          1
```

This confirms:
- Dataset downloaded successfully
- TaskClassif created correctly
- Model trained successfully
- Predictions generated
- Accuracy computed

---

## Part B – Regression Example

Now we use a numeric target column from the same dataset.
```r
task_regr <- htsk(
  repo_id = "scikit-learn/iris",
  filename = "Iris.csv",
  target = "SepalLengthCm"
)
task_regr
```

Output:
```
<TaskRegr> (150x6)
• Target: SepalLengthCm
• Properties: -
• Features (5):
  • dbl (4): Id, PetalLengthCm, PetalWidthCm, SepalWidthCm
  • chr (1): Species
```

### Train Regression Model
```r
learner_regr <- lrn("regr.lm")
learner_regr$train(task_regr)
```

### Make Predictions
```r
prediction_regr <- learner_regr$predict(task_regr)
prediction_regr
```
Output:
```
<PredictionRegr> for 150 observations:
row_ids truth response
       1   5.1 5.007753
       2   4.9 4.757249
       3   4.7 4.774586
     ---   ---      ---
     148   6.5 6.318050
     149   6.2 6.587617
     150   5.9 6.299630
```

### Compute MSE
```r
prediction_regr$score(msr("regr.mse"))
```

Output:
```
regr.mse
0.09014607
```

---

## ✅ Conclusion

This test demonstrates that:
- The mlr3hf package can download datasets from Hugging Face
- It correctly detects classification vs regression
- It integrates fully with the mlr3 ecosystem
- Training, prediction, and evaluation work
- No Python or reticulate is used (pure R implementation)
