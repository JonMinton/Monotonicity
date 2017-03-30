# Simple graph script 


# Set up ------------------------------------------------------------------

rm(list=ls())

# Load prerequisites

require(pacman)

pacman::p_load(
    tidyverse,
    forcats,
    ggplot2,
    cowplot
)

dta <- read_csv("data/samples.csv")
dta %>% mutate(
    Method = fct_recode(
        Method, 
        DM = "Difference Sampling",
        Ind = "Independent",
        RN = "Same Random Number"
        ) 
) -> dta

dta_real <- dta[,c(1,2,3)]
names(dta_real) <- c("Method", "X", "Y")

dta_bounded_pos <- dta[,c(1,4,5)]
names(dta_bounded_pos) <- c("Method", "X", "Y")

dta_bounded_01 <- dta[,c(1,6,7)]
names(dta_bounded_01) <- c("Method", "X", "Y")

ggplot(data = dta_real) + 
    geom_point(aes(x = X, y = Y), alpha = 0.2) + 
    facet_wrap(~Method) + 
    geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
    coord_fixed()
ggsave("figures/new_fig_1.png", dpi = 300, units = "cm", width = 20, height = 8)

ggplot(data = dta_bounded_pos) + 
    geom_point(aes(x = X, y = Y), alpha = 0.2) + 
    facet_wrap(~Method) + 
    geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
    coord_fixed()
ggsave("figures/new_fig_2.png", dpi = 300, units = "cm", width = 20, height = 8)

ggplot(data = dta_bounded_01) + 
    geom_point(aes(x = X, y = Y), alpha = 0.2) + 
    facet_wrap(~Method) + 
    geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
    coord_fixed()
ggsave("figures/new_fig_3.png", dpi = 300, units = "cm", width = 20, height = 8)
