# # Figure Making script

# 13/6/2014
# Redoing everything in ggplot2 
# 
# ####################################### RESULTS ############################################
# 
# # want to plot scat

# Toy example:
tiff("figures/fig_01.tiff", 300,300) 
toy_data <- data.frame(
    bad=rnorm(10000, 0.20, 1.0),
    good=rnorm(10000, 0.6, 0.4)
    )

g <- ggplot(toy_data) + geom_density(aes(x=bad), fill="red", alpha=0.2) + geom_density(aes(x=good), fill="blue", alpha=0.2)


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

## The next figure should be the IPD itself

# TO DO: FIGURE 2 to GO HERE


#####

tiff("figures/fig_03.tiff", 1100,1100) 
g <- ggplot(data=data_wide, aes(x=u1, y=u2))
g2 <- g + geom_point() + facet_wrap(~ method, nrow=3) 
g3 <- g2 + geom_abline(intercept=0, slope=1, colour="red", lty="dashed", size=1.1)
g4 <- g3 + coord_fixed(xlim=c(0.4, 0.7), ylim=c(0.4, 0.7))
g5 <- g4 + xlab("Higher parameter") + ylab("Lower parameter")
g6 <- g5 + theme(text=element_text(size=16))
print(g6)
dev.off()


tiff("figures/fig_04.tiff", 1200, 800)
g <- ggplot(subset(data_wide, method!="Bootstrapped"), aes(x=u1)) + geom_density(fill="grey")
g2 <- g + facet_wrap("method", nrow=4)
g3 <- g2 + geom_density(aes(x=subset(data_wide, method=="Bootstrapped")$u1), col="blue", width=1.1, lty="dashed")
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



####
source("scripts/make_summaries_dataframes.r")


tiff("figures/fig_07.tiff", 1200, 800)
levels(Summaries.RMS$var) <- c("Difference", "Higher", "Lower")

g1 <- ggplot(data=Summaries.RMS) + aes(y=method, x=value) + geom_point(size=3) 
g2 <- g1 + facet_wrap(  ~ var) + labs (x="Root mean squared error", y="Method")
print(g2)

dev.off()

