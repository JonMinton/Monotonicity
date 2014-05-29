X1 <- rnorm(1000, 2, 2)
X2 <- rnorm(1000, 4, 1)
X3 <- rnorm(1000, 6)

Data.unsorted <- data.frame(x1=X1, x2=X2, x3=X3)

Data.sorted <- data.frame(x1=sort(X1), x2=sort(X2), x3=sort(X3))

plot(x2 - x1 ~ 1, data=Data.sorted, main ="Differences between x1 and x2", ylim=c(min(Data.sorted), max(Data.sorted)))
points(Data.unsorted[,2] - Data.unsorted[,1], col="grey")
abline(h=0, lwd=2, lty="dashed")
legend("topright", pch=c(1,1), col=c("black", "grey"), legend=c("Sorted", "Unsorted"))