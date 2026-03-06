library(dplyr)
library(ggplot2)
library(ggsignif)

#upload csv
ptau_histogram_data <- read.csv("ptau_histogram_data.csv")

#create histogram visualization
tau_hist <- ggplot(tau_results_full, aes(x = log10(Area), fill= Treatment)) +
  geom_histogram(color = "black", alpha=1)+
  theme_bw()+
  theme(
    legend.position="none",
    panel.spacing = unit(0.1, "lines"),
    strip.text.x = element_text(size = 8)
  ) +
  scale_fill_manual(values = c("#446455", "#FDD262", "#D3DDDC", "#C7B19C"))+
  facet_wrap(~Treatment)+
  ylab("Count") + xlab("log10(Aggregate Area)")

png("tau_hist.png", width = 5, height = 4, units = "in", res = 300)
plot(tau_hist)
dev.off()

#statistical tests
summary(aov(ptau_histogram_data$Area ~ ptau_histogram_data$Treatment))
TukeyHSD(aov(ptau_histogram_data$Area ~ ptau_histogram_data$Treatment))

#upload csv for Tau count barplot
pTau_count_data <- read.csv("pTau_count_data.csv")

#create summary of image data for pTau aggregate count barplot
tau_count_summary <- pTau_count_data %>% group_by(Treatment) %>% 
  summarise(avg_count = mean(Count), sd = sd(Count), n = n(), se = sd/sqrt(n))

#create barplot
Tau_barplot <- ggplot(tau_count_summary, aes(Treatment, avg_count, fill = Treatment))+
  geom_bar(stat = "identity", color = "black")+
  geom_errorbar(aes(x = Treatment, 
                    ymin = avg_count - se, 
                    ymax = avg_count + se,
                    width = 0.2))+
  scale_y_continuous(expand = expansion(mult = c(0, 0.05)))+
  theme_classic()+
  theme(legend.position = "none")+
  scale_fill_manual(values = c("#446455", "#FDD262", "#D3DDDC", "#C7B19C"))+
  xlab("Treatment")+ ylab("Aggregate Count") +
  geom_signif(y_position = c(20, 21.5, 23),
              xmin = c("TBI", "SHAM", "AD"),
              xmax = c("WT", "WT", "WT"),
              annotations = c('***', '***', '***'),
              tip_length = 0)

#statistical tests
pTau_count_data$log_count <- log10(pTau_count_data$Count + 1)

summary(aov(log_count ~ Treatment, pTau_count_data))
TukeyHSD(aov(log_count ~ Treatment, pTau_count_data))

#save as image
png("tau_barplot.png", width = 5, height = 4, units = "in", res = 300)
plot(Tau_barplot)
dev.off()