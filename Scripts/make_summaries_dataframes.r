# To do :

summaries_mean_sd <- ddply(
    data_long,
    .(method, variable),
    summarise,
    mean=mean(value),
    sd=sd(value)
    )



fn <- function(x){
    out <- quantile(
        x$value,
        seq(from=0.025, to=0.975, by=0.05)            
    )
    
    out <- out^2
    out <- sum(out)
    out <- out^0.5
    
    return(rms=out)
}

summaries_rms <- ddply(
    data_long,
    .(method, variable),
    summarise,
    rms = (sum(quantile(value, seq(from=0.025, 0.975, by=0.05))^2))^0.5
    )




