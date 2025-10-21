# Use official Node.js LTS
FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy app source
COPY src/ ./src

# Expose port
EXPOSE 3000

# Start the app
CMD ["node", "src/index.js"]
