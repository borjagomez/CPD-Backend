FROM node:14

# Create app directory
WORKDIR /usr/src/app
ADD ./app /usr/src/app

RUN npm install

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install r-base
RUN apt-get -y install r-recommended
RUN apt-get -y install r-base-dev
RUN Rscript -e 'install.packages(c("cpm", "quantmod"), ,repos = "http://cran.us.r-project.org")'

EXPOSE 3000
CMD [ "npm", "start" ]
