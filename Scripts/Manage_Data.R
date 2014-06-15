# Manage data file: 

# Load the csvs
# create the samples

# save the samples

# Load data
source("Scripts/Read_Data.R")

if (!file.exists("Data/RObj/Samples_2D.RData")){
    print("Not found Samples Data. Creating from scratch")
    source("Scripts/Make_Sample_Data.R")
    
    print("Saving created data")
    save(Data_Long, Data_Wide, file="Data/RObj/Samples_2D.RData")
    
} else {
    print("Found Samples Data. Loading.")
    load("Data/RObj/Samples_2D.RData")
    
}