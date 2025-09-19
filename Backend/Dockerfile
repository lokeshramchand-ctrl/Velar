# backend/Dockerfile
FROM node:22

# Set working directory inside container
WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install only production dependencies
RUN npm install --production

# Copy backend source code (everything inside src)
COPY .. .

# Expose port
EXPOSE 3000

# Start app (server.js is inside src)
CMD ["node", "src/server.js"]
