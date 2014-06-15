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

n.psa <- 100000

# Check bootstrap IPD

source("Scripts/Make_Sample_Data.R")



C2 <- cast(D2, method ~ variable, function(x) round(c(mean=mean(x), sd=sd(x), quantile(x, seq(from=0.025, to=0.975, by=0.05))), digits=3))


source("scripts/Make_Figures.R")



# To do:

# Add dynamic notebooks which record critical parameters, summaries etc.
# Add subsection showing dependence of AIVM and cov methods on number of draws
# produce tables and caterpillar plots showing distribution of parameters



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


