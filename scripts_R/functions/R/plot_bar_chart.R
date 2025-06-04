library(ggplot2)
library(dplyr)
library(rlang)

plot_bar_chart <- function(data, dataset_name, outcome, factor) {

  # Tidy-eval versions of the column names
  outcome_sym <- sym(outcome)
  factor_sym <- sym(factor)

  # Obtain mean, confidence intervals and include a column to separate conditions
  summary_df <- data %>%
    select(!!factor_sym, !!outcome_sym) %>%
    group_by(!!factor_sym) %>%
    summarise(
      mean = mean(!!outcome_sym, na.rm = TRUE),
      N = sum(!is.na(!!outcome_sym)),
      se = sd(!!outcome_sym, na.rm = TRUE) / sqrt(n()),
      ci_upper = mean + qt(0.975, df = n() - 1) * se,
      ci_lower = mean - qt(0.975, df = n() - 1) * se),
      .groups = "drop"
    ) %>%
    mutate(condition = ifelse(grepl("^tDCS", !!factor_sym), "tDCS", "Control"),
           session = ifelse(grepl("Pre$", !!factor_sym), "Pre",
                            ifelse(grepl("Post$", !!factor_sym), "Post", "Follow_up")
           ))

  # Reorder factors
  summary_df$session   <- factor(summary_df$session, levels = c("Pre", "Post", "Follow_up"))
  summary_df$condition <- factor(summary_df$condition, levels = c("tDCS", "Control"))

  # Plot bar chart
  ggplot(summary_df, aes(x = session, y = mean, fill = condition)) +
    geom_bar(stat = "identity", position = position_dodge(), width = 0.7, color = "black") +
    geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.2, position = position_dodge(0.7)) +
    labs(title = paste("Mean scores and confidence intervals - ", dataset_name), x = "Session", y = "Mean Score") +
    theme_minimal() +
    scale_fill_manual(values = c("Control" = "#FFA07A", "tDCS" = "#4682B4")) + # set fill color
    theme(
      panel.background = element_rect(fill = "white", colour = NA),
      plot.background = element_rect(fill = "white", colour = NA),  # << makes saved image background white
      legend.background = element_rect(fill = "white", colour = NA),
      axis.text.x = element_text(angle = 0, hjust = 0.5, vjust = 5, size = 12), # Optional: improve x-axis label appearance
      axis.title.x = element_text(size = 14),  # Increase x-axis title font size
      axis.text.y = element_text(size = 12), # Increase y-axis label font size
      axis.title.y = element_text(size = 14), # Increase size of title
      plot.title = element_text(size = 14, face = "bold", hjust = 0.5) # Adapt title
    ) +
    scale_y_continuous(limits = c(0, 6), breaks = seq(0, 6, by = 1))  # Set y-axis max limit to 6
}
