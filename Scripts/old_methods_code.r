
# Based on Gandrud's code
Make_Caterpillar <- function(DF){
    #     ggplot(data= NBSub2DF, aes(x=reorder(Variable, X2.5.), y= Mean,
    #                                ymin=X2.5., ymax=X97.5.)) + 
    #         geom_pointrange(size=1.4) + 
    #         geom_hline(aes(intercept= 0), linetype="dotted") +
    #         xlab("Variable\n") + ylab("\n Coefficient Estimate") +
    #         coord_flip() 
    
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
