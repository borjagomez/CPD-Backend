# streamBTC.R: Detect changes in sequential data containing 
# multiple change points.
#
# Time series: Daily log-returns of Bitcoin
# for the year to date.

# Parameters
# cpmType = "Mann-Whitney"      # changes in mean
# cpmType = "Mood"              # changes in variance
cpmType = "Cramer-von-Mises"  # general changes in distribution

# Average Run Length that the method should have. 
# The thresholds h_t are chosen to satisfy this ARL.
# Set ARL_0 to >= 800 in order to avoid many false alarms
ARL0 = 1000

Sys.setlocale("LC_ALL", "en_US.UTF-8")

# Working directory is where this script is at.
# this.dir <- dirname(parent.frame(2)$ofile)
# setwd(this.dir)

# Load required packages
library(cpm)
library(quantmod)   # for getSymbols
library(R.utils)   # for printf

# Import an one dimension time series as an xts object. 
# Here we use Bitcoin data from the specified dates
BTCUSD <- getSymbols("BTC-USD", src='yahoo', from=Sys.Date() - 365, 
                     to=Sys.Date(), auto.assign = FALSE)
closePrices <- BTCUSD[,4]

# Bitcoin data is not available for some days in the time series 
# for whatever reason.
# Replace these 'NA' values with the approximate value obtained via linear
# interpolation of neighboring dates.
print(sum(is.na(closePrices)))
closePrices = na.approx(closePrices)
print(sum(is.na(closePrices)))

# If you want to plot the results to a graphics file 
# instead of plotting it to the screen, uncomment this line
# and the last line (dev.off)
png(filename = "CPD.png", width = 1280, height = 720, units = "px")

# Compute daily returns
vClosePrices <- as.numeric(closePrices) # convert closePrices to numeric vector
n <- length(vClosePrices)
# Continuously compounded returns
returns <- log(vClosePrices[2:n]) - log(vClosePrices[1:n-1])

# Create a Date class object with the dates in the 'returns' time series
# dates <- index(closePrices)
# dates <- dates[-1]  # drop first date

# Convert returns to time series object
# tsReturns = xts(x = returns, order.by = dates)

# This stream is likely to have multiple change points, 
# so use the function processStream.
x <- returns
results <- processStream(x, cpmType = cpmType, ARL0 = ARL0)

# Number of CPs found
nChangePoints = length(results$changePoints)

# Compute date of CPs and detection delays
changePointDates <- seq( as.Date("2011-07-01"), by=1, len=nChangePoints)

for (i in 1:nChangePoints) {
  changePoint = (results$changePoints)[i]
  detectionTime = (results$detectionTimes)[i]
  
  changePointDate <- (index(closePrices))[2] + changePoint
  changePointDates[i] <- changePointDate
  
  printf("Change point at position %d", changePoint)
  printf(", on date ")
  print(changePointDate)
  printf("Detection delay: %d\n", detectionTime - changePoint)
}

# Plot the sequence of observations along with the estimated CP 
# and detection time.

events <- xts(letters[1:nChangePoints], changePointDates)

plot(closePrices)
if (nChangePoints>0) {
  addEventLines(events, lwd = 3, pos = 4)
}

# Plot the sequence of observations along with the estimated CPs
# and detection times.
# chartSeries(closePrices, theme = chartTheme("white"), 
#             TA=c(addLines(v = results$changePoints)))

# TA=c(addTA(tsReturns), 
#      addLines(v = results$changePoints)
#      addLines(v = results$detectionTimes, col = "red")
# ))

dev.off()