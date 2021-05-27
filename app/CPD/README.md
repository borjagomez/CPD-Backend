# Change Point Detection

## How to use this software

First and foremost, you need to install R.

All major linux distributions include R. 

Debian/Ubuntu: 

Use e.g. 

	apt-get install r-base r-recommended 

to install the R environment and recommended packages. Since we also want to
build R packages from source, also 

	run apt-get install r-base-dev 

to obtain the additional tools required for this.

Then, you need to install the R packages 'cpm' and 'quantmod' from CRAN. This
can be done from the command line with

	Rscript -e 'install.packages(c("cpm", "quantmod"))'

Finally, you can run each R script in this repository from the command line as
follows:

	Rscript streamBTC.R

(This particular example 'streamBTC.R' needs no parameters and generates an
image file called 'CPD.png').
