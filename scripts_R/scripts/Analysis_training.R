
################################################################################
# Analysis Script (training tasks)
# Author: Esteban León-Correa
# Last updated: 29/05/2025
################################################################################

# Load required packages
library(here)
library(haven)
library(dplyr)
library(devtools)

### Turn off scientific notation
options(scipen = 999)

### Load package of functions
load_all("C:/Users/Esteban/Desktop/Github/tDCS/scripts_R/functions")

################################################################################
# READ DATA
################################################################################

# Training tasks of interest
tasks = c("digit_span", "max_digit", "n_back", "max_nback")
y_limits_line_chart = list(c(40, 120), c(4, 8), c(200, 800), c(2, 4.5))
assumptions_y_limits = list(c(0, 50), NULL, c(0, 80), c(0, 80))
assumptions_x_limits = list(c(-40, 40), c(-3, 3), c(-300, 300), c(-2, 2))
names(y_limits_line_chart) <- tasks
names(assumptions_y_limits) <- tasks
names(assumptions_x_limits) <- tasks

# Load dataset and define factors
data_training <- read_sav(here::here("datasets", "Training.sav")) %>%
  define_factors() %>%
  mutate(condition_session = interaction(condition, session, sep = "_"))

results <- list()
shapiro_test_model_residuals <- list()
individual_diff_results <- list()

################################################################################
# CONDUCT ANALYSIS
################################################################################

# Loop through each dataset
for (task in tasks) {

  # Create line charts
  plot <- line_chart(data_training, variable = task, y_limits_line_chart[[task]], title = task)
  
  # Save line chart
  ggsave(filename = here::here("figures", paste0("Mean_scores_", task, ".png")), plot = plot, width = 8, height = 6)
  
  # Run Linear Mixed Effects Model
  results[[task]] <- run_LMEM(data_training, task, task)
  
  # Check residuals and assumptions
  shapiro_test_model_residuals[[task]] <- model_assumptions(results[[task]]$model, task, assumptions_x_limits[[task]], assumptions_y_limits[[task]])
  
  # Explore individual differences: higher degree and WM baseline
  individual_diff_results[[task]] <- individual_differences(data_training, results[[task]]$model, outcome = task)
}

################################################################################
# SAVE VARIABLES
################################################################################

# Organise data
training_results <- list()
training_results$results <- results
training_results$shapiro_test_model_residuals <- shapiro_test_model_residuals
training_results$individual_differences <- individual_diff_results

# Save variables
saveRDS(training_results, here::here("results", "training_results.rds"))
