---
title: "CodeBook.md"
author: "Johnny Oh"
date: "June 21, 2016"
output: 
  html_document: 
    keep_md: yes
---

#Getting and Cleaning Data - Course Project
The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

You should create one R script called run_analysis.R that does the following.

Merges the training and the test sets to create one data set.
Extracts only the measurements on the mean and standard deviation for each measurement.
Uses descriptive activity names to name the activities in the data set
Appropriately labels the data set with descriptive variable names.
From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Description of the dataset
The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain.

##Tidying the dataset
#0. Pre work
```{r}
# Clean the workspace
ls()
rm(list=ls())

# Install relevant packages
library(dplyr)
library(data.table)
library(tidyr)

# Download the file
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./masterfitness.zip",method="curl") 
unzip("masterfitness.zip")
```

#1. Merge the training and the test sets to create one data set.
```{r}
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
```

#2. Extract only the measurements on the mean and standard deviation for each measurement. 
```{r}
## Extracting only the mean and standard deviation
meanstd <- grep("mean\\(\\)|std\\(\\)",features$featureName,value=TRUE) #var name

## Taking only measurements for mean and standard deviation and add "subject","activitynum"
meanstd <- union(c("subject","activitynum"), meanstd)
data <- subset(data,select=meanstd) 
head(data)
```


#3. Use descriptive activity names to name the activities in the data set.
```{r}
# Enter name of activity into data
data <- merge(activitylabels, data , by="activitynum", all.x=TRUE)
data$activityname <- as.character(data$activityname)

## Create data with variable means sorted by subject and activity
data$activityname <- as.character(data$activityname)
dataaggregate <- aggregate(. ~ subject - activityname, data = data, mean) 
data <- tbl_df(arrange(dataaggregate,subject,activityname))
```


#4. Appropriately label the data set with descriptive activity names. 
```{r}
names(data) <-gsub("std()", "standard deviation", names(data))
names(data) <-gsub("mean()", "mean", names(data))
names(data) <-gsub("^t", "time", names(data))
names(data) <-gsub("^f", "frequency", names(data))
names(data) <-gsub("Acc", "accelerometer", names(data))
names(data) <-gsub("Gyro", "gyroscope", names(data))
names(data) <-gsub("Mag", "magnitude", names(data))
names(data) <-gsub("BodyBody", "body", names(data))
```


#5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
```{r}
write.table(data, "TidyData.txt", row.name=FALSE)
```
