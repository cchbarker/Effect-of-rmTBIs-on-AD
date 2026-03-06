libs <- c('ggplot2', 'lattice', 'gridExtra', 'MASS', 
          'colorspace', 'plyr', 'scales')
lapply(libs, require, character.only = T)
library(wesanderson)
library(latticeExtra)
library(tidyverse)
library(rstatix)
library(broom)
library(ggpubr)

#upload Barnes maze data
allgroups_barnesmaze_cleaned <- read.csv("allgroups_barnesmaze_cleaned.csv")

###making lattice scatterplot
#settings
colors <- c("#446455", "#FDD262", "#D3DDDC", "#C7B19C", "#ECCBAE", "#79402E")

bw.theme <- trellis.par.get()
bw.theme$box.dot$pch <- "|"
bw.theme$box.rectangle$col <- "black"
bw.theme$box.rectangle$lwd <- 2
bw.theme$box.rectangle$fill <- "grey90"
bw.theme$box.umbrella$lty <- 1
bw.theme$box.umbrella$col <- "black"
bw.theme$plot.symbol$col <- "grey40"
bw.theme$strip.background$col <- "grey80"
bw.theme$plot.symbol$pch <- "•"
bw.theme$plot.symbol$cex <- 1
bw.theme$par.main.text <- list(font = 1)
my.theme$strip.background$col <- "#D3DDDC"
my.theme$plot.symbol$col <- "#446455"
my.theme$plot.polygon$col <- "#C7B19C"

#lattice scatter plot with line of best fit
allgroups_barnesmaze_cleaned$trial <- as.numeric(allgroups_barnesmaze_cleaned$trial) #have to change column class to numeric

barnes.maze.lattice <- xyplot(average ~ trial | factor(treatment), 
                              data = allgroups_barnesmaze_cleaned,    panel = function(x, y, ...) {
                                panel.xyplot(x, y, ...)
                                panel.abline(lm(y~x, col = "black"))
                                lm1 <- lm(y ~ x)
                                lm1sum <- summary(lm1)
                                r2 <- lm1sum$adj.r.squared
                                panel.text(labels = 
                                             bquote(italic(R)^2 == 
                                                      .(format(r2, 
                                                               digits = 3))),
                                           x = 4, y = 1000)  
                                panel.smoother(x, y, method = "lm", 
                                               col = "black", 
                                               col.se = "grey70",
                                               alpha.se = 0.3)
                              },
                              yscale.components = yscale.components.subticks,
                              as.table = TRUE)

barnes.maze.lattice <- update(barnes.maze.lattice, par.settings = my.theme, 
                              layout = c(2, 2),
                              between = list(x = 0.3, y = 0.3))
barnes.maze.lattice <- update(barnes.maze.lattice, xlab = "Trial Number",
                              ylab = "Latency (sec)")

#save high res image
print(barnes.maze.lattice)
png("Lattice.Scatterplot.BM.png", width = 5, height = 4, units = 'in', res = 300)
plot(barnes.maze.lattice)
dev.off()

#statistical analysis
#kuskal wallace test of barnes maze data
kruskal.test(average ~ treatment, allgroups_barnesmaze_cleaned)
#post-hoc test
dunnTest(average ~ treatment,
         data = allgroups_barnesmaze_cleaned,
         method="bonferroni")


###Making connected scatterplot

#average each group per trial day and make line plot
barnesmaze_averages <- aggregate(allgroups_barnesmaze_cleaned,
                                 by = list(allgroups_barnesmaze_cleaned$trial,
                                           allgroups_barnesmaze_cleaned$treatment),
                                 FUN = mean)
barnesmaze_averages <- barnesmaze_averages[,-c(3,6,7)]
names(barnesmaze_averages)[c(1,2)]<- c("trial", "treatment")
View(barnesmaze_averages)

#create barnes maze summary
barnesmaze_summary <- allgroups_barnesmaze_cleaned %>% group_by(trial, treatment) %>% 
  summarise(avg_latency = mean(average), sd = sd(average), n = n(), se = sd/sqrt(n))

#line plot with aggregated data
barnesmaze_lineplot <- ggplot(barnesmaze_summary, aes(x = trial, y = avg_latency,  color = treatment, group=treatment, shape = treatment)) +
  geom_point(size = 4)+
  geom_line()+
  geom_errorbar(aes(ymin = avg_latency - se, ymax = avg_latency + se), width = 0.2)+
  theme_minimal()+
  theme(legend.title = element_blank(),
        axis.line.x = element_line(color = "black"),
        axis.line.y = element_line(color = "black"),
        axis.text.y = element_text(color = "black", size = 9))+
  ylim(65,95)+
  scale_color_manual(values = c("#446455", "#FDD262", "#D3DDDC", "#C7B19C"))+
  scale_shape_manual(values = c(15,16,17,18))+
  ylab("Average Latency (sec)") + xlab("Trial")+
  geom_text(aes(x = 5, y = 90, label = "*"), col="black", size = 6)+
  geom_text(aes(x = 6, y = 91, label = "*"), col="black", size = 6)+
  geom_text(aes(x = 6, y = 93, label = "#"), col="black", size = 4)+
  scale_x_continuous("Trial", labels = as.character(trial), breaks = trial)

png("barnesmaze_lineplot.png", width = 5, height = 4, units = "in", res = 300)
plot(barnesmaze_lineplot)
dev.off()

#Statistical analysis for connected scatterplot
hist(allgroups_barnesmaze_cleaned$average) 

kruskal.test(average ~ treatment, subset(allgroups_barnesmaze_cleaned, trial == "1"))
kruskal.test(average ~ treatment, subset(allgroups_barnesmaze_cleaned, trial == "2"))
kruskal.test(average ~ treatment, subset(allgroups_barnesmaze_cleaned, trial == "3"))
kruskal.test(average ~ treatment, subset(allgroups_barnesmaze_cleaned, trial == "4"))
kruskal.test(average ~ treatment, subset(allgroups_barnesmaze_cleaned, trial == "5"))
kruskal.test(average ~ treatment, subset(allgroups_barnesmaze_cleaned, trial == "6"))

pairwise.wilcox.test(subset(allgroups_barnesmaze_cleaned, trial == "5")$average, subset(allgroups_barnesmaze_cleaned, trial == "5")$treatment,
                     p.adjust.method = "BH")

pairwise.wilcox.test(subset(allgroups_barnesmaze_cleaned, trial == "6")$average, subset(allgroups_barnesmaze_cleaned, trial == "6")$treatment,
                     p.adjust.method = "BH")


##Making NOR boxplot
library(tidyverse) 
library(ggplot2)
library(ggsignif)

#upload data table
NOR_total_data_cleaned <- read.csv("NOR_total_data_cleaned.csv")

#Make boxplot
#NOR boxplot data
NOR_boxplot <- ggplot(data = NOR_total_data_cleaned, aes(x = treatment, y = discrimination_index, fill = treatment))+
  geom_boxplot()+
  theme_classic()+
  theme(legend.position = "none") +
  geom_signif(y_position = c(1.20, 1.13, 1.06), 
              xmin = c("AD", "SHAM", "TBI"),
              xmax = c("WT", "WT", "WT"),
              annotations = c("*", "**", "*"),
              tip_length = 0)+
  scale_fill_manual(values = c("#446455", "#FDD262", "#D3DDDC", "#C7B19C"))+
  xlab("Treatment") + ylab("Discrimination Index")

png('NOR_boxplot.png', height = 4, width = 5, units ='in', res = 300)
plot(NOR_boxplot)
dev.off()

#data analysis
NOR_aov <- aov(discrimination_index ~ treatment, NOR_total_data_cleaned)
summary(NOR_aov)
TukeyHSD(NOR_aov)


