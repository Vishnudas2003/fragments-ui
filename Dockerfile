####################################################################################################
# Stage 1: Install dependencies
####################################################################################################

FROM node:18.12.0-bullseye@sha256:8d9a875ee427897ef245302e31e2319385b092f1c3368b497e89790f240368f5 AS dependencies

LABEL maintainer="Vishnu Das Puthukudi <vdputhukudi@myseneca.ca>"
LABEL description="Fragments UI web app"

# Reduce npm spam when installing within Docker
# https://docs.npmjs.com/cli/v8/using-npm/config#loglevel
ENV NPM_CONFIG_LOGLEVEL=warn

# Disable colour when run inside Docker
# https://docs.npmjs.com/cli/v8/using-npm/config#color
ENV NPM_CONFIG_COLOR=false

# Set the NODE_ENV to production
ENV NODE_ENV=production

# Use /app as our working directory
WORKDIR /app

# Copy our package.json/package-lock.json in
COPY package* .

# Install node dependencies defined in package.json and package-lock.json
RUN npm ci

####################################################################################################
# Stage 2: Build the app
####################################################################################################

FROM node:18.12.0-bullseye@sha256:8d9a875ee427897ef245302e31e2319385b092f1c3368b497e89790f240368f5 AS build

# Use /app as our working directory
WORKDIR /app

# Copy generated node_modules from dependencies stage
COPY --from=dependencies /app/ /app/

# Copy everything else into /app
COPY . .

# Run the server
CMD npm run build

####################################################################################################
# Stage 3: serve the app
####################################################################################################
FROM nginx:stable-alpine@sha256:74694f2de64c44787a81f0554aa45b281e468c0c58b8665fafceda624d31e556 AS deploy
# COPY items we need to run
COPY --from=build /app/dist /usr/share/nginx/html
# We run our service on port 8080
EXPOSE 80