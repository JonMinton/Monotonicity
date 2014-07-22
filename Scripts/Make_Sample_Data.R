

data_long <- make_long(
    data_2d,
    n_psa=N_PSA,
    methods.labels=c(
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
    )
)


data_wide <- cast(data_long, method + sample  ~ variable)
data_wide <- mutate(data_wide, difference = u1 - u2)

data_long <- melt(data_wide, id=c("method", "sample"))

print("made long data")