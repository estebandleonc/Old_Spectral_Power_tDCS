library(lme4)
library(MuMIn)
library(effectsize)
library(emmeans)
library(sjstats)
library(lmerTest)

run_LMEM <- function(data, outcome, model_label) {

  # Fit model
  formula     <- as.formula(paste0(outcome, " ~ condition * as.factor(session) + (1|participant)"))
  model       <- lmer(formula, data = data) # Model
  ANOVA       <- anova(model)  # ANOVA
  effect_size <- effectsize::eta_squared(model, partial = TRUE) # Effect sizes
  r_squared   <- r.squaredGLMM(model) # R-squared

  # Post-hoc pairwise comparisons
  tukey <- emmeans::emmeans(model, list(pairwise ~ session,
                                        pairwise ~ condition,
                                        pairwise ~ session:condition), adjust = "tukey")

  return(list(
    model = model,
    anova = ANOVA,
    effect_size = effect_size,
    r_squared = r_squared,
    tukey = tukey,
    label = model_label
  ))
}
