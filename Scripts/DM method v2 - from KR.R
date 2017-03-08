
# Case where permitted values bounded between 0 and 1 

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
    
    s <- mu.d^2 / v.d
    r <- mu.d / v.d
    
    s.d <- rgamma(n_sims, s, r)   #sample d from a gamma 
    s.nx <- rnorm(n_sims ,mean(n.x), sqrt(var(n.x)))   #sample logit transformed x from a normal
    s.ny <- s.d + s.nx                                 #sample value of logit transformed y 
    
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
    
    x < -rgamma(n_sims,s.x,r.x) # sample y from a gamma
    
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
    s.nx <- rnorm(n_sims, mean(n.x), sqrt(var(n.x)) )  #sample exp transformed x from a normal
    s.ny <- s.nx + s.d                                #sample value of exp transformed y 
    
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




########################################
# x and y are bounded between 0 and 1

#### for y
mu.y=0.8;v.y=0.04     #given mean and var of y
a.y<-((1-mu.y)*mu.y/v.y -1)*mu.y
b.y<-a.y*(1-mu.y)/mu.y

y<-rbeta(100000,a.y,b.y) # sample y from a beta

n.y<-log(y/(1-y))        #logit transformation to get to real line (unbounded)
mean(n.y);var(n.y)       #mean and var after logit transformation

#### for x
mu.x=0.5;v.x=0.06         #given mean and var of x
a.x<-((1-mu.x)*mu.x/v.x -1)*mu.x
b.x<-a.x*(1-mu.x)/mu.x

x<-rbeta(100000,a.x,b.x) # sample x from a beta

n.x<-log(x/(1-x))        #logit transformation
mean(n.x);var(n.x)       #mean and var after logit transformation


# the difference between the logit tranformed x and y
var(n.y)>var(n.x)
#n.y=n.x+d since var(logit transormed y)>var(logit transformed x)
mu.d<-mean(n.y)-mean(n.x)
v.d<-abs(var(n.y)-var(n.x))

s=mu.d^2/v.d
r=mu.d/v.d

s.d<-rgamma(100000,s,r)   #sample d from a gamma 
s.nx<-rnorm(100000,mean(n.x),sqrt(var(n.x)))   #sample logit transformed x from a normal
s.ny<-s.d+s.nx                                 #sample value of logit transformed y 

s.y<-exp(s.ny)/(1+exp(s.ny))                  #back tranform to get y
s.x<-exp(s.nx)/(1+exp(s.nx))                  #back tranform to get x

#check the mean and var and min and max of sampled x and y
mean(s.y);var(s.y);min(s.y);max(s.y)
mean(s.x);var(s.x);min(s.x);max(s.x)

out <- zero_one_bounded(
    0.5, 0.06,
    0.8, 0.04, 
    verbose = T
)

################################
# x and y >0
#### for y
mu.y=0.6;v.y=0.0019      #given mean and var of y
s.y=mu.y^2/v.y
r.y=mu.y/v.y

y<-rgamma(100000,s.y,r.y)  # sample y from a gamma

n.y<-exp(y)        #exp transformation to get to real line (unbounded)
mean(n.y);var(n.y)  #mean and var after exp transformation

#### for x
mu.x=0.5;v.x=0.0016      #given mean and var of x
s.x=mu.x^2/v.x
r.x=mu.x/v.x

x<-rgamma(100000,s.x,r.x) # sample y from a gamma

n.x<-exp(x)       #exp transformation to get to real line (unbounded)
mean(n.x);var(n.x)  #mean and var after exp transformation

# the difference between the exp tranformed x and y
var(n.y)>var(n.x)
#n.y=n.x+d since var(logit transormed y)>var(logist transformed x)
mu.d<-mean(n.y)-mean(n.x)
v.d<-abs(var(n.y)-var(n.x))

s=mu.d^2/v.d
r=mu.d/v.d

s.d<-rgamma(100000,s,r)  #sample d from a gamma 
s.nx<-rnorm(100000,mean(n.x),sqrt(var(n.x)))  #sample exp transformed x from a normal
s.ny<-s.nx+s.d                                #sample value of exp transformed y 

s.y<-log(s.ny)                  #back tranform to get y
s.x<-log(s.nx)                  #back tranform to get x

#check the mean and var and min and max of sampled x and y
mean(s.y);var(s.y);min(s.y);max(s.y)
mean(s.x);var(s.x);min(s.x);max(s.x)

out <- zero_plus_bounded(
    0.5, 0.0016,  
    0.6, 0.0019,
    verbose = T
)



# My code below


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

###
return(data.frame(output))
}




est_beta <- function(mu, var) {
    a <- mu * ((1 - mu) * (mu / var) - 1)
    b <- a * ((1 - mu) / mu)
    return(list(a=a, b=b))
}




################################
# x and y >0
# #### for y
# mu.y=0.6;v.y=0.0019      #given mean and var of y
# s.y=mu.y^2/v.y
# r.y=mu.y/v.y
# 
# y<-rgamma(100000,s.y,r.y)  # sample y from a gamma
# 
# n.y<-exp(y)        #exp transformation to get to real line (unbounded)
# mean(n.y);var(n.y)  #mean and var after exp transformation

#### for x
# mu.x=0.5;v.x=0.0016      #given mean and var of x
# s.x=mu.x^2/v.x
# r.x=mu.x/v.x
# 
# x<-rgamma(100000,s.x,r.x) # sample y from a gamma
# 
# n.x<-exp(x)       #exp transformation to get to real line (unbounded)
# mean(n.x);var(n.x)  #mean and var after exp transformation

# # the difference between the exp tranformed x and y
# var(n.y)>var(n.x)
# #n.y=n.x+d since var(logit transormed y)>var(logist transformed x)
# mu.d<-mean(n.y)-mean(n.x)
# v.d<-abs(var(n.y)-var(n.x))
# 
# s=mu.d^2/v.d
# r=mu.d/v.d
# 
# s.d<-rgamma(100000,s,r)  #sample d from a gamma 
# s.nx<-rnorm(100000,mean(n.x),sqrt(var(n.x)))  #sample exp transformed x from a normal
# s.ny<-s.nx+s.d                                #sample value of exp transformed y 
# 
# s.y<-log(s.ny)                  #back tranform to get y
# s.x<-log(s.nx)                  #back tranform to get x
# 
# #check the mean and var and min and max of sampled x and y
# mean(s.y);var(s.y);min(s.y);max(s.y)
# mean(s.x);var(s.x);min(s.x);max(s.x)

