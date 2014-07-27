# New main script for Monotonicity analysis generation
# 29/5/2014

##### TO DO
# 1) Look again at calculation of covariance approaches



##############################


rm (list=ls())

# Load prerequisites

source("scripts/LoadPackages.R")

RequiredPackages(
    c(
        "MASS",
        "xlsx",
        "ggplot2",
        "reshape",
        "gdata",
        "devtools",
        "plyr"
        )
    )

#######################################################################################################
######################### FUNCTIONS ###################################################################
#######################################################################################################
source("scripts/functions.r")


#######################################################################################################
######################### GLOBAL VARIABLES ############################################################
#######################################################################################################
# Global variables will be ALL UPPERCASE to distinguish them from other variables

N_PSA <- 100000

#######################################################################################################
######################### MAIN SECTION ############################################################
#######################################################################################################


source("Scripts/manage_data.r")



####
source("scripts/make_summaries_dataframes.r")

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


