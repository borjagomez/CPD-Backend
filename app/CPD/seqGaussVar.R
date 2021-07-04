# seqGauss.R: Detect changes in sequential data containing 
# one change point.
#
# Simple eaxample of a Gaussian stream which undergoes a change 
# in mean from 0 to 0.5, occuring after 200 observations

# Working directory is where this script is at.
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

# Load required packages
library(cpm)

# Generate Gaussian time series with one change point 
set.seed(0)
x <- c(rnorm(100, 0, 1), rnorm(100, 0, 3))

# Detect change point
results <- detectChangePoint(x, cpmType = "Cramer-von-Mises",
                             ARL0 = 500)
# results <- detectChangePoint(x, cpmType = "Student",
#                              ARL0 = 500)

# Plot the sequence of observations along with the estimated CP.
plot(x, type = "l", xlab = "Observation", ylab = "x", bty = "l")
if (results$changeDetected)
  abline(v = results$changePoint, lty = 2)

# Plot the maximized statistics $D_t$ for every t, along 
# with the varying thresholds $h_t$.
plot(results$Ds, type = "l", xlab = "Observation",
     ylab = expression(D[t]), bty = "l")
lines(results$thresholds, col = "red")