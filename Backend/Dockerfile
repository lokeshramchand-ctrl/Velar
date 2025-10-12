# backend/Dockerfile
FROM node:22

# Set working directory
WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --omit=dev

# Copy backend source code
COPY . .

# Expose app port
EXPOSE 3000

# Start app
CMD ["node", "src/server.js"]
