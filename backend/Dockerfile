FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm install\
  && npm install typescript -g

COPY . .

RUN tsc

CMD ["npm", "start"]