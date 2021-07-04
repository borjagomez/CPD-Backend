# statsBTC.R: Descriptive statistics of Bitcoin's price.
#
# Time series: Daily log-returns of Bitcoin
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

# Graph the log returns against time
print(plot(tsReturns))

printf("DESCRIPTIVE STATISTICS of data set\n")
print(summary(returns))
printf("\n")
printf("Expected log-return per day: %f\n", mean(returns))
printf("SD of log-return per day: %f\n\n", sd(returns))
# boxplot to check how well is data distributed
boxplot(returns, horizontal = TRUE, main = "log-returns")

# Eliminate outliers
Q <- quantile(returns, probs=c(.25, .75), na.rm = FALSE, names = FALSE)
iqr <- IQR(returns)
up <-  Q[2]+1.5*iqr # Upper Range  
low<- Q[1]-1.5*iqr # Lower Range
print((Q[1] - 5*iqr))
print(Q[2] + 5*iqr)
returns_no <- subset(returns, 
                    returns > (Q[1] - 5*iqr) & returns < (Q[2]+5*iqr))
# boxplot to check how well is data distributed
boxplot(returns_no, horizontal = TRUE, main = "log-returns (no outliers)")

# Histogram of returns
hist(returns_no)
# Quantile-Quantile plot of returns to check for 
# heavy tails
qqnorm(returns_no)
qqline(returns_no, col="red")

# Shapiro-Wilk's normality test.
# H_0: sample distr is normal,
# H_1: sample distr is not normal.
# If p-value < 0.05, say, then reject H_0
shapiro.test(returns_no)