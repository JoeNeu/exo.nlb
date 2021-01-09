FROM node:12

#Set a work directory inside the application
WORKDIR /

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY package*.json ./

RUN npm install

# Bundle app source
COPY . .

CMD [ "node", "autoscaler.js" ]
