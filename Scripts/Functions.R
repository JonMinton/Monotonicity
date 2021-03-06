
zero_one_bounded <- function(
    X_mu, X_var,
    Y_mu, Y_var,
    n_sims = 100000,
    verbose = F
){
    a.Y <- ((1 - Y_mu)* Y_mu / Y_var - 1) * Y_mu
    b.Y <- a.Y * (1 - Y_mu) / Y_mu
    y <- rbeta(n_sims, a.Y, b.Y)
    n.y <- log( y / (1-y) )
    
    if (verbose){
        cat("y has mean of ", mean(n.y), " and var of ", var(n.y), "\n")
    }
    
    a.X <- ((1 - X_mu) * X_mu / X_var - 1) * X_mu
    b.X <- a.X * (1 - X_mu) / X_mu
    
    x <- rbeta(n_sims, a.X, b.X)
    n.x <- log(x / (1-x) )
    
    if (verbose){
        cat("x has mean of ", mean(n.x), " and var of ", var(n.x), "\n")
    }
    
    mu.d <- mean(n.y)  - mean(n.x)
    var.d <- abs(var(n.y) - var(n.x))
    
    if (verbose){
        cat("The variance of y ", ifelse(var(n.y) > var(n.x), "is ", "is not"), 
            "greater than the variance of x\n")
        cat("The difference in means is ", mu.d, "\n")
        cat("The absolute difference in variances is ", var.d, "\n")
    }
    
    s <- mu.d^2 / var.d
    r <- mu.d / var.d
    
    s.d <- rgamma(n_sims, s, r)   #sample d from a gamma 
    if(var(n.y)>var(n.x)){
        s.nx <- rnorm(n_sims,mean(n.x), sqrt(var(n.x)))   #sample logit transformed x from a normal
        s.ny <- s.d + s.nx   
    }
    if(var(n.y)<var(n.x)){
        s.ny<-rnorm(n_sims,mean(n.y),sqrt(var(n.y)))   #sample logit transformed y from a normal
        s.nx<-s.ny - s.d   
    }
    
    s.y <- exp(s.ny) / (1+exp(s.ny))                  #back tranform to get y
    s.x <- exp(s.nx) / (1+exp(s.nx))                  #back tranform to get x
    
    #check the mean and var and min and max of sampled x and y
    
    if (verbose){
        cat("X:\t", mean(s.x), "\t var:\t", var(s.x), "\t(min:\t", min(s.x), "\tmax:\t", max(s.x), "\n")
        cat("Y:\t", mean(s.y), "\t var:\t", var(s.y), "\t(min:\t", min(s.y), "\tmax:\t", max(s.y), "\n")
        
    }
    out <- list(X = s.x, Y = s.y)
    
    return(out)
}



zero_plus_bounded <- function(
    X_mu, X_var,
    Y_mu, Y_var,
    n_sims = 100000,
    verbose = F
){
    
    s.y <- Y_mu^2 / Y_var
    r.y <- Y_mu / Y_var
    y <- rgamma(n_sims, s.y, r.y)
    n.y <- exp(y)
    
    if (verbose){
        cat("y has mean of ", mean(n.y), " and var of ", var(n.y), "\n")
    }
    
    s.x <- X_mu^2 / X_var
    r.x <- X_mu / X_var
    
    x <- rgamma(n_sims,s.x,r.x) # sample y from a gamma
    
    n.x<-exp(x)       #exp transformation to get to real line (unbounded)
    # mean(n.x);var(n.x)  #mean and var after exp transformation
    if (verbose){
        cat("x has mean of ", mean(n.x), " and var of ", var(n.x), "\n")
    }
    
    
    # 
    #n.y=n.x+d since var(logit transormed y)>var(logist transformed x)
    mu.d <- mean(n.y) - mean(n.x)
    v.d <- abs(var(n.y) - var(n.x))
    
    s <- mu.d^2 / v.d
    r <- mu.d   / v.d
    
    s.d <- rgamma(n_sims, s, r)  #sample d from a gamma 

    if(var(n.y)>var(n.x)){
        s.nx <- rnorm(n_sims,mean(n.x), sqrt(var(n.x)))   #sample exp transformed x from a normal
        s.ny <- s.d + s.nx   
    }
    
    if(var(n.y)<var(n.x)){
        
        s.ny<-rnorm(n_sims,mean(n.y),sqrt(var(n.y)))   #sample exp transformed y from a normal
        s.nx<-s.ny - s.d   
        
    }
    
    s.y <- log(s.ny)                  #back tranform to get y
    s.x <- log(s.nx)                  #back tranform to get x
    
    
    if (verbose){
        cat("The variance of y ", ifelse(var(n.y) > var(n.x), "is ", "is not"), 
            "greater than the variance of x\n")  
        cat("X:\t", mean(s.x), "\t var:\t", var(s.x), "\t(min:\t", min(s.x), "\tmax:\t", max(s.x), "\n")
        cat("Y:\t", mean(s.y), "\t var:\t", var(s.y), "\t(min:\t", min(s.y), "\tmax:\t", max(s.y), "\n")
        
    }
    
    
    out <- list(X = s.x, Y = s.y)
    return(out)
}



# Functions file

bootstrap_means_ipd <- function(
    data,
    n_reps
    ){
    n_vars <- dim(data)[2]
    n_obs <- dim(data)[1]
    draws <- 1:n_reps
    output <- matrix(NA, nrow=n_reps, ncol=n_vars)
    for (i in 1:n_reps){
        boot.this <- data[sample(1:n_obs, n_obs, T),]
        for (j in 1:n_vars){
            output[i,j] <- mean(boot.this[,j])
        }
    }
    colnames(output) <- colnames(data)
    output <- as.data.frame(output)
    return(output)
}


est_beta <- function(mu, var) {
    a <- mu * ((1 - mu) * (mu / var) - 1)
    b <- a * ((1 - mu) / mu)
    return(list(a=a, b=b))
}



get_dif_param <- function(
    u1_mu, u1_sd, 
    u2_mu, u2_sd, 
    quietly=T
    ){
    mu <- u1_mu - u2_mu
    
    sigma2 <- ifelse(u1_sd > u2_sd, u1_sd^2 - u2_sd^2, u2_sd^2 - u1_sd^2)
    x <- (1 - mu) / mu
    
    a <- (x/sigma2-1-2*x-x^2)/(1+3*x+3*x^2+x^3)
    b<-a*x
    
    if(quietly==F){
        print(a/(a+b))  # check mean of delta
        print(a*b/(a+b)^2/(a+b+1))  # check variance of delta    
    }
    return(list(a=a, b=b))
}

make_aivm_cov_2d <- function(
    mu_x, sd_x, 
    mu_y, sd_y, 
    colnames_,
    n_psa_=n_psa
    ){
    
    var_x <- sd_x^2
    var_y <- sd_y^2
    
    aivm <- min(
        mean(
            c(var_x, var_y)
        ),
        sd_x * sd_y)
    
    
    sig <- matrix(
        data=c(
            var_x, aivm, 
            aivm, var_y
            ), 
        nrow=2, byrow=T
        )
    
    aivm_samples <-   mvrnorm(
        n=n_psa_, 
        mu=c(mu_x, mu_y), 
        Sigma=sig 
        )
    
    colnames(aivm_samples) <- colnames_
    aivm_samples <- as.data.frame(aivm_samples)
    return(
        list(
            aivm_samples=aivm_samples, 
            aivm=aivm)
        )
}

make_bcvr_2d <- function(
    mu_x, sd_x, 
    mu_y, sd_y, 
    n_psa_, 
    inc_by=0.00001, 
    colnames_,
    upper=T,
    quietly=T
    ){    
    if (!quietly){
        print("make_bcvr_2d entered")
        cat("upper is set to ", upper, "\n")
    }
    
    var_x <- sd_x^2 # variance of X
    var_y <- sd_y^2 # variance of Y
    
    if (!quietly){
        cat("var_x is ", var_x, " and var_y is ", var_y, "\n")
    }
    
    if(upper==T){
        lowerbound <- 0 # start assuming independent
        upperbound <- min(sd_x * sd_y,
                          mean(var_y, var_y)
        ) # upper bounds are the minimum of the AIVM or the cov which implies a cor > 1
        
        if (!quietly){
            cat("upper bounded. Looking for values between ", lowerbound, " and ", upperbound, "\n")
        }
        
    } else {
        lowerbound <- mean(var_x, var_y)
        upperbound <- sd_x * sd_y # don't select a covariance which implies a correlation > 1
        
        if (!quietly){
            cat("lower bounded. Looking for values between ", lowerbound, "and ", upperbound, "\n")
        }
    }
    
      
    cov.this <- lowerbound

    mus <- c(mu_x, mu_y)
    search <- T
    
    if(cov.this <= upperbound){ # if the maximum value's been reached already
        
        cat("Upperbound already reached\n")
        search <- F # if the upper limit's already been reached, go no further
        
        testsig <- matrix(
            c(
                var_x, cov.this, 
                cov.this, var_y
                ), nrow=2, byrow=T
            )
        
        testsamples <- mvrnorm(n_psa_, mu=mus, Sigma=testsig)
    } else {
        cat("Upperbound not yet reached\n")
        this.cov <- lowerbound
        cat("This covariance: ", cov.this, "\n", sep="")
        testsig <- matrix(
            c(
                var_x, cov.this, 
                cov.this, var_y
            ), nrow=2, byrow=T
        )
        
        testsamples <- mvrnorm(n_psa_, mu=mus, Sigma=testsig)
    }
    
    while(search==T){
        cat("trying ", cov.this, "\n")
        testsig <- matrix(
            c(
                var_x, cov.this, 
                cov.this, var_y
                ), nrow=2, byrow=T
            )
        
        try_testsamples <- try(mvrnorm(n_psa_, mu=mus, Sigma=testsig))
        if(class(try_testsamples)=="try-error"){ # if mvrnorm has been passed impossible values
            search <- F
            cat("Error picked up\n")
            
        } else {
            cat("No error in mvrnorm args\n")
            testsamples <- try_testsamples # if the attempted values are correct, use them
            if (any(testsamples[,1] < testsamples[,2])){
                cat("Violation with ", cov.this, "\n")
                cov.this <- cov.this + inc_by # increment the values by a little bit
                cat("Trying ", cov.this, "\n")
            } else {
                cat("Found ", cov.this, "\n")
                search <- F
            }
        }
    }

    cor.this <- cov.this / (sd_x * sd_y)

    colnames(testsamples)=colnames_
    return(
        list(cov=cov.this, 
             samples=testsamples, 
             cor=cor.this)
        )
}


create_draws <- function(
    summary_data,
    method,
    n_psa=100000,
    seed=80,
    quietly=F
    ){
    # summary_data should be a list
    # The top level should be the number of variables to estimate
    n_vars <- length(summary_data)
    output <- matrix(NA, nrow=n_psa, ncol=n_vars)
    colnames(output) <- names(summary_data)
    
    if (method==1){
        ## Method 1 : Independent Sampling (Naive)
        for (i in 1:n_vars){
            params.this <- est_beta(
                summary_data[[i]]$mu,
                summary_data[[i]]$se^2
                )
            draws.this <- rbeta(
                n_psa,
                params.this$a,
                params.this$b
                )
            output[,i] <- draws.this
        }
    }
    
    if (method==2){
        ## Method 2 : Quantile matching/same random number seed        
        seeds <- runif(n_psa)
        for (i in 1:n_vars){
            params.this <- est_beta(
                summary_data[[i]]$mu,
                summary_data[[i]]$se^2
            )            
            draws.this <- qbeta(
                seeds,
                params.this$a,
                params.this$b
            )
            output[,i] <- draws.this
        }

    }
    
    if (method==3){
        ## Method 3 : Upward Replacement
        for (i in 1:n_vars){
            params.this <- est_beta(
                summary_data[[i]]$mu,
                summary_data[[i]]$se^2
            )
            draws.this <- rbeta(
                n_psa,
                params.this$a,
                params.this$b
            )
            
            if (i > 1){
                violations <- draws.this > output[,i-1]
                draws.this[violations] <- output[violations,i-1]
            }
            output[,i] <- draws.this
        }
        
    }
    
    if (method==4){
        ## Method 4 : Downward Replacement
        for (i in n_vars:1){
            params.this <- est_beta(
                summary_data[[i]]$mu,
                summary_data[[i]]$se^2
                )
            draws.this <- rbeta(
                n_psa,
                params.this$a, 
                params.this$b
                )
            if (i < n_vars){
                violations <- draws.this < output[,i+1]
                draws.this[violations] <- output[violations, i + 1]
            }
            output[,i] <- draws.this
        }
    }
    
    if (method==5){
        ## Method 5 : Upwards Resampling
        for (i in 1:n_vars){
            params.this <- est_beta(
                summary_data[[i]]$mu, 
                summary_data[[i]]$se^2
                )
            if (i ==1){
                output[,1] <- rbeta(
                    n_psa,
                    params.this$a,
                    params.this$b
                    )
                
            } else {
                for (j in 1:n_psa){
                    continue <- F
                    while(continue==F){
                        val.this <- rbeta(1, 
                                          params.this$a,
                                          params.this$b
                                          )
                        if (val.this <= output[j,i-1]){
                            output[j, i] <- val.this
                            continue <- T
                        }
                    }
                }
            }
        }
    }
    
    if (method==6){
        ## Method 6 : Downwards Resampling
        
        for (i in n_vars:1){
            params.this <- est_beta(
                summary_data[[i]]$mu, 
                summary_data[[i]]$se^2
            )
            if (i == n_vars){
                output[,n_vars] <- rbeta(
                    n_psa,
                    params.this$a,
                    params.this$b
                )
                
            } else {
                for (j in 1:n_psa){
                    continue <- F
                    while(continue==F){
                        val.this <- rbeta(1, 
                                          params.this$a,
                                          params.this$b
                        )
                        if (val.this >= output[j,i+1]){
                            output[j, i] <- val.this
                            continue <- T
                        }
                    }
                }
            }
        }
    }
    if (method==7){
        ## Method 7 : Resample, both ways
        for (i in 1:(n_vars-1)){
            params_first <- est_beta(
                summary_data[[i]]$mu, 
                summary_data[[i]]$se^2
            )
            
            params_second <- est_beta(
                summary_data[[i+1]]$mu,
                summary_data[[i+1]]$se^2
                )
                                
            for (j in 1:n_psa){
                repeat {
                    candidate_first <- rbeta(1, params_first$a, params_first$b)
                    candidate_second <- rbeta(1, params_second$a, params_second$b)
                    if (candidate_first >= candidate_second) {break}
                }
                output[j, i] <- candidate_first
                output[j, i+1] <- candidate_second
            }
        }
    }
    if (method==8){
        ## Method 7 : AIVM Covariance
        if (n_vars!=2) stop("Only two parameters allowed with this method")
        
        output <- make_aivm_cov_2d(
            mu_x=summary_data[[1]]$mu,
            sd_x=summary_data[[1]]$se,
            mu_y=summary_data[[2]]$mu,
            sd_y=summary_data[[2]]$se,
            colnames_=names(summary_data),
            n_psa_=n_psa
            )$aivm_samples
    }
    
    if (method==9){
        ## Method 8 : Lower bounded covariance retrofitting
        
        if (n_vars!=2) stop("Only two parameters allowed with this method")
        
        output <- as.data.frame(
            make_bcvr_2d(
                mu_x=summary_data[[1]]$mu,
                sd_x=summary_data[[1]]$se,
                mu_y=summary_data[[2]]$mu,
                sd_y=summary_data[[2]]$se,
                n_psa_=n_psa,
                upper=F,
                colnames_=names(summary_data),
                quietly=quietly
            )$samples
        )
                
    }
    
    if (method==10){
        ## Method 9 : Upper Bounded covariance retrofitting
        if (n_vars!=2) stop("Only two parameters allowed with this method")
        
        output <- as.data.frame(   
            make_bcvr_2d(
                mu_x=summary_data[[1]]$mu,
                sd_x=summary_data[[1]]$se,
                mu_y=summary_data[[2]]$mu,
                sd_y=summary_data[[2]]$se,
                n_psa_=n_psa,
                upper=T,
                colnames_=names(summary_data),
                quietly=quietly
            )$samples
        )
        
    }
    
    if (method==11){
        ## Method 10: Beta distribution difference modelling : upwards

                # lowest value is reference
                params.this <- est_beta(
                    summary_data[[1]]$mu, 
                    summary_data[[1]]$se^2
                )
                
                draws_ref <- rbeta(
                    n_psa, 
                    params.this$a,
                    params.this$b
                    )
                output[,1] <- draws_ref
                
                for (i in 2:n_vars){
                    
                    dif_params.this <- get_dif_param(
                        summary_data[[i-1]]$mu, 
                        summary_data[[i-1]]$se,
                        
                        summary_data[[i]]$mu,
                        summary_data[[i]]$se
                        )
                    
                    deltas.this <- rbeta(
                        n_psa,
                        dif_params.this$a,
                        dif_params.this$b
                        )
                    
                    output[,i] <- output[,i-1] - deltas.this
                }
                
            }
    
    if (method == 12){
        # Beta, downwards
        params.this <- est_beta(
            summary_data[[n_vars]]$mu, 
            summary_data[[n_vars]]$se^2
        )
        draws_ref <- rbeta(
            n_psa, 
            params.this$a,
            params.this$b
        )
        output[,n_vars] <- draws_ref
            
        for (i in n_vars:2){
            
            dif_params.this <- get_dif_param(
                summary_data[[i-1]]$mu, 
                summary_data[[i-1]]$se,
                
                summary_data[[i]]$mu,
                summary_data[[i]]$se
            )
            
            deltas.this <- rbeta(
                n_psa,
                dif_params.this$a,
                dif_params.this$b
            )
        
            output[,i-1] <- output[,i] + deltas.this
        }
    }
    
    if (method == 13){
        # zero_one_bounded
        
        out <- zero_one_bounded(
            X_mu = summary_data[[1]]$mu,
            X_var = summary_data[[1]]$se^2,
            Y_mu = summary_data[[2]]$mu,
            Y_var = summary_data[[2]]$se^2,
            
            n_sims = n_psa
        )
        
        output <- data.frame(
            x = out$X, y = out$Y
        )
    }
    if (method == 14){
        # zero_plus_bounded
        
        out <- zero_plus_bounded(
            X_mu = summary_data[[1]]$mu,
            X_var = summary_data[[1]]$se^2,
            Y_mu = summary_data[[2]]$mu,
            Y_var = summary_data[[2]]$se^2,
            
            n_sims = n_psa
        )
        
        output <- data.frame(
            x = out$X, y = out$Y
        )
    }
    
    ###
    return(data.frame(output))
}



# Function for producing Long Data with all methods, given only the Summary data and IPD

make_block <- function(
    ipd=NULL,
    summary_data_=NULL,
    n_psa=1000,
    methods_to_use=1:14,
    methods_labels=c(
        "Independent",
        "Quantile Matching",
        "Replication\n(Upwards)",
        "Replication\n(Downwards)",
        "Resampling\n(Upwards)",
        "Resampling\n(Downwards)",
        "Resampling\n(Both)",
        "Average Individual Variances",
        "Covariance Fitting\n(Lower Bounded)",
        "Covariance Fitting\n(Upper Bounded)",
        "Difference\n(Upwards)", 
        "Difference\n(Downwards)",
        "Zero_one_bounded", 
        "Zero_plus_bounded"
        ),
    quietly=F
    ){
    # Cases:
    # 1) IPD but no Sum
    # 2) Sum but not IPD
    # 3) Sum and IPD
    
    if (!is.null(ipd)){
        print("Making bootstraps using IPD")
        psa_boot <- bootstrap_means_ipd(
            ipd,
            n_reps=n_psa
        )
        variable_labels <- colnames(psa_boot)
        if (is.null(summary_data_)){
            print("summary_data_ not found, so making summary_data from ipd")
            summary_data_ <<- summarise_ipd(
                ipd
                )
            
        }
        if (!(exists("variable_labels"))){
            variable_labels <- colnames(summary_data_)
        }
    }
    
    n_methods <- length(methods_to_use)
    
    methods_block <- vector("list", length=n_methods)
    
    names(methods_block) <- methods_labels
    

    print("iterating through methods")
    for (i in 1:n_methods){
        cat("about to create method ", i, "\n")
        methods_block[[i]] <- as.data.frame(
            create_draws(
            summary_data=summary_data_,
            method=i,
            n_psa=n_psa,
            quietly=quietly
            )
        )

    }

    # add bootstrapped onto end of methodsblock
    methods_block[[length(methods_block) + 1]] <- psa_boot
    names(methods_block)[length(methods_block)] <- "Bootstrapped"

    return(methods_block)
    
}


