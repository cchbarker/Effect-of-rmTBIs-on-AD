library(dplyr)
library(ggplot2)

#upload csv
Full_df <- read.csv("AB_count_results_final.csv")

#summarise results for barplot
ab_count_summary <- Full_df %>% group_by(Treatment) %>% 
  summarise(avg_count = mean(Count), sd = sd(Count), n = n(), se = sd/sqrt(n))

#barplot of count data
abeta_barplot <- ggplot(ab_count_summary, aes(Treatment, avg_count, fill = Treatment))+
  geom_bar(stat = "identity", color = "black")+
  geom_errorbar(aes(x = Treatment, 
                    ymin = avg_count - se, 
                    ymax = avg_count + se,
                    width = 0.2))+
  scale_y_continuous(expand = expansion(mult = c(0, 0.05)))+
  theme_classic()+
  theme(legend.position = "none")+
  scale_fill_manual(values = c("#446455", "#FDD262", "#D3DDDC", "#C7B19C"))+
  xlab("Treatment")+ ylab("Plaque Count") +
  geom_signif(y_position = c(6.4, 6.9, 7.4, 7.8, 8.3),
              xmin = c("TBI", "SHAM", "AD", "AD", "AD"),
              xmax = c("WT", "WT", "WT", "SHAM", "TBI"),
              annotations = c('***', '***', '*', '***', '***'),
              tip_length = 0)

png("abeta_barplot.png", width = 5, height = 4, units = "in", res = 300)
plot(abeta_barplot)
dev.off()


kruskal.test(Count ~ Treatment, Full_df)
pairwise.wilcox.test(Full_df$Count, Full_df$Treatment,
                     p.adjust.method = "none", paired = F)


###Histogram
#upload csv
ab_results_full <- read.csv("AB_histogram_data.csv")

#Make histogram by treatment group
AB_plaque_hist <- ggplot(ab_results_full, aes(x = log10(Area), fill= Treatment)) +
  geom_histogram(color = "black", alpha=1)+
  theme_bw()+
  theme(
    legend.position="none",
    panel.spacing = unit(0.1, "lines"),
    strip.text.x = element_text(size = 8)
  ) +
  scale_fill_manual(values = c("#446455", "#FDD262", "#D3DDDC", "#C7B19C"))+
  facet_wrap(~Treatment)+
  ylab("Count") + xlab("log10(Plaque Area)")

#save figure
png("AB_plaque_hist.png", width = 5, height = 4, units = "in", res = 300)
plot(AB_plaque_hist)
dev.off()

#ANOVA comparing means of plaque sizes
plaque_size_aov <- aov(ab_results_full$Area ~ ab_results_full$Treatment)
summary(plaque_size_aov)
