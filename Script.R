# New main script for Monotonicity analysis generation
# 29/5/2014

rm (list=ls())

# Stages: 

# Load prerequisites
require(MASS)
require(xlsx)
require(ggplot2)
require(reshape)


# Load data
source("Scripts/Read_Data.R")

# Load functions
source("Scripts/Functions.R")


# Stage global variables (e.g. N.psa)

n.psa <- 1000

# Check bootstrap IPD

Data_Long <- Make_Long(
    Data.2D
    )

# Want to make it wide again (because I'm crazy) 

Data_Wide <- unstack(
    Data_Long, 
    value ~ variable                 
                     )

tmp <- Data_Long$method[1:length(Data_Long$method) %%2] # Every other variable

Data_Wide <- data.frame(
    method=tmp, 
    Data_Wide
    )
rm(tmp)

g <- ggplot(data=Data_Wide, aes(x=U2, y=U1))
g2 <- 

# > Data_Wide <- reshape::dcast(Data_Long, method ~ variable)
# Error: 'dcast' is not an exported object from 'namespace:reshape'
# > Data_Wide <- reshape2::dcast(Data_Long, method ~ variable)
# Aggregation function missing: defaulting to length
# > head(Data_wide)
# Error in head(Data_wide) : 
#     error in evaluating the argument 'x' in selecting a method for function 'head': Error: object 'Data_wide' not found
# > head(Data_Wide)
# method   U1   U2
# 1           Bootstrapped 1000 1000
# 2            Independent 1000 1000
# 3      Quantile Matching 1000 1000
# 4  Replication (Upwards) 1000 1000
# 5 Replication (Downwards 1000 1000
# 6   Resampling (Upwards) 1000 1000
# > Data_Wide <- reshape2::dcast(Data_Long, method ~ variable, fun.aggregate=mean)
# > head(Data_Wide)
# method        U1        U2
# 1           Bootstrapped 0.5993126 0.5416754
# 2            Independent 0.5990084 0.5429250
# 3      Quantile Matching 0.6006302 0.5427822
# 4  Replication (Upwards) 0.5978000 0.5411227
# 5 Replication (Downwards 0.6007095 0.5412650
# 6   Resampling (Upwards) 0.6005380 0.5400699
# > Data_Wide <- reshape2::dcast(Data_Long, method ~ variable, fun.aggregate=sd)

# ggplot of Data_Long



####
# Make PSA

# Method 1



# Generate Figures


####################### Notes of actions from Manuscript

# Figures
# Redraw all figures in ggplot2
# First part (all ten methods)
# Label axes as 'better health state' & 'worse health state
#     Second part (subset of methods)
#         label axes as 'low health state', 'moderate health state', 'high health state'
#     Include names of methods in figures
#     Look at density plot equivalents of violin plots
#     ACTION: include multiple measures of central tendency in violin plots/density plots
# Further analyses
#     IPD
#         Additional two state IPD
#             Example where not all individual differences were positive
#         Additional three state IPD
#     Aggregate
#         Two state Different N
#         Three state different N


