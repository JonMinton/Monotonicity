# Functions file

Summarise_IPD <- function(
    Data,
    n.dp=3
    ){
    n.vars <- dim(Data)[2]
    n.obs <- dim(Data)[1]
    output <- vector("list", length=n.vars)
    names(output) <- colnames(Data)
    
    for (i in 1:n.vars){
        this.mu <- round(mean(Data[,i]), n.dp)
        this.upper <- mean(Data[,i]) + 1.96*sd(Data[,i])/sqrt(n.obs)
        this.se <- round(
            (this.upper - mean(Data[,i]))/1.96,
            3)
        
        this.list <- list(
            mu=this.mu,
            se=this.se
            )
        output[[i]] <- this.list
    }
    return(output)    
}

Bootstrap_Means_IPD <- function(
    Data,
    n.reps
    ){
    n.vars <- dim(Data)[2]
    n.obs <- dim(Data)[1]
    draws <- 1:n.reps
    output <- matrix(NA, nrow=n.reps, ncol=n.vars)
    for (i in 1:n.reps){
        this.boot <- Data[sample(1:n.obs, n.obs, T),]
        for (j in 1:n.vars){
            output[i,j] <- mean(this.boot[,j])
        }
    }
    colnames(output) <- colnames(Data)
    output <- as.data.frame(output)
    return(output)
}


Est_Beta <- function(mu, var) {
    a <- mu * ((1 - mu) * (mu / var) - 1)
    b <- a * ((1 - mu) / mu)
    return(list(a=a, b=b))
}



Get_Dif_Param <- function(
    u1.mu, u1.sd, 
    u2.mu, u2.sd, 
    quietly=T
    ){
    mu <- u1.mu - u2.mu
    
    sigma2 <- ifelse(u1.sd > u2.sd, u1.sd^2 - u2.sd^2, u2.sd^2 - u1.sd^2)
    x <- (1 - mu) / mu
    
    a <- (x/sigma2-1-2*x-x^2)/(1+3*x+3*x^2+x^3)
    b<-a*x
    
    if(quietly==F){
        print(a/(a+b))  # check mean of delta
        print(a*b/(a+b)^2/(a+b+1))  # check variance of delta    
    }
    return(list(a=a, b=b))
}

Make_AIVM_Cov_2D <- function(
    mu.X, sd.X, 
    mu.Y, sd.Y, 
    colnames_,
    n.psa_=n.psa
    ){
    
    varX <- sd.X^2
    varY <- sd.Y^2
    
    aivm <- min(
        mean(
            c(varX, varY)
        ),
        sd.X * sd.Y)
    
    sig <- matrix(data=c(varX, aivm, aivm, varY), nrow=2, byrow=T)
    
    aivm.samples <-   mvrnorm(n=n.psa_, mu=c(mu.X, mu.Y), Sigma=sig )
    colnames(aivm.samples) <- colnames_
    aivm.samples <- as.data.frame(aivm.samples)
    return(
        list(
            aivm.samples=aivm.samples, 
            aivm=aivm)
        )
}

Make_BCVR_2D <- function(
    mu.X, sd.X, 
    mu.Y, sd.Y, 
    n.psa_=n.psa, 
    incBy=0.00001, 
    colnames_,
    upper=T
    ){    
    varX <- sd.X^2 # variance of X
    varY <- sd.Y^2 # variance of Y
    if(upper==T){
        lowerbound <- 0 # start assuming independent
        upperbound <- min(sd.X * sd.Y,
                          mean(varX, varY)
        ) # upper bounds are the minimum of the AIVM or the cov which implies a cor > 1
    } else {
        lowerbound <- mean(varX, varY)
        upperbound <- sd.X * sd.Y # don't select a covariance which implies a correlation > 1
    }
    
      
    this.cov <- lowerbound
    cat(varX, varY, lowerbound, upperbound, this.cov, "\n")
    mus <- c(mu.X, mu.Y)
    search <- T
    
    if(this.cov==upperbound){ # if the maximum value's been reached already
        
        cat("Upperbound already reached\n")
        search <- F # if the upper limit's already been reached, go no further
        testsig <- matrix(c(varX, this.cov, this.cov, varY), nrow=2, byrow=T)
        testsamples <- mvrnorm(n.psa_, mu=mus, Sigma=testsig)
    } else {
        cat("Upperbound not yet reached\n")
        this.cov <- lowerbound
        cat("This covariance: ", this.cov, "\n", sep="")
        testsig <- matrix(c(varX, this.cov, this.cov, varY), nrow=2, byrow=T)
        testsamples <- mvrnorm(n.psa_, mu=mus, Sigma=testsig)
    }
    
    while(search==T){
        cat("trying ", this.cov, "\n")
        testsig <- matrix(c(varX, this.cov, this.cov, varY), nrow=2, byrow=T)
        try.testsamples <- try(mvrnorm(n.psa_, mu=mus, Sigma=testsig))
        if(class(try.testsamples)=="try-error"){ # if mvrnorm has been passed impossible values
            search <- F
            cat("Error picked up\n")
            
        } else {
            cat("No error in mvrnorm args\n")
            testsamples <- try.testsamples # if the attempted values are correct, use them
            if (any(testsamples[,1] < testsamples[,2])){
                cat("Violation with ", this.cov, "\n")
                this.cov <- this.cov + incBy # increment the values by a little bit
                cat("Trying ", this.cov, "\n")
            } else {
                cat("Found ", this.cov, "\n")
                search <- F
            }
        }
    }
    this.cor <- this.cov / (sd.X * sd.Y)
    colnames(testsamples)=colnames_
    return(
        list(cov=this.cov, 
             samples=testsamples, 
             cor=this.cor)
        )
}

# NOTE: After getting this to work, add a 'recursive' option for methods 7 onwards


Create_Draws <- function(
    Sum_Data,
    method,
    n.psa=1000,
    ###
    seed=80,
    direction="up",
    ...
    ){
    # Sum_Data should be a list
    # The top level should be the number of variables to estimate
    n.vars <- length(Sum_Data)
    output <- matrix(NA, nrow=n.psa, ncol=n.vars)
    colnames(output) <- names(Sum_Data)
    
    if (method==1){
        ## Method 1 : Independent Sampling (Naive)
        for (i in 1:n.vars){
            this.params <- Est_Beta(
                Sum_Data[[i]]$mu,
                Sum_Data[[i]]$se^2
                )
            this.draws <- rbeta(
                n.psa,
                this.params$a,
                this.params$b
                )
            output[,i] <- this.draws
        }
    }
    
    if (method==2){
        ## Method 2 : Quantile matching/same random number seed        

        for (i in 1:n.vars){
            this.params <- Est_Beta(
                Sum_Data[[i]]$mu,
                Sum_Data[[i]]$se^2
            )
            set.seed(seed)
            this.draws <- rbeta(
                n.psa,
                this.params$a,
                this.params$b
            )
            output[,i] <- this.draws
        }

    }
    
    if (method==3){
        ## Method 3 : Upward Replacement
        for (i in 1:n.vars){
            this.params <- Est_Beta(
                Sum_Data[[i]]$mu,
                Sum_Data[[i]]$se^2
            )
            this.draws <- rbeta(
                n.psa,
                this.params$a,
                this.params$b
            )
            
            if (i > 1){
                violations <- this.draws > output[,i-1]
                this.draws[violations] <- output[violations,i-1]
            }
            output[,i] <- this.draws
        }
        
    }
    
    if (method==4){
        ## Method 4 : Downward Replacement
        for (i in n.vars:1){
            this.params <- Est_Beta(
                Sum_Data[[i]]$mu,
                Sum_Data[[i]]$se^2
                )
            this.draws <- rbeta(
                n.psa,
                this.params$a, 
                this.params$b
                )
            if (i < n.vars){
                violations <- this.draws < output[,i+1]
                this.draws[violations] <- output[violations, i + 1]
            }
            output[,i] <- this.draws
        }
    }
    
    if (method==5){
        ## Method 5 : Upward Resampling

        # METHOD 5: UPWARDS RESAMPLING
        for (i in 1:n.vars){
            this.params <- Est_Beta(
                Sum_Data[[i]]$mu, 
                Sum_Data[[i]]$se^2
                )
            if (i ==1){
                output[,1] <- rbeta(
                    n.psa,
                    this.params$a,
                    this.params$b
                    )
                
            } else {
                for (j in 1:n.psa){
                    continue <- F
                    while(continue==F){
                        this.val <- rbeta(1, 
                                          this.params$a,
                                          this.params$b
                                          )
                        if (this.val < output[j,i-1]){
                            output[j, i] <- this.val
                            continue <- T
                        }
                    }
                }
            }
        }
    }
    
    if (method==6){
        ## Method 6 : Upward Resampling
        
        for (i in n.vars:1){
            this.params <- Est_Beta(
                Sum_Data[[i]]$mu, 
                Sum_Data[[i]]$se^2
            )
            if (i == n.vars){
                output[,n.vars] <- rbeta(
                    n.psa,
                    this.params$a,
                    this.params$b
                )
                
            } else {
                for (j in 1:n.psa){
                    continue <- F
                    while(continue==F){
                        this.val <- rbeta(1, 
                                          this.params$a,
                                          this.params$b
                        )
                        if (this.val > output[j,i+1]){
                            output[j, i] <- this.val
                            continue <- T
                        }
                    }
                }
            }
        }
    }
    
    
    if (method==7){
        ## Method 7 : AIVM Covariance
        if (n.vars!=2) stop("Only two parameters allowed with this method")
        
        output <- Make_AIVM_Cov_2D(
            mu.X=Sum_Data[[1]]$mu,
            sd.X=Sum_Data[[1]]$se,
            mu.Y=Sum_Data[[2]]$mu,
            sd.Y=Sum_Data[[2]]$se,
            colnames_=names(Sum_Data)
            )$aivm.samples
        
    }
    
    if (method==8){
        ## Method 8 : Lower bounded covariance retrofitting
        
        if (n.vars!=2) stop("Only two parameters allowed with this method")
        
        output <- Make_BCVR_2D(
            mu.X=Sum_Data[[1]]$mu,
            sd.X=Sum_Data[[1]]$se,
            mu.Y=Sum_Data[[2]]$mu,
            sd.Y=Sum_Data[[2]]$se,
            upper=F,
            colnames_=names(Sum_Data)
        )$samples
                
    }
    
    if (method==9){
        ## Method 9 : Upper Bounded covariance retrofitting
        if (n.vars!=2) stop("Only two parameters allowed with this method")
        output <- Make_BCVR_2D(
            mu.X=Sum_Data[[1]]$mu,
            sd.X=Sum_Data[[1]]$se,
            mu.Y=Sum_Data[[2]]$mu,
            sd.Y=Sum_Data[[2]]$se,
            upper=T,
            colnames_=names(Sum_Data)
        )$samples
        
        
    }
    
    if (method==10){
        ## Method 10: Beta distribution difference modelling
        if (!exists("direction")) {
            stop("The variable direction must be specified for this method")
        } else {
            if (direction=="up"){
                # lowest value is reference
                this.params <- Est_Beta(
                    Sum_Data[[1]]$mu, 
                    Sum_Data[[1]]$se^2
                )
                
                draws.ref <- rbeta(
                    n.psa, 
                    this.params$a,
                    this.params$b
                    )
                output[,1] <- draws.ref
                
                for (i in 2:n.vars){
                    
                    this.dif_params <- Get_Dif_Param(
                        Sum_Data[[i-1]]$mu, 
                        Sum_Data[[i-1]]$se,
                        
                        Sum_Data[[i]]$mu,
                        Sum_Data[[i]]$se
                        )
                    
                    this.deltas <- rbeta(
                        n.psa,
                        this.dif_params$a,
                        this.dif_params$b
                        )
                    
                    output[,i] <- output[,i-1] + this.deltas
                }
                
            } else if (direction=="down"){
                this.params <- Est_Beta(
                    Sum_Data[[n.vars]]$mu, 
                    Sum_Data[[n.vars]]$se^2
                )
                draws.ref <- rbeta(
                    n.psa, 
                    this.params$a,
                    this.params$b
                )
                output[,n.vars] <- draws.ref
                
                for (i in n.vars:2){
                    
                    this.dif_params <- Get_Dif_Param(
                        Sum_Data[[i-1]]$mu, 
                        Sum_Data[[i-1]]$se,
                        
                        Sum_Data[[i]]$mu,
                        Sum_Data[[i]]$se
                    )
                    
                    this.deltas <- rbeta(
                        n.psa,
                        this.dif_params$a,
                        this.dif_params$b
                    )
                    
                    output[,i-1] <- output[,i] - this.deltas
                }
                
                
            } else stop("value of direction not valid: must be either down or up")
            
        }
    
    }
    
    ###
    return(output)
}



# Function for producing Long Data with all methods, given only the Summary data and IPD

Make_Long <- function(
    IPD=NULL,
    Sum_Data_=NULL,
    n.psa=1000,
    Methods_to_Use=1:11,
    Methods.labels=c(
        "Independent",
        "Quantile Matching",
        "Replication (Upwards)",
        "Replication (Downwards",
        "Resampling (Upwards)",
        "Resampling (Downwards)",
        "Average Individual Variances",
        "Covariance Fitting (Lower Bounded)",
        "Covariance Fitting (Upper Bounded)",
        "Difference (Upwards)", 
        "Difference (Downwards)"
        ),
    ...
    ){
    # Cases:
    # 1) IPD but no Sum
    # 2) Sum but not IPD
    # 3) Sum and IPD
    
    if (!is.null(IPD)){
        print("Making bootstraps using IPD")
        PSA.Boot <- Bootstrap_Means_IPD(
            IPD,
            n.reps=n.psa
        )
        Variable.labels <- colnames(PSA.Boot)
        if (is.null(Sum_Data_)){
            print("Sum_Data_ not found, so making Sum_Data from IPD")
            Sum_Data_ <- Summarise_IPD(
                IPD
                )
            
        }
        if (!(exists("Variable.labels"))){
            Variable.labels <- colnames(Sum_Data_)
        }
    }
    
    n.methods <- length(Methods_to_Use)
    
    Methods_Block <- vector("list", length=n.methods)
    
    names(Methods_Block) <- Methods.labels
    
    Output <- data.frame(
        method=c(),
        variable=c(),
        value=c()
        )
    
    if (exists("PSA.Boot")){
        tmp <- reshape::melt(
            data.frame(PSA.Boot),
            measure.vars=Variable.labels
            )
        tmp <- data.frame(
            method="Bootstrapped",
            tmp
            )
        
        Output <- rbind(
            Output,
            tmp
            )
    }
    
    for (i in 1:n.methods){
        Methods_Block[[i]] <- Create_Draws(
            Sum_Data=Sum_Data_,
            method=i
            )
        
        
        tmp <- reshape::melt(
            data.frame(Methods_Block[[i]]),
            measure.vars=Variable.labels
        )
        
        tmp <- data.frame(
            method=Methods.labels[i],
            tmp
            )
                
        Output <- rbind(
            Output, 
            tmp
        )
        
    }
    
    return(Output)
    
}

# 
# 
# ############################################################################################################################
# ######################## METHODS ###########################################################################################
# ############################################################################################################################
# 
# 
# # 2d case first, then 3d case
# 
# # changed my mind: now just going to look at 2d case
# 
# 
# 
# 
# plot(u2 ~ u1, data=PSA.method01, xlim=c(0.45, 0.7), ylim=c(0.45,0.7))
# abline(0,1)
# 
# # METHOD 2: SAME RANDOM NUMBER SEED
# 
# # Illustration of issue with random number stream and beta distribution
# 
# # non-problematic run:
# 
# 
# 
# # PSA.method02 <-  data.frame(u1=u1, u2=u2)
# # rm(u1, u2)
# # 
# # plot(u2 ~ u1, data=PSA.method02, xlim=c(0.45, 0.7), ylim=c(0.45,0.7))
# # abline(0,1)
# # 
# # 
# # # METHOD 3: UPWARD REPLACEMENT
# # 
# # u1 <- rbeta(n.PSA, u1.param$a, u1.param$b)
# # u2 <- rbeta(n.PSA, u2.param$a, u2.param$b)
# # 
# # u1[u1 < u2] <- u2[u1 < u2]
# # PSA.method03 <- data.frame(u1=u1, u2=u2)
# # rm(u1, u2)
# # plot(u2 ~ u1, data=PSA.method03, xlim=c(0.45, 0.7), ylim=c(0.45,0.7))
# # abline(0,1)
# # 
# # # METHOD 4: DOWNWARD REPLACEMENT
# # 
# # u1 <- rbeta(n.PSA, u1.param$a, u1.param$b)
# # u2 <- rbeta(n.PSA, u2.param$a, u2.param$b)
# # u2[u2 > u1] <- u1[u2 > u1]
# # 
# # PSA.method04 <- data.frame(u1=u1, u2=u2)
# # rm(u1, u2)
# # 
# # plot(u2 ~ u1, data=PSA.method04, xlim=c(0.45, 0.7), ylim=c(0.45,0.7))
# # abline(0,1)
# 
# # 
# # # METHOD 5: UPWARDS RESAMPLING
# # 
# # u1 <- rbeta(n.PSA, u1.param$a, u1.param$b)
# # u2 <- rep(NA, n.PSA)
# # 
# # for (i in 1:n.PSA){
# #     continue <- F
# #     while(continue==F){
# #         this.u2 <- rbeta(1, u2.param$a, u2.param$b)
# #         if (this.u2 < u1[i]){
# #             u2[i] <- this.u2
# #             continue <- T
# #         }
# #     }
# # }
# # 
# # PSA.method05 <- data.frame(u1=u1, u2=u2)
# # 
# # rm(u1, u2)
# # plot(u2 ~ u1, data=PSA.method05, xlim=c(0.45, 0.7), ylim=c(0.45,0.7))
# # abline(0,1)
# # 
# # # METHOD 6: DOWNWARDS RESAMPLING [?]
# # 
# # u1 <- rep(NA, n.PSA)
# # u2 <- rbeta(n.PSA, u2.param$a, u2.param$b)
# # 
# # for (i in 1:n.PSA){
# #     continue <- F
# #     while(continue==F){
# #         this.u1 <- rbeta(1, u1.param$a, u1.param$b)
# #         if (this.u1 > u2[i]){
# #             u1[i] <- this.u1
# #             continue <- T
# #         }
# #     }
# # }
# # 
# # PSA.method06 <- data.frame(u1=u1, u2=u2)
# # 
# # rm(u1, u2)
# 
# # METHOD 7: AIVM COVARIANCE
# 
# # Correlation(X, Y) := covariance (X, Y) / (sd(X) * sd(Y))
# # So, when correlation = 1
# # covariance(X, y) = sd(X) * sd(Y)
# # This defines the upper limit on the values
# 
# # Function
# 
# 
# 
# #plot(u2 ~ u1, data=PSA.method07)
# 
# # METHOD 8: Lower Bounded Covariance Retrofitting
# # METHOD 9: Upper Bounded Covariance Retrofitting
# 
# # Lowerbounded (method 8) : use upper=F
# # Otherwise (method 9) use default:  upper=T
# # 
# # 
# # 
# # names(PSA.method08) <- c("u1", "u2")
# # 
# # tmp <- MakeBCVR.2d(
# #     mu.X=U1.summary$mu,
# #     sd.X=U1.summary$sd,
# #     mu.Y=U2.summary$mu,
# #     sd.Y=U2.summary$sd
# # )
# # 
# # method09.cov <- tmp$cov
# # method09.cor <- tmp$cor
# # 
# # 
# # PSA.method09 <- data.frame(tmp$samples)
# # names(PSA.method09) <- c("u1", "u2")
# # 
# # 
# # plot(u2 ~ u1, data=PSA.method08)
# # plot(u2 ~ u1, data=PSA.method09)
# # 
# # # METHOD 10: Beta distribution difference fitting
# # 

