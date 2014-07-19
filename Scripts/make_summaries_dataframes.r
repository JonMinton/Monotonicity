
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
