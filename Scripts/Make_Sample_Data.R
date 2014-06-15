

Data_Long <- Make_Long(
    Data.2D,
    Methods.labels=c(
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


Data_Wide <- cast(Data_Long, method + sample  ~ variable)
Data_Wide <- data.frame(Data_Wide, difference=Data_Wide$U1 - Data_Wide$U2)

Data_Long <- melt(Data_Wide, id=c("method", "sample"))