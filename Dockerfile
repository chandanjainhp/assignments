FROM python:3.10-slim

# Set Python environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Upgrade pip, setuptools, and wheel first
RUN pip install --upgrade pip setuptools wheel

# Copy project files
COPY . .

# Install the package with 'examples' extra to get jupyterlab
# using -e for editable install since we are mounting the volume in compose
RUN pip install -e .[examples]

# Expose Jupyter port
EXPOSE 8888

# Default command
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--allow-root", "--no-browser", "--IdentityProvider.token=openoa"]
