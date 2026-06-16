# KnowNet X - Complete Deployment & Installation Guide

## ============================================================================
## QUICK START (5 Minutes)
## ============================================================================

### Option 1: Docker Compose (Recommended)

```bash
# Clone/navigate to project
cd KnowNet-X

# Start all services
docker-compose -f docker-compose.production.yml up -d

# Access services
# Frontend:  http://localhost:3000
# Backend:   http://localhost:8001
# API Docs:  http://localhost:8001/docs
```

### Option 2: Automated Deployment

#### Windows (PowerShell):
```powershell
# Navigate to project
cd KnowNet-X

# Run deployment script (requires admin)
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\deploy.ps1 -Environment production
```

#### Linux/Mac (Bash):
```bash
# Navigate to project
cd KnowNet-X

# Run deployment script
chmod +x deploy.sh
./deploy.sh production
```

---

## ============================================================================
## COMPLETE SETUP (For Development)
## ============================================================================

### Prerequisites

- **Docker & Docker Compose** (Latest)
- **Python 3.11+** (if running locally)
- **Node.js 18+** (if running frontend locally)
- **PostgreSQL 16** (if using native instead of Docker)
- **Redis 7** (if using native instead of Docker)
- **Git**

### Step 1: Clone Repository

```bash
git clone https://github.com/yourusername/knownet-x.git
cd knownet-x
```

### Step 2: Environment Configuration

```bash
# Copy environment template
cp .env.example .env

# Edit .env with your settings
# Important variables:
# - OPENAI_API_KEY (for AI features)
# - JWT_SECRET (change from default)
# - Database credentials
# - Email/SMTP settings
```

### Step 3: Build All-in-One Files

The project includes three consolidated files for easy deployment:

```
1. backend_complete.py  → Complete backend (600+ lines, production-ready)
2. frontend_complete.tsx → Complete dashboard UI (500+ lines)
3. agents_complete.py   → AI agents system (LangGraph orchestration)
```

#### Using Backend Complete

```python
# 1. Install dependencies
pip install -r requirements.txt

# 2. Configure environment
export DATABASE_URL="postgresql://user:password@localhost:5432/knownet_db"
export JWT_SECRET="your-secret-key"
export OPENAI_API_KEY="sk-..."

# 3. Run backend
python backend_complete.py

# Server starts on http://localhost:8000
```

#### Using Frontend Complete

```bash
# 1. Add to Next.js project
cp frontend_complete.tsx your-nextjs-project/app/dashboard.tsx

# 2. Install dependencies
npm install framer-motion lucide-react

# 3. Run frontend
npm run dev

# Access on http://localhost:3000
```

#### Using Agents Complete

```python
# 1. Install dependencies
pip install langgraph langchain openai requests

# 2. Set API key
export OPENAI_API_KEY="sk-..."

# 3. Use agents
from agents_complete import AgentOrchestrator

orchestrator = AgentOrchestrator()
result = orchestrator.process_query("Research machine learning trends")
```

### Step 4: Start Database Services

```bash
# Using Docker Compose
docker-compose up -d postgres redis chroma

# Or manually
# PostgreSQL: psql -U knownet_user -d knownet_db
# Redis: redis-cli
```

### Step 5: Database Initialization

```bash
# Run database setup script
docker-compose exec postgres psql -U knownet_user knownet_db < scripts/init.sql

# Or using Python (auto-migration)
python -c "from backend_complete import init_db; init_db()"
```

### Step 6: Start Services

```bash
# All services (full stack)
docker-compose -f docker-compose.production.yml up -d

# Or individually
docker-compose up -d backend frontend
```

---

## ============================================================================
## PRODUCTION DEPLOYMENT
## ============================================================================

### AWS Deployment (ECS + RDS)

```bash
# 1. Push images to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account>.dkr.ecr.us-east-1.amazonaws.com

docker tag knownet-backend:latest <account>.dkr.ecr.us-east-1.amazonaws.com/knownet-backend:latest
docker push <account>.dkr.ecr.us-east-1.amazonaws.com/knownet-backend:latest

# 2. Create ECS task definition
aws ecs register-task-definition --cli-input-json file://task-definition.json

# 3. Create ECS service
aws ecs create-service --cluster knownet-cluster --service-name knownet-service --task-definition knownet-task:1 --desired-count 2

# 4. Configure RDS
# Database: PostgreSQL 16
# Instance: db.t3.medium or larger
# Storage: 100GB+ with auto-scaling
```

### GCP Deployment (Cloud Run + Cloud SQL)

```bash
# 1. Build images
gcloud builds submit --tag gcr.io/<project>/knownet-backend

# 2. Deploy to Cloud Run
gcloud run deploy knownet-backend \
  --image gcr.io/<project>/knownet-backend \
  --platform managed \
  --region us-central1 \
  --set-env-vars DATABASE_URL=<cloud-sql-proxy>

# 3. Set up Cloud SQL (PostgreSQL 16)
# Instance: db-n1-standard-1 or larger
```

### Heroku Deployment

```bash
# 1. Create app
heroku create knownet-x

# 2. Add PostgreSQL addon
heroku addons:create heroku-postgresql:standard-0 --app knownet-x

# 3. Set environment variables
heroku config:set JWT_SECRET=your-secret --app knownet-x
heroku config:set OPENAI_API_KEY=sk-... --app knownet-x

# 4. Deploy
git push heroku main

# 5. Run migrations
heroku run python -c "from backend_complete import init_db; init_db()" --app knownet-x
```

---

## ============================================================================
## MONITORING & LOGGING
## ============================================================================

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend

# With timestamps
docker-compose logs -f --timestamps

# Last 100 lines
docker-compose logs --tail=100
```

### Health Checks

```bash
# Backend health
curl http://localhost:8001/health

# Frontend
curl http://localhost:3000

# Database
docker-compose exec postgres pg_isready -U knownet_user

# Redis
docker-compose exec redis redis-cli ping
```

### Performance Monitoring

```bash
# CPU/Memory usage
docker stats

# Database performance
docker-compose exec postgres psql -U knownet_user knownet_db \
  -c "SELECT * FROM pg_stat_statements LIMIT 10;"

# Redis memory
docker-compose exec redis redis-cli INFO memory
```

---

## ============================================================================
## SCALING & LOAD BALANCING
## ============================================================================

### Horizontal Scaling

```yaml
# docker-compose.production.yml - replicate services
services:
  backend:
    deploy:
      replicas: 3

  frontend:
    deploy:
      replicas: 2
```

### Load Balancing (Nginx)

```nginx
upstream backend {
    server backend1:8000;
    server backend2:8000;
    server backend3:8000;
}

server {
    location /api/ {
        proxy_pass http://backend;
        proxy_set_header Host $host;
    }
}
```

### Database Connection Pooling

```python
# In backend_complete.py
engine = create_engine(
    DATABASE_URL,
    poolclass=QueuePool,
    pool_size=20,
    max_overflow=40
)
```

---

## ============================================================================
## SECURITY HARDENING
## ============================================================================

### SSL/TLS Certificates

```bash
# Generate self-signed (development)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/private.key \
  -out nginx/ssl/certificate.crt

# Let's Encrypt (production)
certbot certonly --standalone -d knownet.ai

# Copy to nginx/ssl/
cp /etc/letsencrypt/live/knownet.ai/* nginx/ssl/
```

### Environment Variables

```bash
# NEVER commit .env file
echo ".env" >> .gitignore

# Use secrets manager in production
# AWS Secrets Manager
# GCP Secret Manager
# HashiCorp Vault
# Azure Key Vault
```

### Database Security

```bash
# Change default credentials
# Update DB_USER and DB_PASSWORD in .env

# Create limited-privilege users
psql -U postgres -c "
  CREATE USER read_only WITH PASSWORD 'secure_password';
  GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;
"

# Enable SSL connections
# postgresql.conf: ssl = on
```

### API Security

```python
# Rate limiting (in backend_complete.py)
from slowapi import Limiter

limiter = Limiter(key_func=get_remote_address)

@app.post("/api/v1/auth/login")
@limiter.limit("5/minute")
async def login(credentials: UserLogin):
    ...
```

---

## ============================================================================
## BACKUP & RECOVERY
## ============================================================================

### Database Backup

```bash
# Daily backup
docker-compose exec postgres pg_dump -U knownet_user knownet_db \
  > backups/knownet_db_$(date +%Y%m%d).sql

# Compress
gzip backups/knownet_db_*.sql

# Upload to S3
aws s3 cp backups/ s3://knownet-backups/ --recursive
```

### Database Restore

```bash
# From backup
docker-compose exec -T postgres psql -U knownet_user knownet_db \
  < backups/knownet_db_20240101.sql

# From S3
aws s3 cp s3://knownet-backups/knownet_db_20240101.sql.gz .
gunzip knownet_db_20240101.sql.gz
docker-compose exec -T postgres psql -U knownet_user knownet_db \
  < knownet_db_20240101.sql
```

### Redis Persistence

```bash
# redis.conf
appendonly yes
appendfsync everysec

# Backup
docker-compose exec redis redis-cli BGSAVE
docker cp knownet-redis:/data/dump.rdb backups/
```

---

## ============================================================================
## TROUBLESHOOTING
## ============================================================================

### Service Won't Start

```bash
# Check logs
docker-compose logs backend

# Check port conflicts
netstat -an | grep 8001
lsof -i :8001

# Free port
fuser -k 8001/tcp
```

### Database Connection Issues

```bash
# Test connection
docker-compose exec backend python -c "
from sqlalchemy import create_engine
engine = create_engine(os.getenv('DATABASE_URL'))
engine.connect()
print('Connected!')
"
```

### Frontend Not Connecting to Backend

```bash
# Check CORS settings in .env
# CORS_ORIGINS should include frontend URL

# Check backend is running
curl http://localhost:8001/health

# Check network connectivity
docker-compose exec frontend curl http://backend:8000/health
```

### Out of Memory

```bash
# Check Docker memory limits
docker stats

# Increase in docker-compose.yml
services:
  backend:
    mem_limit: 2g
    memswap_limit: 2g
```

---

## ============================================================================
## USEFUL COMMANDS
## ============================================================================

```bash
# Container management
docker-compose up -d              # Start services
docker-compose down               # Stop services
docker-compose restart backend    # Restart service
docker-compose logs -f            # View logs
docker-compose exec backend bash  # SSH into container

# Database
docker-compose exec postgres psql -U knownet_user knownet_db
docker-compose exec redis redis-cli

# Image management
docker images                # List images
docker system prune         # Clean up unused
docker rmi -f image_name    # Remove image

# Network
docker network ls          # List networks
docker network inspect knownet-network

# Debugging
docker-compose config      # Show merged config
docker inspect container   # Get container details
```

---

## ============================================================================
## ADDITIONAL RESOURCES
## ============================================================================

- **API Documentation**: http://localhost:8001/docs (Swagger)
- **Architecture**: See ARCHITECTURE.md
- **Security**: See SECURITY.md
- **Contribution Guide**: See CONTRIBUTING.md
- **Support**: GitHub Issues

---

## ============================================================================
## NEXT STEPS
## ============================================================================

1. ✅ Deploy using this guide
2. 🔐 Configure security settings
3. 📊 Set up monitoring (Sentry, DataDog)
4. 📧 Configure email/SMTP
5. 🤖 Enable AI agents (set OPENAI_API_KEY)
6. 📈 Set up analytics tracking
7. 🚀 Configure CI/CD pipeline
8. 📱 Enable webhooks
9. 🔄 Set up backup automation
10. 📞 Configure support channels

---

**Last Updated**: 2024-01-16
**Version**: 1.0.0
**Status**: Production Ready
