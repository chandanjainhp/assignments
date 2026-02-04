# OpenOA Cloud Deployment Guide

This guide details how to deploy the **OpenOA** (Open Operational Assessment) project to a cloud server (e.g., Oracle Cloud, AWS, Azure, or DigitalOcean).

## 🏗️ Architecture Overview

- **Front-end**: Nginx (Reverse Proxy) on Port 80 -> Jupyter Lab on Port 8888.
- **Back-end**: Python Environment (Containerized).

## ✅ Prerequisites

1.  **Cloud Server (VM)**:
    -   Ubuntu 20.04/22.04 LTS or Oracle Linux.
    -   **RAM**: 2GB+ Recommended (If 1GB, you **MUST** use Swap Space).
    -   **Ports**: Open Port **80** (HTTP). (You can close 8888).
2.  **Software**: Docker & Docker Compose installed on the server.

---

## 🚀 Deployment Steps

### Step 1: Prepare the Server
Run these commands on your cloud server:

```bash
# 1. Update and Install Docker
sudo apt-get update
sudo apt-get install -y docker.io docker-compose-v2

# 2. Setup User Permissions
sudo usermod -aG docker $USER

# 3. (CRITICAL for < 2GB RAM) Add Swap Space
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# 4. Relogin
exit
# (Now SSH back in)
```

### Step 2: Deploy the Application
1.  **Transfer Files**: Copy the project folder to your server (use `scp` or `git clone`).
2.  **Start Docker**:
    ```bash
    cd OpenOA
    docker compose up -d --build
    ```

### Step 3: Access
-   **URL**: `http://<YOUR_SERVER_IP>:8888`
-   **Token**: `openoa`

---

## 🔒 Optional: Nginx Reverse Proxy
If using Nginx, add this to your site config to forward traffic from Port 80 -> 8888:

```nginx
location / {
    proxy_pass http://localhost:8888;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
}
```
*Note: If using Nginx, close Port 8888 in your firewall.*
