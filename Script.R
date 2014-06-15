# New main script for Monotonicity analysis generation
# 29/5/2014

rm (list=ls())

# Stages: 

# Load prerequisites
require(MASS)
require(xlsx)
require(ggplot2)
require(reshape)
require(gdata)




# Load functions
source("Scripts/Functions.R")


# Stage global variables (e.g. N.psa)

n.psa <- 100000

# Check bootstrap IPD

source("Scripts/Manage_Data.R")


Summaries.MeanSD <- cast(
    Data_Long, 
    method ~ variable, 
    function(x) c(mean=mean(x), sd=sd(x))
)

Summaries.Quantiles <- cast(
    Data_Long,
    method ~ variable,
    quantile,
    seq(from=0.025, to=0.975, by=0.05)
    )

Summaries.Difs <- cbind(
    Summaries.Quantiles[-1,1],
    adply(Summaries.Quantiles[-1,-1],1, function(x) ((x - Summaries.Quantiles[1,-1])^2))
    )

names(Summaries.Difs)[1] <- "method"
Summaries.Difs.Long <- melt(Summaries.Difs, id.var="method")
Summaries.Difs.Long <- cbind(Summaries.Difs.Long, colsplit(Summaries.Difs.Long$variable, "_", c("var", "quantile")))
Summaries.Difs.Long <- gdata::remove.vars(Summaries.Difs.Long, "variable")

Summaries.RMS <- ddply(Summaries.Difs.Long, .(method, var),function(x) (rms=mean(x$value))^0.5)

attach(Summaries.RMS)
Summaries.RMS <- Summaries.RMS[order(var, method),]
detach(Summaries.RMS)

Summaries.RMS <- rename.vars(Summaries.RMS, from="V1", to="value")

Summaries.RMS$method <- factor(Summaries.RMS$method,
                               levels=rev(levels(Summaries.RMS$method))
                                   )
qplot(x=method, y=value, data=Summaries.RMS, facets = . ~  var, geom="bar")+ coord_flip() 

g1 <- ggplot(data=Summaries.RMS) + geom_linerange(aes(x=method, ymax=value, ymin=0), size=1.2) + coord_flip() 
g2 <- g1 + facet_wrap(  ~ var) 
g2


# What I want: a RMS summary measure

# root mean squared difference between method X and Bootstrapped estimates for each quantile from 
# 2.5% to 97.5%, increasing at 5% intervals

# I want summaries to be in long format

S <- melt(Summaries, id.vars="method")
# Surprisingply painless! 
# Split this into a list of three data frames
S2 <- dlply(S, .(variable))

f1 <- function(x) {
    isBoot <- which(x$method=="Bootstrapped")
    D1 <- x[isBoot,]
    D2 <- x[-isBoot,]
    out <- list(boot=D1, other=D2)
    return(out)
}

f2 <- function(x){
    boot <- x$boot
    other <- x$other
    
    
    
}

debug(f2)

S.boot <- llply(S2, f1)

S.outcome <- ldply(
    S.boot,
    f2
    
    )

SS <- subset(S, subset=method!="Bootstrapped")
SB <- subset(S, subset=method=="Bootstrapped")

SS <- SS[SS$result_variable !="mean" & SS$result_variable!="sd",]
SB <- SB[SB$result_variable !="mean" & SB$result_variable!="sd",]


rmsdif <- function(x){
    
    out <- x$value - SB$value
    out <- out ^2
    out <- mean(out)
    out <- out ^0.5
    return(out)    
}

#debug(rmsdif)

Out <- ddply(
    SS,
    .(method, variable),
    rmsdif
    )

f2  <- function(x){
    out <- x$value
    tmp <- subset(SS, subset=method=="Independent")$value
    out <- out / tmp
    return(out)
}

#debug(f2)

Out2 <- ddply(
    subset(SS, subset=method!="Independent"),
    .(method),
    f2
    )


S2 <- subset(Summaries, subset=method!="Bootstrapped")
S2 <- gdata::remove.vars(S2, names=c("U1_mean", "U1_sd", "U2_mean", "U2_sd", "difference_mean", "difference_sd"))

S3 <- subset(Summaries, subset=method=="Bootstrapped")

S3 <- gdata::remove.vars(S3, names=c("U1_mean", "U1_sd", "U2_mean", "U2_sd", "difference_mean", "difference_sd"))
S3.U1 <- S3[,grep("^U1", names(S3))]
S3.U2 <- S3[,grep("^U2", names(S3))]
S3.diff <- S3[,grep("^diff", names(S3))]


S2.U1 <- S2[,grep("^U1", names(S2))]
S2.U2 <- S2[,grep("^U2", names(S2))]
S2.diff <- S2[,grep("^difference", names(S2))]


# What I want is to calculate root mean square difference between the bootstrapped quantiles and the equivalent 
# quantiles produced by other methods


adply(S2.U1, 1, function(x) (x-S3.U1)^2)


boot.U1 <- subset(Summaries, select=method=="Bootstrapped")
boot.U1 <- boot.U1[,grep("^U1", names(boot.U1))]
apply(S2.U1)

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


