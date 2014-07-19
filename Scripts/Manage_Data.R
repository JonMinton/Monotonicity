# Manage data file: 

# Load the csvs
# create the samples

# save the samples

# Load data
source("scripts/read_data.r")

if (!file.exists("data/robj/samples_2d.rdata")){
    print("Not found Samples Data. Creating from scratch")
    source("scripts/make_sample_data.r")
    
    print("Saving created data")
    save(data_long, data_wide, file="data/robj/samples_2d.rdata")
    
} else {
    print("Found Samples Data. Loading.")
    load("data/robj/samples_2d.rdata")
    
}