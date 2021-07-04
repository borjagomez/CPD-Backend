# batchGauss.R: Detect changes in a batch of data containing 
# at most one change point.
#
# Simple eaxample of a Gaussian stream which undergoes a change 
# in mean from 0 to 0.5, occuring after 200 observations

# Working directory is where this script is at.
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

# Load required packages
library(ecp)

# Generate Gaussian time series with one change point 
set.seed(10)
x <- matrix(c(rnorm(100, 0, 1), rnorm(100, 0, sqrt(3))))

# Detect change point
results <- e.divisive(x)

# Plot the sequence of observations along with the estimated CP.
plot(x, type = "l", xlab = "Observation", ylab = "x", bty = "l")
abline(v = results$estimates, lty = 2)
