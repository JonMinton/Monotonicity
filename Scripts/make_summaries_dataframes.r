

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

Summaries.RMS <- arrange(Summaries.RMS, var, method)

Summaries.RMS <- rename.vars(Summaries.RMS, from="V1", to="value")

Summaries.RMS$method <- factor(Summaries.RMS$method,
                               levels=rev(levels(Summaries.RMS$method))
)
