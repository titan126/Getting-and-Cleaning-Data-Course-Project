---
title: "Codebook"
author: "William Garvey"
date: "10/05/2020"
output: html_document
---

```
library("dplyr")
library("reshape2")
```

This file details the study design and code book for the Getting and Cleaning Data Course Project.

## Study Design

Data collected from the accelerometers on Samsung Galaxy S II smartphone was used for this study. 30 people participated in the study from an age bracket of 19-48 years. Each person performed six different activities: walking, walking upstair, walking downstairs, sitting, standing, and laying. The data is available for retrieval from the following link: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

The dataset was randomly partitioned into two different sets: test and training. 70% of the volunteers were selected for generating the training data and 30% for the test data.

### Merging the Test and Training Data

The training and test data were read into R and merged to create one dataset. This was done using the read.csv and rbind commands below.

```
training_data <- read.table("UCI HAR Dataset/train/X_train.txt")
test_data <- read.table("UCI HAR Dataset/test/X_test.txt")
mergedData <- rbind(training_data, test_data)
```

The dataset contained a separate file identifying the names of each column in the dataset. This file was read into R and applied as the column names to the merged dataset via the code below.

```
data_label <- read.table("UCI HAR Dataset/features.txt")
data_label <- data_label[,2]
colnames(mergedData) <- data_label
```

### Extracting Measurements on Mean and Standard Deviation

Measurements containing either mean or standard deviation values were extracted via the commands below. This extracted only variables that are the output of the mean() or std() functions. Other variables such as meanFreq or gravityMean were excluded from the study.

```
mergedData <- mergedData %>%
  setNames(make.names(names(.), unique = TRUE)) %>%
  select(matches("\\.mean\\.\\.|\\.std\\.\\."))
```

### Using Descriptive Activity Names

The activity type corresponding to each entry in the training or test data are provided in separate files. The actual activity type isn't provided; rather, numbers from 1-6 indicate each of the six different entries. The training and test files were read into R using read.table and merged together. The numbers were replaced with the actual activity type (ex. WALKING in place of 1) using sapply and gsub.

```
activity_type_train <- read.table("UCI HAR Dataset/train/y_train.txt")
activity_type_test <- read.table("UCI HAR Dataset/test/y_test.txt")
activity_type <- rbind(activity_type_train, activity_type_test)
activity_type <- sapply(activity_type,function(x) {x <- gsub(1,"WALKING",x)})
activity_type <- sapply(activity_type,function(x) {x <- gsub(2,"WALKING_UPSTAIRS",x)})
activity_type <- sapply(activity_type,function(x) {x <- gsub(3,"WALKING_DOWNSTAIRS",x)})
activity_type <- sapply(activity_type,function(x) {x <- gsub(4,"SITTING",x)})
activity_type <- sapply(activity_type,function(x) {x <- gsub(5,"STANDING",x)})
activity_type <- sapply(activity_type,function(x) {x <- gsub(6,"LAYING",x)})
```

A unique identifier for each subject in the training and test studies was also provided in a separate file. These files were read into R, merged together, and given a column name of subject_identifier.

```
test_subject <- read.table("UCI HAR Dataset/test/subject_test.txt")
train_subject <- read.table("UCI HAR Dataset/train/subject_train.txt")
mergedSubject <- rbind(test_subject,train_subject)
colnames(mergedSubject) <- "subject_identifier"
```

The activity and subject identifiers were added to the existing dataframe using rbind.

```
mergedData <- cbind(mergedData,activity_type)
mergedData <- cbind(mergedData,mergedSubject)
```

### Creating a Second Tidy Dataset

The melt function from the dplyr package was used to reshape the dataset. This creates a new data frame (mergedMelt) with the activity type and subject identifier in one column. In another column, each variable and value are recorded.

```
measures <- colnames(mergedData)
x <- c(-length(measures),-length(measures)+1)
measures <- measures[x]
mergedMelt <- melt(mergedData, id = c("activity_type","subject_identifier"), measure.vars = measures)
```

The dcast function from the reshape2 package was then used to calculate the mean of each subject and activity type pairing.

```
mergedMeans <- dcast(mergedMelt, activity_type + subject_identifier ~ variable, mean)
```

The column names in the dataset were tidied up slightly.

```
temp <- colnames(mergedMeans)
temp <- gsub("..", "()", temp, fixed = TRUE)
temp <- gsub(".", "-", temp, fixed = TRUE)
temp <- gsub("BodyBody", "Body", temp, fixed = TRUE)
colnames(mergedMeans) <- temp
```

Finally, the tidied data was output with write.table.

```
write.table(mergedMeans, file = "tidy_data.txt", row.names = FALSE, quote = FALSE)
```

## Code Book

The following is a list of each variable in the tidy data set.

* activity_type - identifies the activity being performed by each individual: 
  + WALKING
  + WALKING_UPSTAIRS
  + WALKING_DOWNSTAIRS
  + SITTING
  + STANDING
  + LAYING
* subject_identifier - unique identifier for each subject participating in the study, 1-30

All variables discussed after this point are bounded by [0,1].

The units for the variables below are standard gravity (g), 9.80665 m/s^2. The "t" at the beginning of each variable denotes a time-domain signal.

* tBodyAcc-mean()-X - mean body acceleration, X direction
* tBodyAcc-mean()-Y - mean body acceleration, Y direction
* tBodyAcc-mean()-Z - mean body acceleration, Z direction
* tBodyAcc-std()-X - body acceleration standard deviation, X direction
* tBodyAcc-std()-Y - body acceleration standard deviation, Y direction
* tBodyAcc-std()-Z - body acceleration standard deviation, Z direction
* tGravityAcc-mean()-X - mean gravity acceleration, X direction
* tGravityAcc-mean()-Y - mean gravity acceleration, Y direction
* tGravityAcc-mean()-Z - mean gravity acceleration, Z direction
* tGravityAcc-std()-X - gravity acceleration standard deviation, X direction
* tGravityAcc-std()-Y - gravity acceleration standard deviation, Y direction
* tGravityAcc-std()-Z - gravity acceleration standard deviation, Z direction

Jerk signals were also calculated and included with the data. This indicates the rate at which an object is accelerating. The units are standard gravity (g), 9.80665 m/s^2. (ref: https://en.wikipedia.org/wiki/Jerk_(physics) )

* tBodyAccJerk-mean()-X - mean body acceleration jerk signal, X direction
* tBodyAccJerk-mean()-Y - mean body acceleration jerk signal, Y direction
* tBodyAccJerk-mean()-Z - mean body acceleration jerk signal, Z direction
* tBodyAccJerk-std()-X - body acceleration jerk standard deviation, X direction
* tBodyAccJerk-std()-Y - body acceleration jerk standard deviation, Y direction
* tBodyAccJerk-std()-Z - body acceleration jerk standard deviation, Z direction

The angular velocity was also calculated from the gyroscope on the phone. The units are radians per second (rad/s).

* tBodyGyro-mean()-X - mean body angular velocity, X direction
* tBodyGyro-mean()-Y - mean body angular velocity, Y direction
* tBodyGyro-mean()-Z - mean body angular velocity, Z direction
* tBodyGyro-std()-X - body angular velocity standard deviation, X direction
* tBodyGyro-std()-Y - body angular velocity standard deviation, Y direction
* tBodyGyro-std()-Z - body angular velocity standard deviation, Z direction

Jerk signals were also calculated from the body angular velocity data. These variables are detailed below. THe units are radians per second (rad/s).

* tBodyGyroJerk-mean()-X - mean body angular velocity jerk signal, X direction
* tBodyGyroJerk-mean()-Y - mean body angular velocity jerk signal, Y direction
* tBodyGyroJerk-mean()-Z - mean body angular velocity jerk signal, Z direction
* tBodyGyroJerk-std()-X - body angular velocity jerk signal standard deviation, X direction
* tBodyGyroJerk-std()-Y - body angular velocity jerk signal standard deviation, Y direction
* tBodyGyroJerk-std()-Z - body angular velocity jerk signal standard deviation, Z direction

The magnitude of several of the variables detailed above was also calculated using the Euclidean norm (ref: https://en.wikipedia.org/wiki/Norm_(mathematics)#Euclidean_norm ). Magnitude calculations are detailed below.

* tBodyAccMag-mean() - mean body acceleration magnitude
* tBodyAccMag-std() - body acceleration magnitude standard deviation
* tGravityAccMag-mean() - mean gravity acceleration magnitude
* tGravityAccMag-std() - gravity acceleration magnitude standard deviation
* tBodyAccJerkMag-mean() - mean body acceleration jerk signal magnitude
* tBodyAccJerkMag-std() - body acceleration jerk signal magnitude standard deviation
* tBodyGyroMag-mean() - mean body angular velocity magnitude
* tBodyGyroMag-std() - body angular velocity magnitude standard deviation
* tBodyGyroJerkMag-mean() - mean body angular velocity jerk signal magnitude 
* tBodyGyroJerkMag-std() - body angular velocity jerk signal magnitude standard deviation

The FFT was also computed for many of the variables detailed above to produce another set of variables. These begin with "f" to indicate that the FFT was taken. The units for each are the same as the corresponding time domain variable.

* fBodyAcc-mean()-X - FFT mean body acceleration, X direction
* fBodyAcc-mean()-Y - FFT mean body acceleration, Y direction
* fBodyAcc-mean()-Z - FFT mean body acceleration, Z direction
* fBodyAcc-std()-X - FFT body acceleration standard deviation, X direction
* fBodyAcc-std()-Y - FFT body acceleration standard deviation, Y direction
* fBodyAcc-std()-Z - FFT body acceleration standard deviation, Z direction
* fBodyAccJerk-mean()-X - FFT mean body acceleration jerk signal, X direction
* fBodyAccJerk-mean()-Y - FFT mean body acceleration jerk signal, Y direction
* fBodyAccJerk-mean()-Z - FFT mean body acceleration jerk signal, Z direction
* fBodyAccJerk-std()-X - FFT body acceleration jerk standard deviation, X direction
* fBodyAccJerk-std()-Y - FFT body acceleration jerk standard deviation, Y direction
* fBodyAccJerk-std()-Z - FFT body acceleration jerk standard deviation, Z direction
* fBodyGyro-mean()-X - FFT mean body angular velocity, X direction
* fBodyGyro-mean()-Y - FFT mean body angular velocity, Y direction
* fBodyGyro-mean()-Z - FFT mean body angular velocity, Z direction
* fBodyGyro-std()-X - FFT body angular velocity standard deviation, X direction
* fBodyGyro-std()-Y - FFT body angular velocity standard deviation, Y direction
* fBodyGyro-std()-Z - FFT body angular velocity standard deviation, Z direction
* fBodyAccMag-mean() - FFT mean body acceleration magnitude
* fBodyAccMag-std() - FFT body acceleration magnitude standard deviation
* fBodyAccJerkMag-mean() - FFT mean body acceleration jerk signal magnitude
* fBodyAccJerkMag-std() - FFT body acceleration jerk signal magnitude standard deviation
* fBodyGyroMag-mean() - FFT mean body angular velocity magnitude
* fBodyGyroMag-std() - FFT body angular velocity magnitude standard deviation
* fBodyGyroJerkMag-mean() - FFT body angular velocity jerk signal magnitude
* fBodyGyroJerkMag-std() - FFT body angular velocity jerk signal magnitude standard deviation