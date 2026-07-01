# Stage 1: Build the React Application
FROM node:20-alpine AS builder
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci

# Copy the rest of the application code
COPY . .

# Build the project using Vite
RUN npm run build

# Stage 2: Serve the production build using Nginx
FROM nginx:alpine

# Copy custom Nginx configuration to handle React Routing correctly
COPY <<EOF /etc/nginx/conf.d/default.conf
server {
    listen 80;
    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
        try_files \$uri \$uri/ /index.html;
    }
}
EOF

# Copy build artifacts from stage 1
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

