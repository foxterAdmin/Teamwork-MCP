# 1) Build stage
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# 2) Production image
FROM node:18-alpine
WORKDIR /app
# Sólo copiamos lo esencial del build
COPY --from=build /app/package*.json ./
COPY --from=build /app/build ./build
# Instalamos sólo prod deps
RUN npm ci --omit=dev
EXPOSE 3000
CMD ["node", "build/index.js"]
