# Codebook : Tidying the Samsung Galaxy S accelerometer dataset




##Synopsis
This code book describes the data processing done on the Samsung Galaxy S accelerometer [dataset](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip), in line with the requirements of the course project for the [Getting and Cleaning Data](https://class.coursera.org/getdata-015/human_grading/view/courses/973502/assessments/3/submissions) course within the Coursera Data Science specialisation. 


## Study Design
The data used was collected by sensors on a number of Samsung Galaxy S phones. A set of 30
subjects where tracked that each performed a number of activities. More information on the raw data set can be found [here](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones). The raw data consists of a training and test data set that contain
the sensor data, a set of labels that indicate the activity for each record in the test
and training data sets, a set of variable names, and a set of activity names. These
components were all stored in separate `.txt` files. 

The purpose of our data processing is to merge the training
and test data sets, while supplementing them with the data on subjects and activities.
In doing so, we have renamed the variable names in the data set to make them descriptive
and to increase readability. This is done in an automated way through the use of
regular expressions. We have also replaced the activity labels with their respective description.

Finally, we computed for each subject and activity the mean of a set of selected metrics
that relate to standard deviation and mean of individual sensor measurements. The set
of selected metrics is the one identified with variables in the raw data set that 
include `mean()` or `std()` in their name.

The result is saved to disk in a file called "tidy_samsung.txt" which is created
by a call to write.table with all default arguments. 

All variables are normalised to [-1,1] and unitless. 

## Code book
The variables in the raw data set have been transformed to ease their interpretation.
We decided against the use of long variable names to keep their length manageable. In particular
we have not added a variable name component indicating that the variables are all means, i.e.
summarised per subject and activity, and computed from their respective variables in the 
raw data. 

Given the large number of variables, and the fact that they are all normalised and unitless
we do not list each variable here, rather we provide an explanation for each component that
makes up a variable's name: 

- **t** or **f** : Indicates whether the variable pertains to time domain data (**t**) or 
frequency domain data (**f**). Refer to the README.txt file in the original data set
for more info on the computation of both types of measurements. 
- **body** : Indicates the variable relates to a body motion component 
- **gravity** : Indicates the variable relates to a gravitational motion component 
- **acc** : Indicates the variable relates to acceleration, derived from the accelerometer signals.
- **gyro** : Indicates the variable relates to 3-axial signals derived from the gyroscope.  
- **jerk** : Indicates the variable relates to a jerk signal, derived from body 
linear acceleration and angular velocity in the original data set.
- **mag** : Indicates the variable relates to the magnitude of a signal.
- **mean** : Indicates the variable refers to the mean value.
- **meanfreq** : Indicates the variable refers to the mean frequency value.
- **std** : Indicates the variable refers to the standard deviation.
- **x/y/z** : Refers to the x/y/z-axis components of the metric respectively. 

A number of atomic variables are included in the data set : 

- **activity** : The activity performed by the subject one of (`WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING`)
- **subject** : The ID of the subject that generated the sensor data. 

## Data Processing

### Renaming the variables
The following function was used to rename the variables in the data set.

```r
deriveNames <- function() {
    #Load feature names
    features <- read.table(paste0(basePath, "features.txt"), stringsAsFactors = FALSE, col.names = c("index", "name"))
    
    #Fetch the mean and deviation related names
    selection <- features[grep("mean()|std()", features$name),]
    
    #Reformat names to proper descriptive column names
    
    #Remove parenthesis, replace dash by point and set lowercase
    selection$names <- gsub("[()]", "",gsub("-", ".", tolower(selection$name)))
    
    #Add point after metric components, remove any double points generated
    selection$names <- make.names(gsub("\\.\\.", ".", gsub("(body|gravity|acc|gyro)", "\\1.", selection$names)))
    selection
}
```

The variable `basePath` is set globally in the `run_Analysis.R` script that produces the tidy data set.

### Loading and merging the raw training and test data, activity and subject labels
The following function reads the raw training (`"training"`), or test (`"test"`) data depending on the argument value.


```r
loadData <- function(type) {
  #Load sensor data
  df <-  read.table(paste0(basePath, type, "/X_", type, ".txt"), nrows = max)
  names <- deriveNames()
  
  #Select only columns part of the set of derived names (i.e. mean and std related ones)
  df <- df[,names$index]
  colnames(df) <- names$names
  
  #Add subject info
  subjects <- read.table(paste0(basePath, type, "/subject_", type, ".txt"),  
                       nrows = max, col.names = c("subject_id"))
  df$subject <- subjects$subject_id
  
  #Add activity info
  activityLabels <- read.table(paste0(basePath, "activity_labels.txt"), 
                               col.names = c("activity_num", "activity"))
  activity <- read.table(paste0(basePath, type, "/y_", type, ".txt"),  nrows = max, 
                         col.names = c("activity"))
  df$activity <- activityLabels[activity$activity,2]
  
  #Reorder columns
  df %>% select(activity, subject, 1:(ncol(df)-2))
}
```

### Computing the summaries for the tidy data set
The tidy data set computes the mean value of the respective variables in the raw data.
The following code builds the final data set:

```r
createTidyDataSet <- function() {
  #Read all training, testing, subject and activity data
  all <- readFullDataSet()
  
  #Group by activity and subject and summarise with mean
  result <- all %>% group_by(activity, subject) %>% summarise_each(funs(mean))
  
  #Write out to disk
  write.table(result, file = "tidy_samsung.txt", row.name=FALSE)
  
  all
}
```

### Instruction list
Invoke the creation of the tidy data set by running `run_analysis.R`. The script
requires the `dplyr` package to be available. The raw data is automatically downloaded if it is not detected to be present on the executing system. 

The script was tested on a system with the following `sessionInfo()` output:

```r
sessionInfo()
```

```
## R version 3.2.0 (2015-04-16)
## Platform: x86_64-apple-darwin13.4.0 (64-bit)
## Running under: OS X 10.10.3 (Yosemite)
## 
## locale:
## [1] C
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] dplyr_0.4.1   ggplot2_1.0.1
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.11.6      assertthat_0.1   digest_0.6.8     MASS_7.3-40     
##  [5] grid_3.2.0       plyr_1.8.2       DBI_0.3.1        gtable_0.1.2    
##  [9] formatR_1.2      magrittr_1.5     scales_0.2.4     evaluate_0.7    
## [13] stringi_0.4-1    reshape2_1.4.1   rmarkdown_0.6.1  proto_0.3-10    
## [17] tools_3.2.0      stringr_1.0.0    munsell_0.4.2    parallel_3.2.0  
## [21] yaml_2.1.13      colorspace_1.2-6 htmltools_0.2.6  knitr_1.10.5
```

To read the tidy data one can use:

```r
tidy <- read.table("tidy_samsung.txt", header = TRUE)
```
