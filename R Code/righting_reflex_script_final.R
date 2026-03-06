library(readxl)
library(ggplot2)
library(stats)
library(dplyr)
library(ggpubr)

#upload righting reflex data
righting_reflex_data <- read.csv("righting_reflex_data.csv")

####barplot of righting reflex data

#summarizing to get mean, sd, and se
righting_reflex_sum <- righting_reflex_data %>%
  group_by(Treatment, TBI_Number) %>%
  summarise(
    righting_reflex_avg = mean(righting_reflex_time),
    sd = sd(righting_reflex_time),
    n = n(),
    se = sd / sqrt(n)
  )

#barplot of righting reflex data
righting_reflex_barplot <- ggplot(righting_reflex_sum, aes(x = TBI_Number, y = righting_reflex_avg, fill = Treatment))+
  geom_bar(stat = 'identity', position = 'dodge', color = "black")+
  geom_errorbar(aes(x = TBI_Number, ymin = righting_reflex_sum$righting_reflex_avg - righting_reflex_sum$se,
                ymax = righting_reflex_sum$righting_reflex_avg + righting_reflex_sum$se, 
                group = Treatment), width = 0.2, position = position_dodge(0.9))+
  xlab("TBI Number")+
  ylab("Righting Reflex Time (sec)")+
  theme_classic()+
  theme(legend.position = "bottom")+
  ylim(0,300)+
  geom_signif(y_position = c(300, 300, 300, 300, 300), xmin = c(0.8, 1.8, 2.8, 3.8, 4.8), xmax = c(1.2, 2.2, 3.2, 4.2, 5.2),
              annotation=c("****", "****", "****", "****", "****"), tip_length=0)

png('righting_reflex_TBIexo.png', height = 4, width = 5, units = 'in', res = 300)
plot(righting_reflex_barplot)
dev.off()

#statistical tests
rr_ttest <- compare_means(righting_reflex_time ~ Treatment, data = righting_reflex_data,
              group.by = "TBI_Number", method = "t.test")
print(rr_ttest)

  
