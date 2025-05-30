# Stage 1: Build the React app
FROM node:20-alpine AS build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to install dependencies
COPY package*.json ./

# Install dependencies using npm
RUN npm install

# Copy the rest of the application source code into the container
COPY . .

# Build the React application for production
RUN npm run build

# Stage 2: Serve the app using Nginx
FROM nginx:1.28.0-alpine-slim

# Copy the Nginx configuration template
COPY nginx.conf.template /etc/nginx/templates/default.conf.template

# Copy the production build files from the build stage
COPY --from=build /app/dist /usr/share/nginx/html

# entrypoint script
COPY scripts/replace-wellknown-vars.sh /docker-entrypoint.d/99-replace-vars.sh

CMD ["nginx","-g","daemon off;"]

# Expose port 8080 to serve the application
EXPOSE 80