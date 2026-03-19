args = commandArgs(trailingOnly=TRUE)
infile = args[1]
filename = args[2]
p_threshold = as.numeric(args[3])

#########################################################################

### Packages ###
library(data.table)   # To load data
library(qqman)        # To create QQ Plot
library(tidyverse)    

### Load Data ###
GWAS_df <- read.table(infile, header = T, stringsAsFactors = F)

### Manhattan Plot ###
# Create cumulative POS position for x axis
cum_POS <- GWAS_df %>% 
  group_by(CHR) %>% 
  summarise(max_POS = max(POS)) %>% 
  mutate(POS_add = dplyr::lag(cumsum(as.numeric(max_POS)), default = 0)) %>% 
  select(CHR, POS_add)

Man_plot_df <- GWAS_df %>% 
  inner_join(cum_POS, by = "CHR") %>% 
  mutate(POS_cum = POS + POS_add)

# Find central POS for each chromosome for adding chromsome no. to x axis
axis_set <- Man_plot_df %>% 
  group_by(CHR) %>% 
  summarize(center = mean(POS_cum))

# Set max y axis value
ylim <- Man_plot_df %>%
  filter(P == min(P)) %>%
  slice(1) %>%
  mutate(ylim = abs(floor(log10(P))) + 2) %>%
  pull(ylim)

# Set significance threshold
sig <- p_threshold

# Plot
Man_plot <- ggplot(Man_plot_df, 
       aes(x = POS_cum, y = -log10(P), color = as_factor(CHR), size = -log10(P))) +
  geom_point(size = 0.6, alpha = 0.75) +
  geom_hline(yintercept = -log10(sig), 
             color = "grey40",
             linetype = "dashed") +
  scale_x_continuous(label = axis_set$CHR, 
                     breaks = axis_set$center) +
  scale_y_continuous(expand = c(0, 0), 
                     limits = c(0, ylim)) +
  scale_color_manual(values = rep(c("#276FBF", "#183059"), 
                                  unique(length(axis_set$CHR)))) +
  scale_size_continuous(range = c(0.5, 3)) +
  labs(x = "Chromosome",
       y = expression(-log[10](p-value))) +
  theme_classic() +
  theme(legend.position = "none",
        axis.text.x = element_text(angle = 60, size = 8, vjust = 0.5))

outfile <- paste(filename, ".Manhattan.png", sep="")
ggsave(Man_plot, width = 25, height = 10, unit = "cm", file = outfile)


### QQ Plot ###
# calculate lambda
alpha <- median(qchisq(1-GWAS_df$P,1))/qchisq(0.5,1)

# specify confidence interval
ci <- 0.95
# no. SNPs
n_snps <- nrow(GWAS_df)

# Create dataframe with all the data for the QQ Plot
QQ_plot_df <- tibble(
  observed = -log10(sort(GWAS_df$P)),
  expected = -log10(ppoints(n_snps)),
  clower = -log10(qbeta(
    p = (1 - ci) / 2,
    shape1 = seq(n_snps),
    shape2 = rev(seq(n_snps))
  )),
  cupper = -log10(qbeta(
    p = (1 + ci) / 2,
    shape1 = seq(n_snps),
    shape2 = rev(seq(n_snps))
  ))
)

#Plot
QQ_plot <- ggplot(QQ_plot_df, aes(x = expected, y = observed)) +
    geom_ribbon(aes(ymax = cupper, ymin = clower),
                fill = "grey30", alpha = 0.5) +
    geom_point() +
    geom_segment(data = . %>% filter(expected == max(expected)),
      aes(x = 0, xend = expected, y = 0, yend = expected),
      linewidth = 1.25, alpha = 0.5,
      color = "grey30", lineend = "round") +
    labs(x = expression(Expected -log[10](p-value)),
         y = expression(Observed -log[10](p-value)),
         caption = paste("lambda =", signif(alpha, digits = 4))) +
    theme_classic() +
    theme(plot.caption = element_text(size = 12))

outfile <- paste(filename, ".QQ.png", sep="")
ggsave(QQ_plot, width = 25, height = 25, unit = "cm", file = outfile)
