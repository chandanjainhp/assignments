# OpenOA Deployment - Technical Implementation Guide

## Project Overview
This document provides comprehensive technical details about the OpenOA deployment on Oracle Cloud infrastructure, including architecture, configuration, and implementation decisions.

---

## 1. Architecture Overview

### Infrastructure Stack
- **Server:** Oracle Cloud (1GB RAM, 1 Core CPU)
- **OS:** Ubuntu 20.04 LTS
- **Containerization:** Docker & Docker Compose
- **Reverse Proxy:** Nginx
- **Backend:** Python 3.10 with Jupyter Lab
- **SSL/TLS:** Let's Encrypt Certificate

### Service Architecture
```
Internet (HTTPS)
    ↓
Nginx (Port 443 & 80)
    ↓
Docker Network
    ├── nginx container
    └── openoa container (Jupyter Lab on 8888)
```

---

## 2. Docker Configuration

### Docker Compose Setup (v3.3)
```yaml
- nginx: Reverse proxy service (latest image)
- openoa: Custom Python application (built from Dockerfile)
```

**Why Docker Compose?**
- Service isolation and dependency management
- Easy scaling and reproducibility
- Volume mounting for live code updates
- Internal Docker network for service communication

### Dockerfile Optimization
```dockerfile
FROM python:3.10-slim
- Upgraded pip, setuptools, wheel to latest versions
- Set PYTHONUNBUFFERED=1 for real-time logging
- PYTHONDONTWRITEBYTECODE=1 to reduce overhead
- PIP_NO_CACHE_DIR=1 to minimize image size
```

**Key Features:**
- Editable installation (`pip install -e .[examples]`) for development
- Volume mounting for live code updates
- Minimal dependencies with slim Python image

---

## 3. Nginx Configuration

### HTTPS/SSL Implementation
**Configuration File:** `/etc/nginx/nginx.conf`

**Features Implemented:**
1. **HTTP to HTTPS Redirect**
   - All HTTP traffic (port 80) redirects to HTTPS (port 443)
   - Automatic protocol upgrade for all requests

2. **SSL/TLS Security**
   - TLSv1.2 and TLSv1.3 protocols
   - Strong cipher suites (HIGH:!aNULL:!MD5)
   - Server cipher preference enabled

3. **Reverse Proxy Configuration**
   - Backend proxy: `http://openoa:8888`
   - Header forwarding for client information
   - X-Forwarded-Proto for protocol preservation

4. **WebSocket Support**
   - Critical for Jupyter Lab real-time features
   - HTTP/1.1 upgrade mechanism
   - Connection upgrade headers

### SSL Certificate Management
- **Provider:** Let's Encrypt (Free, Auto-renewable)
- **Certificate Location:** `/etc/letsencrypt/live/aicompanionstudio.chandanjainhp.in/`
- **Mapped in Docker:** Volume mount to `/etc/nginx/certs/`
- **Domain:** aicompanionstudio.chandanjainhp.in

---

## 4. Deployment Process

### Step-by-Step Deployment
1. **Repository Setup**
   ```bash
   git clone https://github.com/NatLabRockies/OpenOA
   cd assignments
   ```

2. **Docker Compose Setup**
   ```bash
   docker-compose version: '3.3'
   docker-compose up -d --build
   ```

3. **SSL Certificate Installation**
   ```bash
   certbot certonly --standalone -d aicompanionstudio.chandanjainhp.in
   cp /etc/letsencrypt/live/.../*.pem ~/assignments/certs/
   ```

4. **Service Startup**
   - Nginx container starts automatically
   - Openoa container builds from Dockerfile
   - Services communicate via Docker network

### Command Reference
```bash
# Start services
sudo docker-compose up -d

# View logs
sudo docker-compose logs -f

# Check status
sudo docker-compose ps

# Rebuild image
sudo docker-compose up -d --build

# Stop services
sudo docker-compose down

# Test SSL
curl -k https://localhost/
```

---

## 5. Python Environment

### Package Management
- **Python Version:** 3.10-slim
- **Package Installer:** pip (upgraded)
- **Installation Method:** Editable install (`-e` flag)
- **Dependencies:** Examples extra includes Jupyter Lab

### Key Dependencies
- jupyter-lab: Interactive notebook environment
- openoa: Wind energy analysis framework
- pandas, numpy: Data processing
- plotly: Data visualization

### Environment Variables
```dockerfile
PYTHONUNBUFFERED=1              # Real-time output
PYTHONDONTWRITEBYTECODE=1       # No .pyc files
PIP_NO_CACHE_DIR=1              # Smaller image
PIP_DISABLE_PIP_VERSION_CHECK=1 # No pip warnings
```

---

## 6. Performance Optimization

### Resource Constraints (1GB RAM, 1 Core)
**Optimizations Made:**
1. **Slim Python Image**
   - Reduced base image size
   - Minimal unnecessary packages

2. **Pip Optimization**
   - No cache directory (`--no-cache-dir`)
   - Cache disabled in environment

3. **Python Configuration**
   - Unbuffered output for real-time logging
   - No bytecode generation

4. **Nginx Configuration**
   - Worker connections: 1024
   - Efficient reverse proxy
   - Minimal overhead

---

## 7. Security Implementation

### Security Features
1. **HTTPS/SSL**
   - All traffic encrypted
   - Auto-renewal with Let's Encrypt
   - Strong TLS protocols

2. **Access Control**
   - Jupyter Lab token authentication (`openoa`)
   - No public port exposure
   - Access only through Nginx reverse proxy

3. **Docker Isolation**
   - Services in isolated containers
   - Private Docker network
   - No direct host access

4. **Header Security**
   - X-Forwarded-Proto for HTTPS awareness
   - X-Real-IP for client identification
   - X-Forwarded-For for proxy chain tracking

---

## 8. Troubleshooting Guide

### Common Issues & Solutions

**Issue 1: Docker Compose Version Error**
```
Solution: Use version '3.3' (compatible with Docker Compose 1.25.0)
```

**Issue 2: Service Connection Refused**
```
Solution: Ensure Docker network communication
- Check: docker-compose ps
- Logs: docker-compose logs -f
```

**Issue 3: SSL Certificate Issues**
```
Solution: Verify certificate paths in docker-compose.yml
- Certs location: ./certs/cert.pem and ./certs/key.pem
- Permissions: sudo chown $USER:$USER certs/*
```

**Issue 4: Pip Warnings During Build**
```
Solution: Upgrade pip, setuptools, wheel in Dockerfile
- Already implemented in current version
```

**Issue 5: Jupyter Lab Access**
```
Solution: Access via https://aicompanionstudio.chandanjainhp.in
- Password: openoa
- No token needed if authenticated
```

---

## 9. Monitoring & Maintenance

### Regular Maintenance
```bash
# View real-time logs
sudo docker-compose logs -f

# Monitor resource usage
docker stats

# Update containers
sudo docker-compose pull
sudo docker-compose up -d

# SSL renewal (auto, but can force)
sudo certbot renew
```

### Health Checks
- **HTTPS Access:** Test at https://aicompanionstudio.chandanjainhp.in
- **Docker Status:** `sudo docker-compose ps`
- **Service Logs:** `sudo docker-compose logs`

---

## 10. Technology Decisions & Rationale

### Why Docker Compose?
- ✅ Simplified multi-container orchestration
- ✅ Easy service dependency management
- ✅ Reproducible deployments
- ✅ Volume mounting for development

### Why Nginx?
- ✅ Lightweight reverse proxy
- ✅ Excellent performance
- ✅ Native HTTPS/SSL support
- ✅ WebSocket support for Jupyter

### Why Let's Encrypt?
- ✅ Free SSL certificates
- ✅ Automatic renewal
- ✅ No manual management
- ✅ Industry standard

### Why Python 3.10-slim?
- ✅ Latest stable Python version
- ✅ Minimal base image (reduced memory)
- ✅ Sufficient for scientific computing
- ✅ Good balance of features and size

---

## 11. Future Enhancements

**Possible Improvements:**
1. Kubernetes deployment for scaling
2. Load balancing for multiple instances
3. Database backend (PostgreSQL)
4. API gateway layer
5. Monitoring and alerting (Prometheus, Grafana)
6. CI/CD pipeline integration
7. Auto-scaling based on demand
8. Data persistence and backup strategy

---

## 12. Deployment Timeline

- **Repository Setup:** 30 minutes
- **Docker Configuration:** 1 hour
- **SSL Certificate Setup:** 30 minutes
- **Testing & Optimization:** 1 hour
- **Total:** ~3 hours

---

## Contact & Support

For technical questions or issues:
- Review this documentation
- Check Docker logs: `docker-compose logs`
- Test deployment: https://aicompanionstudio.chandanjainhp.in

---

**Deployment Status:** ✅ LIVE AND OPERATIONAL

**Last Updated:** February 4, 2026
**Deployed By:** Chandan Jain H P
