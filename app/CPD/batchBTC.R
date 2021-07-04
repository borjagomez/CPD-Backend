# batchBTC.R: Detect changes in a batch of data containing 
# at most one change point.
#
# Then perform statistical analysis of each data chunk:
# segmentLeft = observations up to the CP
# segmentRight = observations after the CP.
#
# Time series: Daily log-returns of Bitcoin
# for the year to date.

# Parameters
alpha = 0.05   # level of the test

Sys.setlocale("LC_ALL", "en_US.UTF-8")

# Working directory is where this script is at.
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

# Load required packages
library(cpm)
library(quantmod)   # for getSymbols
library(forecast)   # for Acf
library(R.utils)   # for printf

# Import an one dimension time series as an xts object. 
# Here we use Bitcoin data from the year to date
BTCUSD <- getSymbols("BTC-USD", src='yahoo', from=Sys.Date()-365,
                     to=Sys.Date(), auto.assign = FALSE)
closePrices <- BTCUSD[,4]

# Bitcoin data is not available for some days in the time series 
# for whatever reason.
# Replace these 'NA' values with the approximate value obtained via linear
# interpolation of neighboring dates.
print(sum(is.na(closePrices)))
closePrices = na.approx(closePrices)
print(sum(is.na(closePrices)))

# Compute daily returns
vClosePrices <- as.numeric(closePrices) # convert closePrices to numeric vector
n <- length(vClosePrices)
# Continuously compounded returns
returns <- log(vClosePrices[2:n]) - log(vClosePrices[1:n-1])

# Create a Date class object with the dates in the 'returns' time series
dates <- index(closePrices)
dates <- dates[-1]  # drop first date

# Convert returns to time series object
tsReturns = xts(x = returns, order.by = dates)

# Detect change point
x <- returns
# results <- detectChangePointBatch(x, cpmType = "Mann-Whitney",
#                                   alpha = alpha)
# results <- detectChangePointBatch(x, cpmType = "Mood",
#                                   alpha = alpha)
results <- detectChangePointBatch(x, cpmType = "Cramer-von-Mises",
                                  alpha = alpha)

changePoint <- results$changePoint
changePointDate <- start(tsReturns) + changePoint

# Print quantitative results
if (results$changeDetected) {
  printf("\nBATCH DETECTION RESULTS:\n")
  printf("There is a change point on ")
  print(changePointDate)
} else {
  print("No change point detected")
}

tsDs <- xts(x = results$Ds, order.by = dates)
tsThreshold <- xts(x = rep(results$threshold, length(dates)), 
                   order.by = dates)

# Plot the sequence of observations along with the estimated CP.
# Plot also the returns, and the associated 
# statistic $D_{k,n}$ for every k, alongwith the threshold $h_n$.
chartSeries(closePrices, theme = chartTheme("white"), 
            TA=c(addTA(tsReturns), 
                 addTA(tsDs), 
                 addTA(tsThreshold, on=3, col = "red")))
if (results$changeDetected) {
  addLines(v=changePoint)
}

# For clarity, replot the associated statistic $D_{k,n}$ 
# for every k, along with the threshold $h_n$.
plot(results$Ds, type = "l", xlab = "Observation",
     ylab = expression(D[t]), bty = "l")
abline(h = results$threshold, lty = 2)


# STATISTICAL ANALYSIS OF LEFT / RIGHT DATA SEGMENTS

# Divide data into two data segments, 
# one to the left of the breakpoint,
# and one to the right.
n <- length(x)
segmentLeft = x[1:changePoint]
segmentRight = x[(changePoint+1):n]

mean(segmentLeft)
sd(segmentLeft)
mean(segmentRight)
sd(segmentRight)

# Plot the two histograms on one chart
# Choose transparent colors
c1 <- rgb(173,216,230,max = 255, alpha = 80, names = "lt.blue")
c2 <- rgb(255,192,203, max = 255, alpha = 80, names = "lt.pink")
mi <- min(x) - 0.001 # Set the minimum for the breakpoints
ma <- max(x) + 0.001 # Set the maximum for the breakpoints
ax <- pretty(x, n = 15) # Make a neat vector for the breakpoints
ax
histL <- hist(segmentLeft, breaks = ax, plot = FALSE)
histR <- hist(segmentRight, breaks = ax, plot = FALSE)
plot(histL, col = c1) # Plot 1st histogram using a transparent color
plot(histR, col = c2, add = TRUE) # Add 2nd histogram using different color
title(sub = "Blue = left segment, Red = right segment")

# Quantile-Quantile plot of left segment
qqnorm(segmentLeft, main = "Normal Q-Q Plot of Left Segment")
qqline(segmentLeft, col="red")

# Quantile-Quantile plot of right segment
qqnorm(segmentRight, main = "Normal Q-Q Plot of Right Segment")
qqline(segmentRight, col="red")

# Autocorrelationplot of left segment
Acf(segmentLeft)
Acf(segmentRight)

# Shapiro-Wilk's normality test.
# H_0: sample distr is normal,
# H_1: sample distr is not normal.
# If p-value < 0.05, say, then reject H_0
shapiro.test(segmentLeft)
shapiro.test(segmentRight)