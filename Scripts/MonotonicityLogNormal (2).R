

d.test <- function(par, A.mu, A.sig, B.mu, B.sig, nsims=10000){
  A <- rnorm(nsims, mean=A.mu, sd=A.sig)
  B <- rnorm(nsims, mean=B.mu, sd=B.sig)
  
  D.mu <- par[1]
  D.sig <- exp(par[2])
  
  D <- rlnorm(nsims, meanlog=D.mu, sdlog=D.sig)
  
  B.pred <- A + D
  
  mse <- mean((B.pred - B)^2)
  return(mse)
}

d.test(par=c(3, 1), 1, 1, 2, 1)
d.test(par=c(0, -50), 1, 1, 2, 1)

optim.out <- optim(par=c(0, 0), d.test, A.mu=1, A.sig=1, B.mu=2, B.sig=1,
                     method="BFGS", hessian=T, control=list(trace=1))

A <- rnorm(1000, 1, 1)
B <- rnorm(1000, 2, 1)
B.pred <- A + rlnorm(1000, optim.out$par[1], exp(optim.out$par[2]))
plot(density(B))
lines(density(B.pred), lty="dashed")
length(which(A>B))
length(which(A>B.pred))



