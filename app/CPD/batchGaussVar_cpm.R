# batchGauss.R: Detect changes in a batch of data containing 
# at most one change point.
#
# Simple eaxample of a Gaussian stream which undergoes a change 
# in mean from 0 to 0.5, occuring after 200 observations

# Working directory is where this script is at.
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

# Load required packages
library(cpm)

testCP <- function(x, cpmType, alpha, tau) {
  # Detect change point
  results <- detectChangePointBatch(x, cpmType, alpha)
  return(abs(tau - results$changePoint))
}

MAE1 = 0  # MAE of first method
MAE2 = 0  # MAE of second method (windowing+var)

for (s in 1:1000){  # Run 1000 Monte Carlo simulations
  
  # Generate Gaussian time series with one change point 
  set.seed(s)
  x <- c(rnorm(100, 0, 1), rnorm(100, 0, sqrt(3)))
  
  ###### First method: CPD on original time series ######
  
  error <- testCP(x, cpmType = "Cramer-von-Mises", alpha = 0.05, 100)
  MAE1 = MAE1 + error

  ###### Second method: windowing + var(window) + CPD ######
  
  X <- embed(x, dimension = 5)  # windows of size 5
  nwindows = dim(X)[1]
  
  # variances holds a time series with the var of each window
  variances <- vector(mode = "numeric", length = nwindows)
  for (i in 1:nwindows) {
    window = X[i,]
    variances[i] = var(window)
  }
  
  # Detect change point
  error <- testCP(variances, cpmType = "Cramer-von-Mises", alpha = 0.05, 100)
  MAE2 = MAE2 + error
}
MAE1 = MAE1 / 1000
MAE2 = MAE2 / 1000
print(MAE1)
print(MAE2)

# # Plot the sequence of observations along with the estimated CP.
# plot(x, type = "l", xlab = "Observation", ylab = "x", bty = "l")
# if (results$changeDetected)
#   abline(v = results$changePoint, lty = 2)
# 
# # Plot the associated statistic $D_{k,n}$ for every k, along 
# # with the threshold $h_n$.
# plot(results$Ds, type = "l", xlab = "Observation",
#      ylab = expression(D[t]), bty = "l")
# abline(h = results$threshold, lty = 2)


# # Plot the sequence of observations along with the estimated CP.
# plot(variances, type = "l", xlab = "Observation", ylab = "x", bty = "l")
# if (results$changeDetected)
#   abline(v = results$changePoint, lty = 2)
# 
# # Plot the associated statistic $D_{k,n}$ for every k, along 
# # with the threshold $h_n$.
# plot(results$Ds, type = "l", xlab = "Observation",
#      ylab = expression(D[t]), bty = "l")
# abline(h = results$threshold, lty = 2)

