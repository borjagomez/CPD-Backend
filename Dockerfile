FROM borjagomez/cpdbackend-base:latest

# Create app directory
WORKDIR /usr/src/app
ADD ./app /usr/src/app

RUN npm install

EXPOSE 3000
CMD ["npm", "start"]
