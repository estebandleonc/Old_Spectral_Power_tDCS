define_factors <- function(data) {
  if ("condition" %in% names(data)) {
    data$condition <- factor(data$condition,
                             levels = c(1, 2),
                             labels = c("tDCS", "Control"))
  }

  if ("session" %in% names(data)) {
    unique_sessions <- unique(data$session)

    if (length(unique_sessions) <= 3) {
      data$session <- factor(data$session,
                             levels = c(1, 2, 3),
                             labels = c("Pre", "Post", "Follow-up"))
    }
  }

  if ("highest_degree" %in% names(data)) {
    data$highest_degree <- factor(data$highest_degree,
                                  levels = c(1, 2, 3),
                                  labels = c("High School", "Undergrad", "Postgrad"))
  }

  if ("sex" %in% names(data)) {
    data$sex <- factor(data$sex,
                       levels = c(1, 2),
                       labels = c("Male", "Female"))
  }

  if ("order_tests" %in% names(data)) {
    data$order_tests <- factor(data$order_tests,
                               levels = c(1, 2),
                               labels = c("COR_LET", "LET_COR"))
  }

  return(data)
}
