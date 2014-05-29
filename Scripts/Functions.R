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
    output <- matrix(NA, nrows=n.reps, ncols)
    for (i in 1:n.reps){
        this.boot <- Data[sample(draws, n.obs, T),]
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