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

Bi.M05 <- Create_Draws(
    Sum_Data=data.sum,
    method=5
    )

# Check method 6
Bi.M06 <- Create_Draws(
    Sum_Data=data.sum,
    method=6
)

# Check method 7
Bi.M07 <- Create_Draws(
    Sum_Data=data.sum,
    method=7
)


# Check method 8
Bi.M08 <- Create_Draws(
    Sum_Data=data.sum,
    method=8
    )


# Check method 9
Bi.M09 <- Create_Draws(
    Sum_Data=data.sum,
    method=9
)



# Check method 10

Bi.M10u <- Create_Draws(
    Sum_Data=data.sum,
    method=10,
    direction="up"
)

Bi.M10d <- Create_Draws(
    Sum_Data=data.sum,
    method=10,
    direction="down"
)


# Combine all estimates into a single long dataframe

Data_Wide <- data.frame(
    method=c(),
    variable=c(),
    value=c()
    )

tmp <- reshape::melt(
    data.frame(Bi.M01),
    measure.vars=c("U1", "U2")
    )

##################
tmp <- data.frame(method="Ind", tmp)

Data_Wide <- rbind(
    Data_Wide, 
    tmp
    )

###############
tmp <- reshape::melt(
    data.frame(Bi.M02),
    measure.vars=c("U1", "U2")
)

tmp <- data.frame(method="Quant Match", tmp)

Data_Wide <- rbind(
    Data_Wide, 
    tmp
)

##############
tmp <- reshape::melt(
    data.frame(Bi.M02),
    measure.vars=c("U1", "U2")
)

tmp <- data.frame(method="Quant Match", tmp)

Data_Wide <- rbind(
    Data_Wide, 
    tmp
)

##############
tmp <- reshape::melt(
    data.frame(Bi.M03),
    measure.vars=c("U1", "U2")
)

tmp <- data.frame(method="Rep Up", tmp)

Data_Wide <- rbind(
    Data_Wide, 
    tmp
)

#############
tmp <- reshape::melt(
    data.frame(Bi.M04),
    measure.vars=c("U1", "U2")
)

tmp <- data.frame(method="Rep down", tmp)

Data_Wide <- rbind(
    Data_Wide, 
    tmp
)

#############
tmp <- reshape::melt(
    data.frame(Bi.M05),
    measure.vars=c("U1", "U2")
)

tmp <- data.frame(method="Resamp Up", tmp)

Data_Wide <- rbind(
    Data_Wide, 
    tmp
)

#############
tmp <- reshape::melt(
    data.frame(Bi.M06),
    measure.vars=c("U1", "U2")
)

tmp <- data.frame(method="Resamp Down", tmp)

Data_Wide <- rbind(
    Data_Wide, 
    tmp
)

#############
tmp <- reshape::melt(
    data.frame(Bi.M07),
    measure.vars=c("U1", "U2")
)

tmp <- data.frame(method="AIVM", tmp)

Data_Wide <- rbind(
    Data_Wide, 
    tmp
)

#############
tmp <- reshape::melt(
    data.frame(Bi.M08),
    measure.vars=c("U1", "U2")
)

tmp <- data.frame(method="LB", tmp)

Data_Wide <- rbind(
    Data_Wide, 
    tmp
)

tmp <- reshape::melt(
    data.frame(Bi.M09),
    measure.vars=c("U1", "U2")
)

tmp <- data.frame(method="UB", tmp)

Data_Wide <- rbind(
    Data_Wide, 
    tmp
)

tmp <- reshape::melt(
    data.frame(Bi.M10),
    measure.vars=c("U1", "U2")
)

tmp <- data.frame(method="Diff Up", tmp)

Data_Wide <- rbind(
    Data_Wide, 
    tmp
)

tmp <- reshape::melt(
    data.frame(Bi.M10d),
    measure.vars=c("U1", "U2")
)

tmp <- data.frame(method="Diff Down", tmp)

Data_Wide <- rbind(
    Data_Wide, 
    tmp
)

# Make PSA

# Method 1



# Generate Figures


