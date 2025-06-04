library(lme4)
library(MuMIn)
library(emmeans)
library(dplyr)
library(tidyr)
library(rlang)

individual_differences <- function(data, model, outcome) {

  # Dynamically construct the formula
  f_model_1 <- as.formula(paste0(outcome, " ~ as.factor(session) + (1|participant)"))
  f_model_2 <- as.formula(paste0(outcome, " ~ condition * as.factor(session) * highest_degree + (1|participant)"))

  # Fit models
  model_1 <- lmer(f_model_1, data = data)
  model_2 <- lmer(f_model_2, data = data)

  # Look at the variance explained by the models
  r_squared_education <- rbind(r.squaredGLMM(model_1),
                        r.squaredGLMM(model),
                        r.squaredGLMM(model_2))

  # Perform likelihood ratio test
  lr_education <- anova(model_1, model, model_2)

  # Multiple comparisons with the new model
  tukey_education <- emmeans(model_2, list(pairwise ~ highest_degree,
                                    pairwise ~ session:highest_degree,
                                    pairwise ~ session:condition:highest_degree), adjust = "tukey")

  # Pivot to wide format
  vars_to_keep <- c("participant", "condition", "session", "highest_degree", "EPT", outcome)
  vars_in_data <- names(data)

  # Ensure only the necessary variables are kept
  clean_data <- data %>%
    select(all_of(intersect(vars_to_keep, vars_in_data)))

  # Transform data to wide format
  if (all(c("Pre", "Post") %in% unique(clean_data$session))) {
    data_wide <- clean_data %>%
      pivot_wider(names_from = session, values_from = all_of(outcome), names_prefix = "score_") %>%
      mutate(change_score = score_Post - score_Pre)

    # Fit the linear regression for baseline WM
    model_inWM <- lm(change_score ~ score_Pre * condition, data = data_wide)

    # Separate by group
    model_inWM_tDCS <- lm(change_score ~ score_Pre, data = subset(data_wide, condition == "tDCS"))
    model_inWM_Control <- lm(change_score ~ score_Pre, data = subset(data_wide, condition == "Control"))

  } else if (all(c("1", "6") %in% unique(as.character(clean_data$session)))) {
    data_wide <- clean_data %>%
      mutate(session = as.character(session)) %>% # Ensure session values are character for naming
      pivot_wider(names_from = session, values_from = all_of(outcome), names_prefix = "score_") %>%
      mutate(change_score = score_6 - score_1)

    # Fit the linear regression for baseline WM
    model_inWM <- lm(change_score ~ score_1 * condition, data = data_wide)

    # Separate by group
    model_inWM_tDCS <- lm(change_score ~ score_1, data = subset(data_wide, condition == "tDCS"))
    model_inWM_Control <- lm(change_score ~ score_1, data = subset(data_wide, condition == "Control"))

  } else {
    stop("Cannot determine session coding: expected either Pre/Post or numeric 1/6")
  }

  # Fit the Linear regression with problem-solving scores (use EPT scores as predictor)
  if ("EPT" %in% names(data_wide)) {
    model_EPT <- lm(change_score ~ EPT*condition, data = data_wide)

    # Separate by group
    model_EPT_tDCS    <- lm(change_score ~ EPT, data = subset(data_wide, condition == "tDCS"))
    model_EPT_Control <- lm(change_score ~ EPT, data = subset(data_wide, condition == "Control"))
  } else {
    model_EPT <- NULL
    model_EPT_tDCS <- NULL
    model_EPT_Control <- NULL
  }

  return(list(
    r_squared_education = r_squared_education,
    lr_education = lr_education,
    tukey_education = tukey_education,
    model_inWM = model_inWM,
    model_inWM_tDCS = model_inWM_tDCS,
    model_inWM_Control = model_inWM_Control,
    model_EPT = model_EPT,
    model_EPT_tDCS = model_EPT_tDCS,
    model_EPT_Control = model_EPT_Control
  ))
}
