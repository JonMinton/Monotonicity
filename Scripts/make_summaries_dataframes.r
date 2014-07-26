
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

summaries_difs_squared <- cbind(
    summaries_quintiles[-1,1],
    adply(summaries_quintiles[-1,-1],1, function(x) ((x - summaries_quintiles[1,-1])^2)) #[1]
)

#[1] What this line does is as follows:
# 1) take the contents of summaries_quintiles, less the first row (bootstrapped quintiles) and the first
# column (names)
# 2) turns this into an array
# 3) says to act on each row of the array separately, corresponding to each method
# 4) says to calculate the squared differences between bootstrapped quantiles and 
# each method's corresponding quintiles,
# 5) return these rows of squared difs as an output, converted to a dataframe


names(summaries_difs_squared)[1] <- "method"
summaries_difs_squared_long <- melt(summaries_difs_squared, id.var="method")
summaries_difs_squared_long <- cbind(summaries_difs_squared_long, colsplit(summaries_difs_squared_long$variable, "_", c("var", "quantile")))
summaries_difs_squared_long <- gdata::remove.vars(summaries_difs_squared_long, "variable")

summaries_rms <- ddply(summaries_difs_squared_long, .(method, var),function(x) (rms=(mean(x$value))^0.5))


summaries_rms <- arrange(summaries_rms, var, method)

summaries_rms <- rename.vars(summaries_rms, from="V1", to="value")

summaries_rms$method <- factor(summaries_rms$method,
                               levels=rev(levels(summaries_rms$method))
)

summaries_rms <- recast(summaries_rms, method ~ var)

summaries_rms <- summaries_rms[c("method", "u1", "u2", "difference")]



