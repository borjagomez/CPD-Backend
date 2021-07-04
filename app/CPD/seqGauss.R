# seqGauss.R: Detect changes in sequential data containing 
# one change point.
#
# Simple eaxample of a Gaussian stream which undergoes a change 
# in mean from 0 to 0.5, occuring after 200 observations

# Parameters
# Average Run Length that the method should have. 
# The thresholds h_t are chosen to satisfy this ARL.
ARL0 = 400

# Working directory is where this script is at.
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

# Load required packages
library(cpm)
library(R.utils)   # for printf

# Generate Gaussian time series with one change point 
set.seed(0)
x <- c(rnorm(200, 0, 1), rnorm(200, 0.5, 1))

# Detect change point
results <- detectChangePoint(x, cpmType = "Student", 
                             ARL0 = ARL0)

# Plot the sequence of observations along with the estimated CP 
# and detection time.
plot(x, type = "l", xlab = "Observation", ylab = "x", bty = "l")
if (results$changeDetected) {
  abline(v = results$changePoint, lty = 2)
  abline(v = results$detectionTime, lty = 2, col = "red")
}

# Plot the maximized statistics $D_t$ for every t, along 
# with the varying thresholds $h_t$.
plot(results$Ds, type = "l", xlab = "Observation",
     ylab = expression(D[t]), bty = "l", ylim = c(0,5))
lines(results$thresholds, col = "red")

# Print CP estimate and detection time:
printf("Change point estimate: %f\n", results$changePoint)
printf("Detection time:        %f\n", results$detectionTime)