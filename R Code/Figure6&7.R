library(dplyr)
library(ggplot2)
library(ggsignif)

#FIGURE 6
######################################################################################
#upload csv file
GFAP_MFI_df <- read.csv("GFAP_MFI_df.csv")

#summarise df by treatment type
GFAP_summary <- GFAP_MFI_df %>% group_by(Treatment) %>% 
  summarise(avg_mfi = mean(sum_mfi), sd = sd(sum_mfi), n = n(), se = sd/sqrt(n))

#make barplot of GFAP data
GFAP_MFI_totals_barplot <- ggplot(GFAP_summary, aes(x = Treatment, y = avg_mfi, fill = Treatment))+
  geom_bar(position = "dodge", stat = "identity", color = "black")+
  geom_errorbar(aes(x = Treatment, 
                    ymin = avg_mfi - se, 
                    ymax = avg_mfi + se,
                    width = 0.2))+
  geom_signif(xmin = c("AD", "SHAM", "TBI"),
              xmax = c("WT", "WT", "WT"),
              y_position = c(305, 285, 265),
              annotations = c("**", "*", "*"),
              tip_length = 0)+
  scale_y_continuous(expand = expansion(mult = c(0, 0.05)))+
  theme_classic()+
  theme(legend.position = "none")+
  scale_fill_manual(values = c("#446455", "#FDD262", "#D3DDDC", "#C7B19C"))+
  xlab("Treatment")+ ylab("MFI")

png("GFAP_MFI_totals_barplot.png", width = 5, height = 4, units = "in", res = 300)
plot(GFAP_MFI_totals_barplot)
dev.off()

#data analysis for GFAP barplot
log_GFAP_df <- as.data.frame(cbind(GFAP_MFI_df$Treatment, log(GFAP_MFI_df$sum_mfi)))
FULL_GFAP_summary_aov <- aov(V2 ~ V1, log_GFAP_df)
summary(FULL_GFAP_summary_aov)
TukeyHSD(FULL_GFAP_summary_aov)

#FIGURE7
#########################################################################################
#upload csv
iba1_MFI_df <- read.csv("iba1_MFI_df.csv")

#create summary
iba1_full_summary <- iba1_MFI_df %>% group_by(Treatment) %>% summarise(avg_mean = mean(Mean), 
                                                                            sd = sd(Mean), 
                                                                            n = n(),
                                                                            se = sd/sqrt(n))

#create barplot of iba1 MFI data
iba1_mfitotals_barplot <- ggplot(iba1_full_summary, aes(x = Treatment, y = avg_mean, fill = Treatment))+
  geom_bar(stat = "identity", color = "black") +
  geom_errorbar(aes(x = Treatment,
                    ymin = avg_mean - se,
                    ymax = avg_mean + se,
                    width = 0.2))+
  theme_classic()+
  theme(legend.position = "none")+
  scale_fill_manual(values = c("#446455", "#FDD262", "#D3DDDC", "#C7B19C"))+
  geom_signif(y_position = c(210, 195, 180), 
              xmin = c('AD','SHAM','TBI'),
              xmax = c('WT','WT', 'WT'),
              annotations = c('***', '**', '***'),
              tip_length = 0)+
  ylab("MFI")
print(iba1_mfitotals_barplot)

#save image
png("iba1_mfitotals_barplot.png", width = 5, height = 4, units = "in", res = 300)
plot(iba1_mfitotals_barplot)
dev.off()

#anova for MFI Iba1 data
summary(aov(log(iba1_MFI_df$Mean)~iba1_MFI_df$Treatment))
TukeyHSD(aov(log(iba1_MFI_df$Mean)~iba1_MFI_df$Treatment))