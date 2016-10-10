## Load Packages
library(dplyr)
library(tidyr)
## Download file
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")
## Unzip file
unzip(zipfile="./data/Dataset.zip",exdir="./data")
## Getting files
path_rf <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path_rf, recursive=TRUE)
dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)
dataFeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)
## Merging Subject, Activity and Features data 
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
## Naming Variables
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
names(dataFeatures)<- dataFeaturesNames$V2
## Merging all data
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)
##Extract mean and standard deviation
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)
## Descriptive activity names
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)
names(activityLabels)<-c("activity", "descriptiveactivity")
Data<-merge(x=Data, y=activityLabels, by="activity")
Data<-select(Data, -activity)
## Labeling variables with descriptive names
names(Data)<-gsub("^t", "Time", names(Data))
names(Data)<-gsub("^f", "Frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))
## Create tidy data set
Data2<-aggregate(. ~subject + descriptiveactivity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$descriptiveactivity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)
