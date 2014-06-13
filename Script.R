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

Data_Wide <- cast(Data_Long, method + sample  ~ variable)


g <- ggplot(data=Data_Wide, aes(x=U1, y=U2))
g2 <- g + geom_point() + facet_wrap("method") 
g3 <- g2 + geom_abline(intercept=0, slope=1, colour="red", lty="dashed", size=1.1)
g4 <- g3 + coord_cartesian(xlim=c(0.45,0.7), ylim=c(0.45,0.7)) + coord_fixed()
g4 + xlab("Better health state") + ylab("Worse health state")

# TO DO: 
# make the aspect ratio 1

# Want to create something that shows densities of values:
#U1,
#U2
#U2-U1

# Each time overlays with bootstrapped

Data_Wide <- data.frame(Data_Wide, difference=Data_Wide$U1 - Data_Wide$U2)

# U1
g <- ggplot(subset(Data_Wide, method!="Bootstrapped"), aes(x=U1)) + geom_density(fill="grey")
g2 <- g + facet_wrap("method")
g3 <- g2 + geom_density(aes(x=subset(Data_Wide, method=="Bootstrapped")$U1), col="blue", width=1.1, lty="dashed")
g3

# U2 
g <- ggplot(subset(Data_Wide, method!="Bootstrapped"), aes(x=U2)) + geom_density(fill="grey")
g2 <- g + facet_wrap("method")
g3 <- g2 + geom_density(aes(x=subset(Data_Wide, method=="Bootstrapped")$U2), col="blue", width=1.2, lty="dashed")
g3

# difference 
g <- ggplot(subset(Data_Wide, method!="Bootstrapped"), aes(x=difference)) + geom_density(fill="grey")
g2 <- g + facet_wrap("method")
g3 <- g2 + geom_density(aes(x=subset(Data_Wide, method=="Bootstrapped")$difference), col="blue", width=1.2, lty="dashed")
g3


# Table summaries
C1 <- cast(D2, method ~ variable, function(x) c(mean=mean(x), sd=sd(x), quantile(x, c(0.025, 0.5, 0.975))))

# draw as dotplot

     ggplot(data= subset(C1, method!="Bootstrapped"), aes(x=method, y= U1_X50.,
                                ymin=U1_X2.5., ymax=U1_X97.5.)) + 
         geom_pointrange(size=1.4) + geom_hline(aes(yintercept=subset(C1, method=="Bootstrapped")$U1_X2.5.), lty="dashed") +
    xlab("Method\n") + ylab("\n Quantile Range") +
         coord_flip() + geom_hline(aes(yintercept=subset(C1, method=="Bootstrapped")$U1_X97.5.), lty="dashed") +
    geom_hline(aes(yintercept=subset(C1, method=="Bootstrapped")$U1_X50.))


ggplot(data= subset(C1, method!="Bootstrapped"), aes(x=method, y= U2_X50.,
                                                     ymin=U2_X2.5., ymax=U2_X97.5.)) + 
    geom_pointrange(size=1.4) + geom_hline(aes(yintercept=subset(C1, method=="Bootstrapped")$U2_X2.5.), lty="dashed") +
    xlab("Method\n") + ylab("\n Quantile Range") +
    coord_flip() + geom_hline(aes(yintercept=subset(C1, method=="Bootstrapped")$U2_X97.5.), lty="dashed") +
    geom_hline(aes(yintercept=subset(C1, method=="Bootstrapped")$U2_X50.))

ggplot(data= subset(C1, method!="Bootstrapped"), aes(x=method, y= difference_X50.,
                                                     ymin=difference_X2.5., ymax=difference_X97.5.)) + 
    geom_pointrange(size=1.4) + geom_hline(aes(yintercept=subset(C1, method=="Bootstrapped")$difference_X2.5.), lty="dashed") +
    xlab("Method\n") + ylab("\n Quantile Range") +
    coord_flip() + geom_hline(aes(yintercept=subset(C1, method=="Bootstrapped")$difference_X97.5.), lty="dashed") +
    geom_hline(aes(yintercept=subset(C1, method=="Bootstrapped")$difference_X50.))

C2 <- cast(D2, method ~ variable, function(x) round(c(mean=mean(x), sd=sd(x), quantile(x, seq(from=0.025, to=0.975, by=0.05))), digits=3))


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


