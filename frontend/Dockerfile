FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules/serve ./node_modules/serve
EXPOSE 8080
CMD ["node", "node_modules/serve/bin/serve.js", "-s", "dist", "-l", "8080"]
