# Stage 1: Build React app
FROM node:18-alpine AS builder

WORKDIR /app

# Fix old webpack/react-scripts OpenSSL issue
ENV NODE_OPTIONS=--openssl-legacy-provider

# Copy dependency files first for caching
COPY package.json package-lock.json ./

# Reliable CI install
RUN npm ci --no-audit --no-fund

# Copy source code
COPY . .

# Create production build
RUN npm run build

# Stage 2: Serve with nginx
FROM nginx:alpine

# Remove default nginx html
RUN rm -rf /usr/share/nginx/html/*

# Copy React build
COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -q --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]