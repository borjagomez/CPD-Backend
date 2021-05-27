# batchBTC.R: Detect changes in a batch of data containing 
# at most one change point.
#
# Time series: Daily price of BTC in USD (at closing) 
# for the period Jan 2017 through today.

# Working directory is where this script is at.
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

# Load required packages
library(cpm)
library(quantmod)   # for getSymbols
library(forecast)   # for Acf

# Import an one dimension time series as an xts object. 
# Here we use Bitcoin data from the specified dates
# getSymbols("BTC-USD", src='yahoo', from="2017-06-01", to="2018-05-31", warnings = FALSE)
BTCUSD <- getSymbols("BTC-USD", src='yahoo', from="2017-01-01", to=Sys.Date(), 
                     auto.assign = FALSE)
closePrices <- BTCUSD[,4]

# Bitcoin data is not available for some days in the time series 
# for whatever reason.
# Replace these 'NA' values with the approximate value obtained via linear
# interpolation of neighboring dates.
sum(is.na(closePrices))
closePrices = na.approx(closePrices)
sum(is.na(closePrices))

# Graph the data against time
chartSeries(closePrices, theme = chartTheme("white"))

# Compute daily percent returns
vClosePrices <- as.numeric(closePrices) # convert closePrices to numeric vector
n <- length(vClosePrices)
# returns <- (vClosePrices[2:n] - vClosePrices[1:n-1]) / vClosePrices[1:n-1]
returns <- (vClosePrices[2:n] - vClosePrices[1:n-1])

# Create a Date class object with the dates in the 'returns' time series
dates <- index(closePrices)
dates <- dates[-1]  # drop first date

# Convert returns to time series object
tsReturns = xts(x = returns, order.by = dates)

# Plot returns
addTA(tsReturns)

# Detect change point
x <- returns
results <- detectChangePoint(x, cpmType = "Cramer-von-Mises",
                                  ARL0 = 5000, startup = 20)
changePoint <- results$changePoint
changePointDate <- start(tsReturns) + changePoint

# Plot the associated statistic $D_{k,n}$ for every k, along 
# with the threshold $h_n$.
tsDs <- xts(x = results$Ds, order.by = dates)
addTA(tsDs)

# Plot the sequence of observations along with the estimated CP.
if (results$changeDetected) {
  addLines(v=changePoint)
}

# Plot the associated statistic $D_{k,n}$ for every k, along 
# with the threshold $h_n$.
plot(results$Ds, type = "l", xlab = "Observation",
     ylab = expression(D[t]), bty = "l")
lines(results$thresholds, col = "red")
