# AI/Dockerfile
FROM python:3.11-slim

# Set working dir
WORKDIR /app

# Install build tools for heavy libs (if needed), then cleanup
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc \
 && rm -rf /var/lib/apt/lists/*

# Copy dependency file
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy AI source code
COPY . .

# Expose the service port (Flask/FastAPI defaults to 5000)
EXPOSE 5000

# Run service
CMD ["python", "predict_api.py"]