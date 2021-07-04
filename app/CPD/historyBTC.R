# historyBTC.R: historical data of Bitcoin's price.
#
# Time series: Daily price of BTC in USD (at closing) 
# for the period Jan 2017 through today.

# Set language of plots, messagest, etc. to English (US)
# This is not necessary if you have an English system.
Sys.setlocale("LC_ALL", "en_US.UTF-8")

# Working directory is where this script is at.
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

# Load required packages
library(quantmod)   # for getSymbols, chartSeries, addTA
library(R.utils)    # for printf

# Import an one dimension time series as an xts object. 
# Here we use Bitcoin data from the specified dates
BTCUSD <- getSymbols("BTC-USD", src='yahoo', from="2017-01-01", 
                     to=Sys.Date(), auto.assign = FALSE)

# Get a feel for the data.
# Display the structure of theBTCUSD object
str(BTCUSD)
# Show first part of the BTCUSD object
print(head(BTCUSD))

# We will work only with prices at close of market
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
# returns <- (vClosePrices[2:n] - vClosePrices[1:n-1])  # simple returns
# returns <- (vClosePrices[2:n] - vClosePrices[1:n-1]) / vClosePrices[1:n-1]
# Continuously compounded returns
returns <- log(vClosePrices[2:n]) - log(vClosePrices[1:n-1])

# Create a Date class object with the dates in the 'returns' time series
dates <- index(closePrices)
dates <- dates[-1]  # drop first date

# Convert returns to time series object
tsReturns = xts(x = returns, order.by = dates)

# Graph the price data and returns against time
chartSeries(closePrices, theme = chartTheme("white"), 
            TA=c(addTA(tsReturns)))