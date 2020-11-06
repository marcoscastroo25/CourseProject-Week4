# 1. Combino los set del training y pruebas para crear un Data Set.

## Paso 1: Descargo el archivo zip del sitio web
if(!file.exists("./data")) dir.create("./data")
sourceUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(sourceUrl, destfile = "./data/projectData_getCleanData.zip")

## Paso 2: Descomprimo los datos
fileZip <- unzip("./data/projectData_getCleanData.zip", exdir = "./data")

## Pase 3: Cargo los datos en R
xtrain <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
ytrain <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subjecttrain <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
xtest <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
ytest <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subjecttest <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

## Paso 4: Combino los datos de training y test
trainMerged <- cbind(subjecttrain, ytrain, xtrain)
testMerged <- cbind(subjecttest, ytest, xtest)
FinalMerged <- rbind(trainMerged, testMerged)

# 2. Extraigo solamente las medidas sobre el promedio y la desviacion estandar de cada medida.

## Paso 1: Cargo las caracteristicas del nombre en R
featureName <- read.table("./data/UCI HAR Dataset/features.txt", stringsAsFactors = FALSE)[,2]

## Paso 2:  Extraigo el promedio y la desviacion estandar de cada medidas
featureIndex <- grep(("mean\\(\\)|std\\(\\)"), featureName)
finalData <- FinalMerged[, c(1, 2, featureIndex+2)]
colnames(finalData) <- c("subject", "activity", featureName[featureIndex])

# 3. Utilizo nombres de actividades descriptivos para nombrar las actividades en el data set

## Paso 1: load activity data into R
activityName <- read.table("./data/UCI HAR Dataset/activity_labels.txt")

## Paso 2: reemplazo del 1 al 6 con los nombres de actividades
finalData$activity <- factor(finalData$activity, levels = activityName[,1], labels = activityName[,2])

# 4. Etiqueto apropiadamente el conjunto de datos con nombres de variables descriptivos

names(finalData) <- gsub("\\()", "", names(finalData))
names(finalData) <- gsub("^t", "time", names(finalData))
names(finalData) <- gsub("^f", "frequence", names(finalData))
names(finalData) <- gsub("-mean", "Mean", names(finalData))
names(finalData) <- gsub("-std", "Std", names(finalData))

# 5. Creo un segundo conjunto de datos ordenado e independiente con el promedio de cada variable para cada actividad y cada tema.
library(dplyr)
groupData <- finalData %>%
    group_by(subject, activity) %>%
    summarise_each(funs(mean))

# 6. Genero Archivo txt
write.table(groupData, "./Getting_and_Cleaning_data_Project/tidydataFinal.txt", row.names = FALSE)