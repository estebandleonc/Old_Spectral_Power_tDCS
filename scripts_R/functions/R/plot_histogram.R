library(ggplot2)
library(dplyr)

plot_histogram <- function(data, dataset) {

  # Filter out missing values from the 'score' variable
  data_filtered <- na.omit(data)

  # Calculate the mean for each combination of condition and session
  mean_data <- aggregate(score ~ condition + session, data_filtered, mean)

  ggplot(data_filtered, aes(x = score, fill = factor(session))) +
    geom_histogram(color = "black", fill = "white", position = "dodge", bins = 30, alpha = 0.7) +
    facet_grid(condition ~ session) +
    geom_vline(data = mean_data, aes(xintercept = score),  # Add a vertical line at the mean of 'score'
               color = "red",                 # Color of the line
               linetype = "dashed",           # Line type (dashed)
               linewidth = 0.5) +                  # Line thickness
    labs(title = paste("Score Distributions - ", dataset),
         x = "Score", y = "Frequency",
         fill = "Session") +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"))
}
