# batchBTC_recursive_solution.R: 
# Detect changes in a batch of data containing 
# multiple change points.
#
# First, look for the ML change point in the batch.
# Then, divide the batch into two non-overlapping segments:
#   segmentLeft = observations up to the CP
#   segmentRight = observations after the CP.
# and apply batch detection individually to each segment.
#
# This "divide-and-conquer" strategy could be applied recursively
# until no CP is found in either segment.
#
# Time series: Daily log-returns of Bitcoin
# for the year to date.

# Parameters
alpha = 0.1   # level of the test

Sys.setlocale("LC_ALL", "en_US.UTF-8")

# Working directory is where this script is at.
# this.dir <- dirname(parent.frame(2)$ofile)
# setwd(this.dir)

# Load required packages
library(cpm)
library(quantmod)   # for getSymbols
library(R.utils)   # for printf

# Detect change point (batch detection) in a time series object, 
# and chart it.
detectChangePointBatchTS <- function(tsReturns, cpmType, alpha)
{
  x <- coredata(tsReturns)
  dates <- index(tsReturns)
  
  results <- detectChangePointBatch(x, cpmType, alpha)
  changePoint <- results$changePoint
  changePointDate <- start(tsReturns) + changePoint
  
  printf("\nBATCH DETECTION RESULTS:\n")
  if (results$changeDetected) {
    printf("There is a change point at position %d", changePoint)
    printf(", on date ")
    print(changePointDate)
  } else {
    printf("No change point detected\n")
  }
  
  plot(results$Ds, type = "l")
  abline(h = results$threshold, lty = 2)
  
  return(changePoint)
}

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

changePoint <- detectChangePointBatchTS(tsReturns, 
                                        cpmType = "Cramer-von-Mises", 
                                        alpha = alpha)

# Divide data into two data segments,
# one to the left of the breakpoint,
# and one to the right.
n <- length(returns)
tsSegmentLeft = tsReturns[1:changePoint]
tsSegmentRight = tsReturns[(changePoint+1):n]

# Apply batch CP detection individually to each segment
changePointLeft <- 
  detectChangePointBatchTS(tsSegmentLeft, cpmType = "Cramer-von-Mises",
                         alpha = alpha)
changePointRight <-
detectChangePointBatchTS(tsSegmentRight, cpmType = "Cramer-von-Mises",
                         alpha = alpha)

# Plot the sequence of observations along with the estimated CP.
# Plot also the returns, and the associated 
# statistic $D_{k,n}$ for every k, alongwith the threshold $h_n$.
chartSeries(closePrices, theme = chartTheme("white"), 
            TA=c(addTA(tsReturns), 
                 addLines(v=changePointLeft), 
                 addLines(v=changePoint),
                 addLines(v=changePoint+changePointRight)))

# For clarity, replot the associated statistic $D_{k,n}$ 
# for every k, along with the threshold $h_n$.
# plot(results$Ds, type = "l", xlab = "Observation",
#      ylab = expression(D[t]), bty = "l")
# abline(h = results$threshold, lty = 2)
