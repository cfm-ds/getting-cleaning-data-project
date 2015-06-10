## README 

###Purpose
This repository contains the solution to the course project for the for the [Getting and Cleaning Data](https://class.coursera.org/getdata-015/human_grading/view/courses/973502/assessments/3/submissions) course within the Coursera Data Science specialisation. The assignment involves data processing on the Samsung Galaxy S accelerometer [dataset](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip).

The purpose of our data processing is to merge the training and test data sets, while supplementing them with the data on subjects and activities.
In doing so, we have renamed the variable names in the data set to make them descriptive
and to increase readability. This is done in an automated way through the use of
regular expressions. We have also replaced the activity labels with their respective description.

Finally, we computed for each subject and activity the mean of a set of selected metrics
that relate to standard deviation and mean of individual sensor measurements. The set
of selected metrics is the one identified with variables in the raw data set that 
include `mean()` or `std()` in their name.

The result is saved to disk in a file called `tidy_samsung.txt` which is created
by a call to write.table with all default arguments. 

### Repository contents
The repository contains a generated tidy version of the data set (`"tidy_samsung.txt"`), a cookbook (`"CodeBook.md"`) that describes the data processing steps done, study design, and instructions for launching the 
data processing code, this readme file, and the script for processing (`"run_analysis.R"`).

