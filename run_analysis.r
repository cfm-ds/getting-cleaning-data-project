library(dplyr)
basePath <- "./UCI HAR Dataset/"
max <- -1

setup <- function() {
  if(!file.exists("galaxy.zip")) {
    source_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
    dest <- "galaxy.zip"
    download.file(source_url, dest, method = "curl")
    unzip("galaxy.zip")
  }
}


deriveNames <- function() {
    #Load feature names
    features <- read.table(paste0(basePath, "features.txt"), stringsAsFactors = FALSE, col.names = c("index", "name"))
    
    #Fetch the mean and deviation related names
    selection <- features[grep("mean()|std()", features$name),]
    
    #Reformat names to proper descriptive column names
    
    #Remove parenthesis, replace dash by point and set lowercase
    selection$names <- gsub("[()]", "",gsub("-", ".", tolower(selection$name)))
    
    #Add point after metric components, remove any double points generated
    selection$names <- make.names(gsub("\\.\\.", ".", gsub("(^t|^f|body|gravity|acc|gyro|jerk)", "\\1.", selection$names)))
    
    #Remove double body identifier on some frequency related variables
    selection$names <- make.names(gsub("body\\.body\\.", "body\\.", selection$names))

    selection
}

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

readFullDataSet <- function() {
  rbind(loadData("train"), loadData("test"))
}

createTidyDataSet <- function() {
  #Read all training, testing, subject and activity data
  all <- readFullDataSet()
  
  #Group by activity and subject and summarise with mean
  result <- all %>% group_by(activity, subject) %>% summarise_each(funs(mean))
  
  #Write out to disk
  write.table(result, file = "tidy_samsung.txt", row.name=FALSE)
  all
}
setup()
readFullDataSet()
ds <- createTidyDataSet()