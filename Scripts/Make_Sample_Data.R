data_summaries <- summarise_ipd(
    data_2d
    )

data_block <- make_block(
    ipd=data_2d,
    summary_data=data_summaries,
    n_psa=N_PSA,
    methods_labels=c(
        "Independent",
        "Quantile Matching",
        "Replication\n(Upwards)",
        "Replication\n(Downwards)",
        "Resampling\n(Upwards)",
        "Resampling\n(Downwards)",
        "AIVM",
        "Covariance Fitting\n(Lower Bounded)",
        "Covariance Fitting\n(Upper Bounded)",
        "Difference\n(Upwards)", 
        "Difference\n(Downwards)"
    ),
    quietly=F
)

data_wide <- ldply(data_block)
data_wide$sample <- 1:N_PSA
data_wide <- rename(data_wide, c(".id"="method"))
data_wide <- mutate(data_wide, difference=u1-u2)
data_wide <- data_wide[c("method", "sample", "u1", "u2", "difference")]
data_wide$method <- factor(
    data_wide$method,
    levels=c(
        "Bootstrapped",
        "Independent",
        "Quantile Matching",
        "Resampling\n(Downwards)",
        "Resampling\n(Upwards)",
        "Replication\n(Downwards)",
        "Replication\n(Upwards)",
        "AIVM",
        "Covariance Fitting\n(Lower Bounded)",
        "Covariance Fitting\n(Upper Bounded)",
        "Difference\n(Downwards)",
        "Difference\n(Upwards)"
    )
)
data_long <- melt(data_wide, id.var=c("method", "sample"))

print("finished making wide and long data")

