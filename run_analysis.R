library(reshape2)

tempfile <- "dataset.zip"

## Download and unzip the data for the project:
if (!file.exists(tempfile)){
        fileURL <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileURL, tempfile)
}  
if (!file.exists("UCI HAR Dataset")) { 
        unzip(tempfile) 
}

# Load activity files: labels and features
act_label <- read.table("UCI HAR Dataset/activity_labels.txt")
act_label[,2] <- as.character(act_label[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extracts only the data on the mean and standard deviation for each measurement
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names <- features[featuresWanted,2]
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)

# Load the training datasetsaset/train/X_train.txt")[featuresWanted]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

# Load the test dataset
test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge train and test datasets into one data set and add labels
onedata <- rbind(train, test)
colnames(onedata) <- c("subject", "activity", featuresWanted.names)

# turn activities & subjects into factors
onedata$activity <- factor(onedata$activity, levels = act_label[,1], labels = act_label[,2])
onedata$subject <- as.factor(onedata$subject)

onedata.melted <- melt(onedata, id = c("subject", "activity"))
onedata.mean <- dcast(onedata.melted, subject + activity ~ variable, mean)

write.table(onedata.mean, "tidydataset.txt", row.names = FALSE, quote = FALSE)