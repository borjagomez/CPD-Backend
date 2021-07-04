# meanTest_ML.R: Maximum Likelihood test for shift in mean.
#
# Assume that 2 independent random samples are selected 
# from each of two normal populations:
#   X_1, X_2, ... X_{n_1} ~ N(\mu_1, \sigma_1)
#   X_1, X_2, ... X_{n_2} ~ N(\mu_2, \sigma_2).
# Both populations possess equal variances 
#   \sigma_1 = \sigma_2 = \sigma
# but possibly different means
#   \mu_1, \mu_2.
#
# We want to test the null hypothesis H_0 that there is no 
# change in the distribution
#   H_0: X_i ~ N(\mu_1, \sigma²) for all i=1,2,...,n
# versus the alternative hypothesis H_1 that there is a 
# change in distribution somewhere in thesequence
#   H_1: X_i ~ N(\mu_1, \sigma²) for i <= k, 
#        X_i ~ N(\mu_2, \sigma^2) for k < i <= n.
#
# We use a ML test with maximum value statistic T_max 
# at the \alpha = 0.05 level of significance.

# Working directory is where this script is at.
# this.dir <- dirname(parent.frame(2)$ofile)
# setwd(this.dir)

# Load required packages
library(R.utils)   # for printf

alpha = 0.05  # level of significance of the test

n1 = 200     # num of observations before the change point
n2 = 200     # num of observations after the change point
n = n1+n2   # total number of observations

# Generate Gaussian time series with one change point at k=10, 
# the first random sample consists of n_1 observations from a N(0,1)
# while the second sample consists of n_2 observations from a N(0.5,1).
set.seed(0)
rand_sample_1 = rnorm(n1, 0, 1)
rand_sample_2 = rnorm(n2, 0.5, 1)
x <- c(rand_sample_1, rand_sample_2)

# Plot the sequence of observations.
plot(x, type = "l", xlab = "Observation", ylab = "x", bty = "l")

# Initialize empty vector that will contain the statistics
# T_k for k=2:n-2
T.stat <- vector(mode = "numeric", length = n)
T.stat[1] <- NA
T.stat[n-1] <- NA
T.stat[n] <- NA

for (k in 2:n-2) {     # k = candidate to CP location
  n1 = k
  n2 = n-k
  
  rand_sample_1 = x[1:k]
  rand_sample_2 = x[(k+1):n]
  
  # S = "pooled" estimator for the sd \sigma
  sample_mean_1 = mean(rand_sample_1)
  sample_mean_2 = mean(rand_sample_2)
  sample_var_1 = var(rand_sample_1)
  sample_var_2 = var(rand_sample_2)
  S2 = ((n1-1)*sample_var_1 + (n2-1)*sample_var_2) / (n1+n2-2)
  S = sqrt(S2)
  
  # Test statistic T
  T.stat[k] = (sample_mean_1 - sample_mean_2) / (S*sqrt(1/n1 + 1/n2))
}

# We use a ML test. The rejection region [h, +\inf) for \alpha 
# is given by the Bonferroni inequality
#   |t_max| > h = T^{-1}(1 - \alpha/(2(n-1)))
df = n-2
h = qt(1 - alpha/(2*(n-1)), df)

# Output result
printf("ML test with significance level %f \n", alpha)

if (max(abs(T.stat), na.rm = TRUE) > h) {
  changeDetected = TRUE
  changePoint = which.min(T.stat)   # MLE for change point
  printf("There is a change in mean at location %d\n", 
         changePoint)
} else {
  changeDetected = FALSE
  changePoint = 0
  printf("We can't conclude change in mean in the sequence\n")
}

# Plot the sequence of observations along with the estimated CP.
plot(x, type = "l", xlab = "Observation", ylab = "x", bty = "l")
if (changeDetected)
  abline(v = changePoint, lty = 2)

# Plot the associated statistic D_k = T_k for every k, 
# along with the threshold h
plot(abs(T.stat), type = "l", xlab = "Observation", ylab = "T_k", bty = "l")
abline(h = h, lty = "dashed")
