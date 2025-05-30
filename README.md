# Runtime environment variables in React + Vite in dockerized NGINX containers

This is a small sample in how to set up a containerized React + Vite application to use runtime environment variables.
Normally react and vite applications transpile the environment variables during compile into the js or css files.

For production build this sample just sets a new replaceable token in the files by definig it in the .env.production file:

```
VITE_API_URL=__VITE_API_URL__
```

So for non production runtimes (like dev mode) you can still use the .env file to define the environment variables.

In the Dockerfile we specify two phases one for creating a production build of the application:

```
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
```

In the second pahse we copy the built artifacts form the build environment in a new container image bases on a nginx:1.28.0-alpine-slim

For replacing environment variables in the nginx configuration the templating feature of nginx docker image can be used. Copy files with a extension ".template" into the default templates directory: 
```
/etc/nginx/templates/
```
During startup nginx docker image automatically replaces environment variables with the help of envsubst and copies the file to /etc/nginx/conf.d directory:

```
20-envsubst-on-templates.sh: Running envsubst on /etc/nginx/templates/default.conf.template to /etc/nginx/conf.d/default.conf
```

For finally replacing the ```__VITE_API_URL__``` which we injected in the .env.production file we use the bash script in: 

```
scripts/replace-wellknown-vars.sh
```

The find commands finds all files in a directory specified by the ASSETS_DIR environment variable and replaces with the help of sed the ```__VITE_API_URL__``` token with the value from the environment variable during startup time.

For executing the script properly we copy it to /docker-entrypoint.d directory within the nginx container - another nice extensionpoint of the nginx container.

## Security Consideration

For security reasons, I recommend avoiding a generic approach to replacing all environment variables injected at container startup. Instead, explicitly replace each variable by name within this script.

Please be cautious using environment variables. If you need to load sensitive information into the frontend, ensure it's done securely by requesting it from the backend — using proper encryption and authentication for transfer and data in rest.

