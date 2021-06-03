FROM borjagomez/cpdbackend-base:latest

# Create app directory
WORKDIR /usr/src/app
ADD ./app /usr/src/app

RUN npm install
RUN cp -R /usr/src/app/node_modules /tmp/node_modules

EXPOSE 3000
CMD ["npm", "start"]
