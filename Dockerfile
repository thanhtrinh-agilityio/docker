# syntax=docker/dockerfile:1

ARG NODE_VERSION=18.0.0
FROM node:${NODE_VERSION}-alpine as base

WORKDIR /usr/src/app
EXPOSE 3000

# Development
FROM base as dev
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci --include=dev
COPY . .
RUN chown -R node:node /usr/src/app
USER node
CMD npm run dev


# Test
FROM base as test
ENV NODE_ENV=test
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci --include=dev
COPY . .
RUN chown -R node:node /usr/src/app
USER node
RUN npm run test

# Production
FROM base as prod
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev
COPY . .
RUN chown -R node:node /usr/src/app
USER node
CMD ["node", "src/index.js"]
