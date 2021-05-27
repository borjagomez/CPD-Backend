# batchGaussian.R: Detect changes in a batch of data containing 
# at most one change point.
#
# Simple eaxample of a Gaussian stream which undergoes a change 
# in mean from 0 to 0.5, occuring after 200 observations

# Working directory is where this script is at.
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

# Load required packages
library(cpm)

set.seed(0)
x <- c(rnorm(200, 0, 1), rnorm(200, 0.5, 1))
results <- detectChangePointBatch(x, cpmType = "Student", 
                                  alpha = 0.05)

# Plot the sequence of observations along with the estimated CP.
plot(x, type = "l", xlab = "Observation", ylab = "x", bty = "l")
if (results$changeDetected)
  abline(v = results$changePoint, lty = 2)

# Plot the associated statistic $D_{k,n}$ for every k, along 
# with the threshold $h_n$.
plot(results$Ds, type = "l", xlab = "Observation",
     ylab = expression(D[t]), bty = "l")
abline(h = results$threshold, lty = 2)