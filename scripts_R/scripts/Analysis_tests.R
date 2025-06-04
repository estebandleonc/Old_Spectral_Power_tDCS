
################################################################################
# Analysis Script (WM tests)
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

# List of datasets
dataset_names <- c("LET_RET.sav", "LET_MAN.sav", "COR_RET.sav", "COR_MAN.sav")

# Loop through each dataset
for (dataset_name in dataset_names) {
  
  # Extract base name for output naming
  base_name <- tools::file_path_sans_ext(dataset_name)
  
  # Load dataset and define factors
  data <- read_sav(here::here("datasets", dataset_name)) %>%
    define_factors()

################################################################################
# DATA VISUALISATION AND ASSUMPTIONS CHECK
################################################################################
  
  # Create boxplots for every variable
  plot_boxplots(data, dataset_name = base_name)
  
  # Create a new factor representing the combination of 'condition' and 'session'
  data$condition_session <- interaction(data$condition, data$session)
  
  # Bar chart with confidence intervals
  plot_bar_chart(data, dataset_name = base_name, outcome = "score", factor = "condition_session") 
  
  # Save bar chart
  ggsave(filename = here::here("figures", paste0("Control_vs_tDCS_bar_chart_", base_name, ".png")), width = 8, height = 6)
  
  # Plot histogram
  plot_histogram(data, base_name)
  
  # Shapiro-Wilk tests by group
  shapiro_results <- tapply(data$score, data$condition_session, shapiro.test)
  
################################################################################
# LINEAR MIXED MODEL: PRE VS POST
################################################################################
  
  # Filter the data to include only PRE and POST sessions
  data_pre_post <- filter(data, session %in% c("Pre", "Post"))
  
  # Fit the linear mixed model only with PRE and POST sessions
  pre_post <- run_LMEM(data_pre_post, outcome = "score", base_name)

  # Model assumptions check: distribution of residuals and normality test
  shapiro_test_model_residuals <- model_assumptions(pre_post$model, base_name, xlim = c(-0.6, 0.6))
  
################################################################################
# INDIVIDUAL DIFFERENCES: PRE VS POST
################################################################################
  
  # Explore the effect of highest degree, baseline WM and problem solving
  individual_diff_results <- individual_differences(data_pre_post, pre_post$model, outcome = "score")
  
################################################################################
# FOLLOW-UP SESSION (POST vs FOLLOW-UP)
################################################################################
  
  # Filter the data to include only POST and FU sessions
  data_post_fu <- filter(data, session %in% c("Post", "Follow-up"))
  
  # Fit the linear mixed model only with POST and FU sessions
  fu <- run_LMEM(data_post_fu, outcome = "score", base_name)
  
################################################################################
# SAVE RESULTS
################################################################################

  # Organise data
  pre_post$shapiro_results <- shapiro_results
  pre_post$shapiro_test_model_residuals <- shapiro_test_model_residuals
  pre_post$individual_differences <- individual_diff_results
  
  # Create a list to store all the results
  results <- list()
  results$pre_post <- pre_post
  results$fu <- fu
  
  # Save results
  saveRDS(results, here::here("results", paste0("results_", base_name, ".rds")))
  message("Results saved for: ", base_name)
}

