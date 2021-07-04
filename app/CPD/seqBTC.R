# batchBTC.R: Detect changes in sequential data containing 
# one change point.
#
# Time series: Daily log-returns of Bitcoin
# for the year to date.

# Parameters
# Average Run Length that the method should have. 
# The thresholds h_t are chosen to satisfy this ARL.
ARL0 = 800

Sys.setlocale("LC_ALL", "en_US.UTF-8")

# Working directory is where this script is at.
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

# Load required packages
library(cpm)
library(quantmod)   # for getSymbols
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
results <- detectChangePoint(x, cpmType = "Cramer-von-Mises",
                                  ARL0 = ARL0)

changePoint <- results$changePoint
changePointDate <- start(tsReturns) + changePoint
detectionTime <- results$detectionTime
detectionTimeDate <- start(tsReturns) + detectionTime

# Print quantitative results
if (results$changeDetected) {
  printf("\nSEQUENTIAL DETECTION RESULTS:\n")
  printf("There is a change point on ")
  print(changePointDate)
  printf("Detection time ")
  print(detectionTimeDate)
  printf("Detection delay ")
  print(detectionTime-changePoint)
} else {
  print("No change point detected")
}

# Plot the associated statistic $D_{k,n}$ for every k, along 
# with the threshold $h_n$.
tsDs <- xts(x = results$Ds, order.by = dates[1:length(results$Ds)])
tsThresholds <- xts(x = results$thresholds[1:length(results$Ds)], 
                    order.by = dates[1:length(results$Ds)])

# Plot the sequence of observations along with the estimated CP
# and detection time.
chartSeries(closePrices, theme = chartTheme("white"), 
            TA=c(addTA(tsReturns), 
                 addTA(tsDs), 
                 addTA(tsThresholds, on=3, col = "red", legend = ""), 
                 addLines(v = results$changePoint), 
                 addLines(v = results$detectionTime, col = "red")))