
################################################################################
# Analysis Script (training tasks as predictors of WM tests' scores)
# Author: Esteban León-Correa
# Last updated: 30/05/2025
################################################################################

# Load required packages
library(here)
library(haven)
library(devtools)

### Turn off scientific notation
options(scipen = 999)

### Load package of functions
load_all("C:/Users/Esteban/Desktop/Github/tDCS/scripts_R/functions")

################################################################################
# READ DATA
################################################################################

# Tests of interest
tests <- c("LET_RET", "LET_MAN", "COR_RET", "COR_MAN")
formula_complete <- c("difference ~ condition*(diff_ds + diff_max_ds)",
                      "difference ~ diff_ds + diff_max_ds",
                      "difference ~ condition*(diff_nb + diff_max_nb)",
                      "difference ~ diff_max_ds")
formula_tDCS <- c("difference ~ diff_ds + diff_max_ds",
                  "difference ~ diff_ds + diff_max_ds",
                  "difference ~ diff_nb + diff_max_nb",
                  "difference ~ diff_ds + diff_max_ds")
formula_control <- c("difference ~ diff_ds + diff_max_ds",
                     "difference ~ diff_ds + diff_max_ds",
                     "difference ~ diff_nb + diff_max_nb",
                     "difference ~ diff_max_ds")

# Load dataset and define factors
data <- read_sav(here::here("datasets", "Complete_dataset.sav")) %>%
  define_factors()

# Filter the dataset to include only sessions pre and post
pre_post <- subset(data, session %in% c("Pre", "Post"))

###############################################################################
# CONDUCT ANALYSIS
###############################################################################

# Create list to store results
results_training_tests <- list()

# Loop over each test to conduct regressions
for (i in seq_along(tests)) {
  test <- tests[i]
  results_training_tests[[test]] <- regression_training_tests(pre_post,
                                               test,
                                               as.formula(formula_complete[i]),
                                               as.formula(formula_tDCS[i]),
                                               as.formula(formula_control[i])
  )
}

# Save results
saveRDS(results_training_tests, here::here("results", "regressions_training_tests_results.rds"))
