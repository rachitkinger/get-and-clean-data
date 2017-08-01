## NOTE: I have not used dplyr for this assignment. I have used data.table package
##load the appropriate libraries
library(data.table)

#Downloads and unzips data to the working directory

download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile = as.character(getwd()), method = "curl")
unzip(zipfile = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", exdir = as.character(getwd()))


#load all data into separate datasets
#load activity data into workspace

testact  <- read.table("test/Y_test.txt" , header = FALSE)
trainact <- read.table("train/Y_train.txt", header = FALSE)

#load subject data for test and train

testsub  <- read.table("test/subject_test.txt", header = FALSE)
trainsub <- read.table("train/subject_train.txt", header = FALSE)

#load feature data from test and train

testfeat  <- read.table("test/X_test.txt", header = FALSE)
trainfeat <- read.table("train/X_train.txt", header = FALSE)

##====now start the cleaning and combining of data sets=====

## combine the test and train data sets for each type - activity, subject, and feature -
## and create 3 data sets (viz. activity, subject, features)

activity <- rbind(trainact, testact)
subject <- rbind(trainsub, testsub)
features <- rbind(trainfeat, testfeat)

## name the columns of the unicolumn datasets 
names(activity)<- c("activity")
names(subject)<-c("subject")
featureNames <- read.table("features.txt", head=FALSE)
names(features) <- featureNames$V2

#map the labels to activity in the activity data set
labels <- read.table("activity_labels.txt", header = FALSE)
activity$activity <- factor(activity$activity, levels = as.integer(labels$V1), labels = labels$V2)

#convert subject into factors to support further analysis
subject$subject <- factor(subject$subject, levels = 1:30)

#calculate means and std dev for columns by subsetting
meanstdev<-c(as.character(featureNames$V2[grep("mean\\(\\)|std\\(\\)", featureNames$V2)]))
subdata<-subset(features,select=meanstdev)

#bind the data sets with labels and activity
combined.sub.act <- cbind(subject, activity)
final <- cbind(subdata, combined.sub.act)

#prepare final dataset
names(final)<-gsub("^t", "time", names(final))
names(final)<-gsub("^f", "frequency", names(final))

#create new tidy data sets
suppressWarnings(tidydata <- aggregate(final, by = list(final$subject, final$activity), FUN = mean))
colnames(tidydata)[1] <- "Subject"
names(tidydata)[2] <- "Activity"

#remove avg and stdev for non-aggregated sub and act columns
tidydata <- tidydata[1:68]

#Finally, write the tidy data to text file
write.table(tidydata, file = "tidydata.txt", row.name = FALSE)


