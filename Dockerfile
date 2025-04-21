# Stage 1: Build Flutter app
FROM ubuntu:latest as build

# Install dependencies
RUN apt-get update && apt-get install -y curl git unzip

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
ENV PATH="/flutter/bin:${PATH}"

# Copy and build Flutter app
WORKDIR /app
COPY main/ /app/main/
WORKDIR /app/main
RUN flutter pub get
RUN flutter build web

# Stage 2: Serve static files with Node.js
FROM node:18-alpine
WORKDIR /app

# Copy built Flutter files and server code
COPY --from=build /app/main/build/web /app/build/web
COPY server/package.json /app/package.json
COPY server/server.js /app/server.js

# Install Node.js dependencies
RUN npm install

# Start the server
CMD ["npm", "start"]
