# meanTest.R: Two-sample hypothesis test for shift in mean.
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
# We want to test the null hypothesis H_0 that no change exists 
# in mean
#   H_0: \mu_1 - \mu_2 = 0
# versus the alternative hypothesis H_1 that a change in mean 
# occurs immediately after time n_1
#   H_1: (\mu_1 - \mu_2) not equal to 0.
#
# We use a standard two-sample test with Student-t statistic T 
# at the \alpha = 0.05 level of significance.

# Working directory is where this script is at.
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

# Load required packages
library(R.utils)   # for printf

alpha = 0.01  # level of significance of the test

n1 = 10     # num of observations before the change point
n2 = 10     # num of observations after the change point
n = n1+n2   # total number of observations

# Generate Gaussian time series with one change point at k=10, 
# the first random sample consists of n_1 = 10 observations from a N(0,1)
# while the second sample consists of n_2 = 10 observations from a N(10,1).
set.seed(0)
rand_sample_1 = rnorm(n1, 0, 1)
rand_sample_2 = rnorm(n2, 2, 1)
x <- c(rand_sample_1, rand_sample_2)

# Plot the sequence of observations.
plot(x, type = "l", xlab = "Observation", ylab = "x", bty = "l")

# S = "pooled" estimator for the sd \sigma
sample_mean_1 = mean(rand_sample_1)
sample_mean_2 = mean(rand_sample_2)
sample_var_1 = var(rand_sample_1)
sample_var_2 = var(rand_sample_2)
S2 = ((n1-1)*sample_var_1 + (n2-1)*sample_var_2) / (n1+n2-2)
S = sqrt(S2)

# Test statistic T
T = (sample_mean_1 - sample_mean_2) / (S*sqrt(1/n1 + 1/n2))

# We use a two-tailed test. The rejection region for \alpha is
#   |t| > t_{\alpha/2} = t_{.025}.
df = n-2
t_alpha2 = qt(alpha/2, df, lower.tail = FALSE)

# Output result
printf("\nTwo-sample hypothesis test with significance level %f \n", alpha)

if (abs(T) > t_alpha2) {
  printf("Null hypothesis rejected: ")
  printf("There is a change in mean at time %d \n", n1)
} else {
  printf("Null hypothesis not rejected: ")
  printf("We can't conclude change in mean at time %d \n", n1)
}

# Compute p-value
p = 2*pt(abs(T), df = 18, lower.tail=FALSE)
printf("\nCOMPUTATION OF P-VALUE\n")
printf("Observed value of the test statistic is |t|=%f\n", abs(T))
printf("Test will confirm CP for all ")
printf("significance levels alpha > %f\n", p)