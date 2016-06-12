
## Get the file
if(!file.exists("./finalData")){dir.create("./finalData")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./finalData/Data.zip",method="curl")

## Unzip the file
unzip(zipfile="./finalData/Data.zip",exdir="./finaldata")
              
## read activity files
dir_r <- file.path("./finalData", "UCI HAR Dataset")
activityTest  <- read.table(file.path(dir_r, "test" , "Y_test.txt" ),header = FALSE)
activityTrain <- read.table(file.path(dir_r, "train", "Y_train.txt"),header = FALSE)
              
## read subject files
subjectTrain <- read.table(file.path(dir_r, "train", "subject_train.txt"),header = FALSE)
subjectTest  <- read.table(file.path(dir_r, "test" , "subject_test.txt"),header = FALSE)
              
## read features files
featuresTest  <- read.table(file.path(dir_r, "test" , "X_test.txt" ),header = FALSE)
featuresTrain <- read.table(file.path(dir_r, "train", "X_train.txt"),header = FALSE)
              
## merge into one dataset
subject_data <- rbind(subjectTrain, subjectTest)
activity_data <- rbind(activityTrain, activityTest)
feature_data <- rbind(featuresTrain, featuresTest)
              
names(subject_data)<-c("subject")
names(activity_data)<- c("activity")
featureHeader <- read.table(file.path(dir_r, "features.txt"),head=FALSE)
names(feature_data)<- featureHeader$V2
              
data_merge <- cbind(subject_data, activity_data)
allData <- cbind(feature_data, data_merge)
              
## extract mean & std dev
mean_stdev <-featureHeader$V2[grep("mean\\(\\)|std\\(\\)", featureHeader$V2)]
mean_stdev2<-c(as.character(mean_stdev), "subject", "activity" )
allDataSub<-subset(allData,select=mean_stdev2)
              
## use descriptive activity names
activityNames <- read.table(file.path(dir_r, "activity_labels.txt"),header = FALSE)
allDataSub$activity<-factor(allDataSub$activity);
allDataSub$activity<- factor(allDataSub$activity,labels=as.character(activityNames$V2))
              
## use descriptive variable names
names(allDataSub)<-gsub("^t", "time", names(allDataSub))
names(allDataSub)<-gsub("^f", "frequency", names(allDataSub))
names(allDataSub)<-gsub("Acc", "Accelerometer", names(allDataSub))
names(allDataSub)<-gsub("Gyro", "Gyroscope", names(allDataSub))
names(allDataSub)<-gsub("Mag", "Magnitude", names(allDataSub))
names(allDataSub)<-gsub("BodyBody", "Body", names(allDataSub))
              
## creates tidy dataset
library(plyr);
tidyData<-aggregate(. ~subject + activity, allDataSub, mean)
tidyData<-tidyData[order(tidyData$subject, tidyData$activity),]
write.table(tidyData, file = "tidyData.txt",row.name=FALSE)
              
              