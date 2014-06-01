# New main script for Monotonicity analysis generation
# 29/5/2014

rm (list=ls())

# Stages: 

# Load prerequisites
require(MASS)
require(xlsx)
require(ggplot2)


# Load data
source("Scripts/Read_Data.R")

# Load functions
source("Scripts/Functions.R")


# Stage global variables (e.g. N.psa)

n.psa <- 1000

# Check bootstrap IPD

Bi.Boot <- Bootstrap_Means_IPD(
    Data.2D,
    n.reps=n.psa
    )

# Check Summarise_IPD

data.sum <- Summarise_IPD(Data.2D)


# Check method 1

Bi.M01 <- Create_Draws(
    Sum_Data=data.sum,
    method=1
    )

# Check method 2
Bi.M02 <- Create_Draws(
    Sum_Data=data.sum,
    method=2
    )
# Check method 3
Bi.M03 <- Create_Draws(
    Sum_Data=data.sum,
    method=3
)

# Check method 4
Bi.M04 <- Create_Draws(
    Sum_Data=data.sum,
    method=4
)
# Check method 5

# Check method 6

# Check method 7

# Check method 8

# Check method 9

# Chech method 10




# Make PSA

# Method 1



# Generate Figures


