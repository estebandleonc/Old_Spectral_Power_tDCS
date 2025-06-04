library(dplyr)
library(tidyr)

regression_training_tests <- function(data, test, formula_complete, formula_tDCS, formula_control) {

  # Subtract post - pre
  data_filtered <- data %>%
    select(participant, condition, session, test, diff_ds, diff_max_ds, diff_nb, diff_max_nb) %>%
    pivot_wider(names_from = session, values_from = test) %>%
    mutate(difference = Post - Pre)
  
  # Fit a linear regression model with training measures as predictors
  model <- lm(formula_complete, data = data_filtered)
  
  # Fit a linear regression model for each condition
  model_tDCS <- lm(formula_tDCS, data = filter(data_filtered, condition == "tDCS"))
  model_control <- lm(formula_control, data = filter(data_filtered, condition == "Control"))
  
  # Combine everything into one list
  predictors <- list(
    model_complete = model,
    model_tDCS     = model_tDCS,
    model_control  = model_control
  )
}
  
