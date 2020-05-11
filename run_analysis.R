library("dplyr")
library("reshape2")

#read training/test data and merge into a single dataset
training_data <- read.table("UCI HAR Dataset/train/X_train.txt")
test_data <- read.table("UCI HAR Dataset/test/X_test.txt")
mergedData <- rbind(training_data, test_data)

#read features and add them as columns to the data frame
data_label <- read.table("UCI HAR Dataset/features.txt",check.names = FALSE)
data_label <- data_label[,2]
colnames(mergedData) <- data_label

#extract only measurements on mean or standard deviation
mergedData <- mergedData %>%
  setNames(make.names(names(.), unique = TRUE)) %>%
  select(matches("\\.mean\\.\\.|\\.std\\.\\."))

#read subject data and merge into a single dataset
test_subject <- read.table("UCI HAR Dataset/test/subject_test.txt")
train_subject <- read.table("UCI HAR Dataset/train/subject_train.txt")
mergedSubject <- rbind(test_subject,train_subject)
colnames(mergedSubject) <- "subject_identifier"

#read activity types, merge into a single set, and tidy with activity names
activity_type_train <- read.table("UCI HAR Dataset/train/y_train.txt")
activity_type_test <- read.table("UCI HAR Dataset/test/y_test.txt")
activity_type <- rbind(activity_type_train, activity_type_test)
activity_type <- sapply(activity_type,function(x) {x <- gsub(1,"WALKING",x)})
activity_type <- sapply(activity_type,function(x) {x <- gsub(2,"WALKING_UPSTAIRS",x)})
activity_type <- sapply(activity_type,function(x) {x <- gsub(3,"WALKING_DOWNSTAIRS",x)})
activity_type <- sapply(activity_type,function(x) {x <- gsub(4,"SITTING",x)})
activity_type <- sapply(activity_type,function(x) {x <- gsub(5,"STANDING",x)})
activity_type <- sapply(activity_type,function(x) {x <- gsub(6,"LAYING",x)})

#add activity types and subject data to data frame
mergedData <- cbind(mergedData,activity_type)
mergedData <- cbind(mergedData,mergedSubject)

#melt resulting data frame
#this creates a new data frame with the activity type and subject identifier in one column
#in another column, each variable and value are recorded
measures <- colnames(mergedData)
x <- c(-length(measures),-length(measures)+1)
measures <- measures[x]
mergedMelt <- melt(mergedData, id = c("activity_type","subject_identifier"), measure.vars = measures)

#use dcast to calculate the mean of each activity type and subject pairing
mergedMeans <- dcast(mergedMelt, activity_type + subject_identifier ~ variable, mean)

#clean up column names
temp <- colnames(mergedMeans)
temp <- gsub("..", "()", temp, fixed = TRUE)
temp <- gsub(".", "-", temp, fixed = TRUE)
temp <- gsub("BodyBody", "Body", temp, fixed = TRUE)
colnames(mergedMeans) <- temp

#write tidy dataset to a separate file
write.table(mergedMeans, file = "tidy_data.txt", row.names = FALSE, quote = FALSE)