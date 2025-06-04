library(dplyr)
library(stringr)
library(ggplot2)

line_chart <- function(data, variable, y_limits, title) {

  # Internal summary function
  compute_summary <- function(data, target_var) {
    data %>%
      mutate(target = .data[[target_var]]) %>%
      filter(!is.na(target)) %>% # remove missing values before grouping
      select(condition_session, target) %>%
      group_by(condition_session) %>%
      summarise(
        mean = mean(target, na.rm = TRUE),
        N = sum(!is.na(target)),
        se = sd(target, na.rm = TRUE) / sqrt(N),
        ci_upper = mean + qt(0.975, df = N - 1) * se,
        ci_lower = mean - qt(0.975, df = N - 1) * se,
        .groups = "drop"
      ) %>%
      mutate(
        condition = ifelse(grepl("^tDCS", condition_session), "tDCS", "Control"),
        session = as.numeric(str_extract(condition_session, "\\d+")),
        condition = factor(condition, levels = c("tDCS", "Control"))
      )
  }

  plot <- function(df, title, y_limits) {
    ggplot(df, aes(x = session, y = mean, group = condition, color = condition)) +
      geom_line(position = position_dodge(0.7), linewidth = 1) +
      geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.2, position = position_dodge(0.7)) +
      geom_point(position = position_dodge(0.7), size = 3) + # Add points to indicate mean values
      labs(title = title, x = "Session", y = "Mean Score") +
      theme_minimal() +
      scale_color_manual(values = c("Control" = "orange", "tDCS" = "blue")) + # set fill color to grayscale
      theme(
        panel.background = element_rect(fill = "white", colour = NA),
        plot.background = element_rect(fill = "white", colour = NA),  # << makes saved image background white
        legend.background = element_rect(fill = "white", colour = NA),
        axis.text.x = element_text(angle = 0, hjust = 0.5, vjust = 5, size = 14), # Optional: improve x-axis label appearance
        axis.title.x = element_text(size = 18),  # Increase x-axis title font size
        axis.text.y = element_text(size = 14), # Increase y-axis label font size
        axis.title.y = element_text(size = 18), # Increase size of title
        plot.title = element_text(size = 18, face = "bold", hjust = 0.5), # Adapt title
        legend.text = element_text(size = 16), # Change the font size of the legend text
        legend.title = element_text(size = 18, face = "bold")
      ) +
      scale_y_continuous(limits = y_limits) # Change the font size of the legend title
  }

  # Compute and return the plot
  summary_df <- compute_summary(data, variable)
  plot(summary_df, title, y_limits)
}
