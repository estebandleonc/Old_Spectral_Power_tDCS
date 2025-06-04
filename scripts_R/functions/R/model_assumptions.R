model_assumptions <- function(model, label, xlim = NULL, ylim = NULL) {
  res <- resid(model)

  # QQ plot showing distribution of residuals
  qqnorm(res, main = paste("Q-Q Plot of Residuals - ", label))
  qqline(res, col = 'red', lwd = 1.5)

  # Histogram and density plot of residuals
  hist_res <- if (!is.null(xlim) && !is.null(ylim)) {
    hist(res, xlab = "Residuals", main = paste("Residuals Histogram - ", label),
                   xlim = xlim, ylim = ylim)
  } else if (!is.null(xlim)) {
    hist(res, xlab = "Residuals", main = paste("Residuals Histogram - ", label),
         xlim = xlim)
  } else if (!is.null(ylim)) {
    hist(res, xlab = "Residuals", main = paste("Residuals Histogram - ", label),
         ylim = ylim)
  } else {
    hist(res, xlab = "Residuals", main = paste("Residuals Histogram -", label))
  }

  density_res <- density(res) #density plot of residuals
  multiplier <- hist_res$counts / hist_res$density #re scale density
  density_res$y <- density_res$y * multiplier[1]
  lines(density_res, col = "red", lwd = 1.5) # add density line

  # Return Shapiro Test residuals
  return(shapiro.test(res))

  rm(hist_res, density_res, multiplier)
}
