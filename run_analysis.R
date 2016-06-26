# Getting and Cleaning Data - Course Project
# Johnny Oh
# June 21, 2016

# The goal of this exercise is to create a tidy data set by doing the following:
# 1. Merge the training and the test sets to create one data set.
# 2. Extract only the measurements on the mean and standard deviation for each measurement. 
# 3. Use descriptive activity names to name the activities in the data set.
# 4. Appropriately label the data set with descriptive activity names. 
# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
################################################################################

### 0. Pre-work
## Clean the workspace
ls()
rm(list=ls())

## Install relevant packages
library(dplyr)
library(data.table)
library(tidyr)

## Download the file
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./masterfitness.zip",method="curl") 
unzip("masterfitness.zip")



### 1. Merge the training and the test sets to create one data set.
## Download all the relevant files
# Read subject files
subjecttrain <- tbl_df(read.table(file.path("UCI HAR Dataset", "train", "subject_train.txt")))
subjecttest  <- tbl_df(read.table(file.path("UCI HAR Dataset", "test" , "subject_test.txt" )))

# Read activity files
activitytrain <- tbl_df(read.table(file.path("UCI HAR Dataset", "train", "Y_train.txt")))
activitytest  <- tbl_df(read.table(file.path("UCI HAR Dataset", "test" , "Y_test.txt" )))

#Read data files.
train <- tbl_df(read.table(file.path("UCI HAR Dataset", "train", "X_train.txt" )))
test  <- tbl_df(read.table(file.path("UCI HAR Dataset", "test" , "X_test.txt" )))

## Merge subject and activity files
allsubject <- rbind(subjecttrain, subjecttest)
setnames(allsubject, "V1", "subject")

allactivity<- rbind(activitytrain, activitytest)
setnames(allactivity, "V1", "activitynum")

## Combine the training and test files
data <- rbind(train, test)

## name variables according to feature e.g.(V1 = "tBodyAcc-mean()-X")
features <- tbl_df(read.table(file.path("UCI HAR Dataset", "features.txt")))
setnames(features, names(features), c("featureNum", "featureName"))
colnames(data) <- features$featureName

## column names for activity labels
activitylabels<- tbl_df(read.table(file.path("UCI HAR Dataset", "activity_labels.txt")))
setnames(activitylabels, names(activitylabels), c("activitynum","activityname"))

## Merge columns
allsubact<- cbind(allsubject, allactivity)
data <- cbind(allsubact, data)



### 2. Extract only the measurements on the mean and standard deviation for each measurement. 
## Extracting only the mean and standard deviation
meanstd <- grep("mean\\(\\)|std\\(\\)",features$featureName,value=TRUE) #var name

## Taking only measurements for mean and standard deviation and add "subject","activitynum"
meanstd <- union(c("subject","activitynum"), meanstd)
data <- subset(data,select=meanstd) 
head(data)



### 3. Use descriptive activity names to name the activities in the data set.
## Enter name of activity into data
data <- merge(activitylabels, data , by="activitynum", all.x=TRUE)
data$activityname <- as.character(data$activityname)

## Create data with variable means sorted by subject and activity
data$activityname <- as.character(data$activityname)
dataaggregate <- aggregate(. ~ subject - activityname, data = data, mean) 
data <- tbl_df(arrange(dataaggregate,subject,activityname))



### 4. Appropriately label the data set with descriptive activity names. 
names(data) <-gsub("std()", "standard deviation", names(data))
names(data) <-gsub("mean()", "mean", names(data))
names(data) <-gsub("^t", "time", names(data))
names(data) <-gsub("^f", "frequency", names(data))
names(data) <-gsub("Acc", "accelerometer", names(data))
names(data) <-gsub("Gyro", "gyroscope", names(data))
names(data) <-gsub("Mag", "magnitude", names(data))
names(data) <-gsub("BodyBody", "body", names(data))



### 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
write.table(data, "TidyData.txt", row.name=FALSE)







