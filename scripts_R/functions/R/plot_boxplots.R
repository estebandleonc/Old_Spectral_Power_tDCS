plot_boxplots <- function(data, dataset_name) {

  if (all(c("condition", "session") %in% names(data))) {
    boxplot(score ~ condition:session,
            col = c("white", "lightgray"),
            data = data,
            xlab = "Condition",
            ylab = "Score",
            main = paste("Boxplots of Scores by Condition and Session - ", dataset_name),
            cex.axis = 0.65)

      for (cond in unique(data$condition)) {
      boxplot(score ~ session,
              col = c("white", "lightgray"),
              data = subset(data, condition == cond),
              xlab = "Session",
              ylab = "Score",
              main = paste("Boxplots of Scores for ", cond, " group - ", dataset_name))
      }
  }

  if ("highest_degree" %in% names(data)) {
    boxplot(score ~ highest_degree,
            col = c("white", "lightgray"),
            data = data,
            xlab = "Highest Degree",
            ylab = "Score",
            main = paste("Boxplots of Scores for Education Level - ", dataset_name))
  }

  if ("sex" %in% names(data)) {
    boxplot(score ~ sex,
            col = c("white", "lightgray"),
            data = data,
            xlab = "Sex",
            ylab = "Score",
            main = paste("Boxplots of Scores for Sex - ", dataset_name))
  }

  if ("order_tests" %in% names(data)) {
    boxplot(score ~ order_tests,
            col = c("white", "lightgray"),
            data = data,
            xlab = "Order of Tests",
            ylab = "Score",
            main = paste("Boxplots of Scores for Order of Tests - ", dataset_name))
  }
}
