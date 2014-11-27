

# Toy example:
tiff("figures/fig_01.tiff", 300,300) 
toy_data <- data.frame(
    bad=rnorm(10000, 0.20, 1.0),
    good=rnorm(10000, 0.6, 0.4)
    )

g <- ggplot(toy_data) + geom_density(aes(x=bad), fill="red", alpha=0.6) + geom_density(aes(x=good), fill="blue", alpha=0.2)


theme_myblank <- theme(axis.line=element_blank(),
      axis.text.x=element_blank(),
      axis.text.y=element_blank(),
      axis.ticks=element_blank(),
      axis.title.x=element_blank(),
      axis.title.y=element_blank(),
      legend.position="none",
      panel.background=element_blank(),
      panel.border=element_blank(),
      panel.grid.major=element_blank(),
      panel.grid.minor=element_blank(),
      plot.background=element_blank())

g2 <- g + theme_myblank

print(g2)

dev.off()

# The IPD itself

tiff("figures/fig_02.tiff", 500, 500)
g <- ggplot(data=data_2d, aes(x=u1, y=u2))
g2 <- g + geom_abline(intercept=0, slope=1, colour="red", lty="dashed", size=1.1)
g3 <- g2 + geom_point()
g4 <- g3 + xlab("Higher parameter") + ylab("Lower parameter")
g5 <- g4 + coord_fixed(xlim=c(0,1), ylim=c(0,1))
print(g5)
dev.off()



#####

tiff("figures/fig_03.tiff", 1100,1100) 

samples <- sample(
    unique(data_wide$sample),
    min(2500, length(unique(data_wide$sample)))
)

d_wide_ss <- subset(data_wide, subset=sample %in% samples)
g <- ggplot(data=d_wide_ss, aes(x=u1, y=u2))
g2 <- g + geom_abline(intercept=0, slope=1, colour="red", lty="dashed", size=1.1)


g3 <- g2 + geom_point(alpha=0.1) + facet_wrap(~ method, nrow=3) 
g4 <- g3 + coord_fixed(xlim=c(0.4, 0.7), ylim=c(0.4, 0.7))
g5 <- g4 + xlab("Higher parameter") + ylab("Lower parameter")
g6 <- g5 + theme(text=element_text(size=16))
print(g6)
dev.off()


tiff("figures/fig_04.tiff", 1200, 800)
g <- ggplot(subset(data_wide, subset=method!="Bootstrapped"), aes(x=u1)) + geom_density(fill="grey")
g2 <- g + facet_wrap("method", nrow=4)
g3 <- g2 + geom_density(aes(x=subset(data_wide, subset=method=="Bootstrapped")$u1), col="blue", width=1.1, lty="dashed")
g4 <- g3 + xlab("Distribution of estimates for higher parameter")
print(g4)
dev.off()


# u2 : worse health state
tiff("figures/fig_05.tiff", 1200, 800)
g <- ggplot(subset(data_wide, method!="Bootstrapped"), aes(x=u2)) + geom_density(fill="grey")
g2 <- g + facet_wrap("method", nrow=4)
g3 <- g2 + geom_density(aes(x=subset(data_wide, method=="Bootstrapped")$u2), col="blue", width=1.2, lty="dashed")
g4 <- g3 + xlab("Distribution of estimates for lower parameter")
print(g4)
dev.off()



# difference
tiff("figures/fig_06.tiff", 1200, 800)
g <- ggplot(subset(data_wide, method!="Bootstrapped"), aes(x=difference)) + geom_density(fill="grey")
g2 <- g + facet_wrap("method", nrow=4)
g3 <- g2 + geom_density(
    aes(x=subset(data_wide, method=="Bootstrapped")$difference), 
    col="blue", width=1.2, lty="dashed",
    trim=T
    )

g4 <- g3 + xlab("Distribution of differences in paired estimates")
g5 <- g4 + coord_cartesian(ylim=c(0,100))
g6 <- g5 + geom_vline(mapping=aes(x=0), colour="red")
print(g6)
dev.off()




# Want values reordered by mean rms error
levels(summaries_rms$variable) <- c("Higher", "Lower", "Difference")

mean_rms <- ddply(summaries_rms,
                  .(method),
                  summarise,
                  mean_rms=mean(rms),
                  dif_rms=rms[variable=="Difference"]
                  )
summaries_rms <- join(summaries_rms, mean_rms)

summaries_rms$method <- factor(summaries_rms$method,
                               levels=summaries_rms[order(summaries_rms$mean_rms),"method"])

tiff("figures/fig_07.tiff", 1200, 800)

g1 <- ggplot(data=summaries_rms) + aes(x=rms, y=method) + geom_point(size=3) 
g2 <- g1 + facet_wrap(  ~ variable) + labs (x="Root mean squared error", y="Method")
print(g2)

dev.off()

