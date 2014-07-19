
summaries_mean_sd <- cast(
    data_long, 
    method ~ variable, 
    function(x) c(mean=mean(x), sd=sd(x))
)

summaries_quintiles <- cast(
    data_long,
    method ~ variable,
    quantile,
    seq(from=0.025, to=0.975, by=0.05)
)

summaries_difs <- cbind(
    summaries_quintiles[-1,1],
    adply(summaries_quintiles[-1,-1],1, function(x) ((x - summaries_quintiles[1,-1])^2))
)

names(summaries_difs)[1] <- "method"
summaries_difs_long <- melt(summaries_difs, id.var="method")
summaries_difs_long <- cbind(summaries_difs_long, colsplit(summaries_difs_long$variable, "_", c("var", "quantile")))
summaries_difs_long <- gdata::remove.vars(summaries_difs_long, "variable")

summaries_rms <- ddply(summaries_difs_long, .(method, var),function(x) (rms=mean(x$value))^0.5)

summaries_rms <- arrange(summaries_rms, var, method)

summaries_rms <- rename.vars(summaries_rms, from="V1", to="value")

summaries_rms$method <- factor(summaries_rms$method,
                               levels=rev(levels(summaries_rms$method))
)







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

