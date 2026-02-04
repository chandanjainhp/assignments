FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy project files
COPY . .

# Install the package with 'examples' extra to get jupyterlab
# using -e for editable install since we are mounting the volume in compose
RUN pip install --no-cache-dir -e .[examples]

# Expose Jupyter port
EXPOSE 8888

# Default command
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--allow-root", "--no-browser"]
