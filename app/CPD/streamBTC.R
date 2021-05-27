# seqBTC.R: Detect changes in sequential data containing 
# multiple change points.
#
# Time series: Daily price of BTC in USD (at closing) 
# for the period Jan 2017 through today.

# Working directory is where this script is at.
#this.dir <- dirname(parent.frame(2)$ofile)
#setwd(this.dir)

# Load required packages
library(cpm)
library(quantmod)   # for getSymbols

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

# If you want to plot the results to a graphics file 
# instead of plotting it to the screen, uncomment this line
# and the last line (dev.off)
png(filename = "CPD.png")

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

# This stream is likely to have multiple change points, 
# so use the function processStream.
x <- returns
# Set ARL_0 to 5000 in order to avoid a large number of false alarms
results <- processStream(x, cpmType = "Cramer-von-Mises", ARL0 = 5000)

# Compute date of last CP
changePoint <- results$changePoints[length(results$changePoints)]
changePointDate <- start(tsReturns) + changePoint

# Plot the sequence of observations along with the estimated CP.
addLines(v=results$detectionTimes)
addLines(v=results$changePoints, col = "red")

dev.off()