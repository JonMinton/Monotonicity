

summaries_mean_sd <- ddply(
    data_long,
    .(method, variable),
    summarise,
    mean=mean(value),
    sd=sd(value)
    )


boot_only <- subset(data_long, subset=method=="Bootstrapped")
boot_excluded <- subset(data_long, subset=method!="Bootstrapped")

fn <- function(x){
    this_variable <- x$variable[1]
    boot_values <- boot_only$value[boot_only$variable==this_variable]
    
    boot_quantiles <- quantile(
        boot_values,
        seq(from=0.025, 0.975, 0.05)
                               )
    
    this_quantiles <- quantile(
        x$value,
        seq(from=0.025, 0.975, 0.05)
        )
    
    out <- boot_quantiles - this_quantiles
    out <- out^2
    out <- sum(out)
    out <- out^0.5
    return(rms=out)
}

summaries_rms <- ddply(
    boot_excluded,
    .(method, variable),
    fn
    )

summaries_rms <- rename(summaries_rms, replace=c("V1"="rms"))



