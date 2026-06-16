#!/bin/bash

################################################################################
# KnowNet X - Production Deployment Setup Script (All-in-One)
# Automated setup and deployment for production environments
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# CONFIGURATION
# ============================================================================

PROJECT_NAME="KnowNet X"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVIRONMENT="${1:-production}"
DOCKER_REGISTRY="${DOCKER_REGISTRY:-docker.io}"
DEPLOY_TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "$1 is not installed"
        return 1
    fi
    log_success "$1 is installed"
}

# ============================================================================
# PRE-DEPLOYMENT CHECKS
# ============================================================================

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  $PROJECT_NAME - Production Setup${NC}"
echo -e "${BLUE}  Environment: $ENVIRONMENT${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

log_info "Checking prerequisites..."

check_command "docker" || exit 1
check_command "docker-compose" || exit 1
check_command "git" || exit 1

log_success "All prerequisites installed\n"

# ============================================================================
# ENVIRONMENT CONFIGURATION
# ============================================================================

log_info "Setting up environment configuration..."

if [ ! -f "$PROJECT_DIR/.env" ]; then
    log_warning ".env file not found, creating from template..."
    cat > "$PROJECT_DIR/.env" << 'EOF'
# Database Configuration
DB_NAME=knownet_db
DB_USER=knownet_user
DB_PASSWORD=change_me_in_production_$(openssl rand -base64 32)
DB_HOST=postgres
DB_PORT=5432

# Redis Configuration
REDIS_PASSWORD=change_me_in_production_$(openssl rand -base64 32)
REDIS_HOST=redis
REDIS_PORT=6379

# JWT Configuration
JWT_SECRET=your_jwt_secret_key_change_in_production
JWT_ALGORITHM=HS256
JWT_EXPIRATION_HOURS=24

# OpenAI Configuration
OPENAI_API_KEY=sk-your-api-key-here
OPENAI_MODEL=gpt-4

# Application Configuration
ENVIRONMENT=production
DEBUG=false
LOG_LEVEL=INFO

# CORS Configuration
CORS_ORIGINS=http://localhost:3000,http://localhost:8000,https://knownet.ai
CORS_CREDENTIALS=true

# Security
SECURE_COOKIES=true
HTTPS_ONLY=true
CSP_ENABLED=true

# Email Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_FROM=noreply@knownet.ai

# AWS Configuration (Optional)
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
S3_BUCKET=knownet-assets

# Monitoring & Logging
SENTRY_DSN=
DATADOG_API_KEY=
LOG_TO_FILE=true
LOG_FILE_PATH=/var/log/knownet/app.log

# Feature Flags
ENABLE_OAUTH=true
ENABLE_ANALYTICS=true
ENABLE_AI_AGENTS=true
ENABLE_KNOWLEDGE_GRAPH=true
EOF
    log_success ".env file created"
else
    log_success ".env file found"
fi

# ============================================================================
# BUILD CONFIGURATION
# ============================================================================

log_info "Configuring build system..."

# Create docker-compose override for production
cat > "$PROJECT_DIR/docker-compose.override.yml" << EOF
version: '3.9'

services:
  backend:
    environment:
      DEBUG: false
      LOG_LEVEL: INFO

  frontend:
    environment:
      NODE_ENV: production

  nginx:
    ports:
      - "80:80"
      - "443:443"
EOF

log_success "Docker Compose configured\n"

# ============================================================================
# DATABASE INITIALIZATION
# ============================================================================

log_info "Preparing database initialization script..."

mkdir -p "$PROJECT_DIR/scripts"

cat > "$PROJECT_DIR/scripts/init.sql" << 'EOF'
-- KnowNet X Database Initialization

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    avatar_url TEXT,
    bio TEXT,
    mfa_enabled BOOLEAN DEFAULT false,
    mfa_secret VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    is_admin BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Projects table
CREATE TABLE IF NOT EXISTS projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    color VARCHAR(7) DEFAULT '#00C853',
    is_public BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Knowledge table
CREATE TABLE IF NOT EXISTS knowledge (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    creator_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    tags TEXT[] DEFAULT '{}',
    embeddings VECTOR(1536),
    is_public BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_projects_owner_id ON projects(owner_id);
CREATE INDEX idx_knowledge_project_id ON knowledge(project_id);
CREATE INDEX idx_knowledge_creator_id ON knowledge(creator_id);
CREATE INDEX idx_knowledge_tags ON knowledge USING gin(tags);

-- Security logs table
CREATE TABLE IF NOT EXISTS security_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    details JSONB,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Audit logs table
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID,
    action VARCHAR(50) NOT NULL,
    changes JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_security_logs_user ON security_logs(user_id);
EOF

log_success "Database initialization script created\n"

# ============================================================================
# SSL CERTIFICATE SETUP
# ============================================================================

log_info "Setting up SSL certificates..."

mkdir -p "$PROJECT_DIR/nginx/ssl"

if [ ! -f "$PROJECT_DIR/nginx/ssl/certificate.crt" ]; then
    log_warning "SSL certificates not found"
    log_info "Generating self-signed certificates for development..."
    
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$PROJECT_DIR/nginx/ssl/private.key" \
        -out "$PROJECT_DIR/nginx/ssl/certificate.crt" \
        -subj "/C=US/ST=State/L=City/O=KnowNet/CN=knownet.local"
    
    log_success "Self-signed certificates generated"
else
    log_success "SSL certificates found"
fi

log_info "For production, replace with real certificates from Let's Encrypt or CA provider\n"

# ============================================================================
# NGINX CONFIGURATION
# ============================================================================

log_info "Setting up Nginx reverse proxy..."

mkdir -p "$PROJECT_DIR/nginx"

cat > "$PROJECT_DIR/nginx/nginx.conf" << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 50M;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript 
               application/json application/javascript application/xml+rss;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=general:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=api:10m rate=100r/s;

    # Backend upstream
    upstream backend {
        server backend:8000;
    }

    # Frontend upstream
    upstream frontend {
        server frontend:3000;
    }

    # HTTP redirect to HTTPS
    server {
        listen 80;
        server_name _;
        return 301 https://$host$request_uri;
    }

    # HTTPS server
    server {
        listen 443 ssl http2;
        server_name knownet.local;

        ssl_certificate /etc/nginx/ssl/certificate.crt;
        ssl_certificate_key /etc/nginx/ssl/private.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;

        # Security headers
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;

        # API endpoints - backend
        location /api/ {
            limit_req zone=api burst=200 nodelay;
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Frontend
        location / {
            limit_req zone=general burst=50 nodelay;
            proxy_pass http://frontend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF

log_success "Nginx configuration created\n"

# ============================================================================
# BUILD AND DEPLOYMENT
# ============================================================================

log_info "Building Docker images..."

docker-compose -f "$PROJECT_DIR/docker-compose.production.yml" build

log_success "Docker images built\n"

# ============================================================================
# START SERVICES
# ============================================================================

log_info "Starting services..."

docker-compose -f "$PROJECT_DIR/docker-compose.production.yml" up -d

log_success "Services started\n"

# ============================================================================
# HEALTH CHECKS
# ============================================================================

log_info "Performing health checks...\n"

sleep 10

# Check PostgreSQL
if docker-compose -f "$PROJECT_DIR/docker-compose.production.yml" exec -T postgres pg_isready -U knownet_user > /dev/null 2>&1; then
    log_success "PostgreSQL: OK"
else
    log_error "PostgreSQL: FAILED"
fi

# Check Redis
if docker-compose -f "$PROJECT_DIR/docker-compose.production.yml" exec -T redis redis-cli ping > /dev/null 2>&1; then
    log_success "Redis: OK"
else
    log_error "Redis: FAILED"
fi

# Check Backend
if curl -f http://localhost:8001/health > /dev/null 2>&1; then
    log_success "Backend: OK"
else
    log_error "Backend: FAILED"
fi

# Check Frontend
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    log_success "Frontend: OK"
else
    log_error "Frontend: FAILED"
fi

echo ""

# ============================================================================
# DEPLOYMENT SUMMARY
# ============================================================================

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Deployment Complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "📍 Service URLs:"
echo -e "  Frontend:  ${YELLOW}http://localhost:3000${NC}"
echo -e "  Backend:   ${YELLOW}http://localhost:8001${NC}"
echo -e "  API Docs:  ${YELLOW}http://localhost:8001/docs${NC}"
echo -e "  Nginx:     ${YELLOW}https://localhost${NC}\n"

echo -e "📊 Database:"
echo -e "  Host:     ${YELLOW}localhost:5432${NC}"
echo -e "  Database: ${YELLOW}knownet_db${NC}"
echo -e "  User:     ${YELLOW}knownet_user${NC}\n"

echo -e "🔒 Important:"
echo -e "  • Change .env passwords in production"
echo -e "  • Replace SSL certificates with valid ones"
echo -e "  • Set OPENAI_API_KEY if using AI features"
echo -e "  • Configure email SMTP settings"
echo -e "  • Review security settings before production\n"

echo -e "📚 Documentation:"
echo -e "  • Setup: ${YELLOW}GETTING_STARTED.md${NC}"
echo -e "  • API:   ${YELLOW}API.md${NC}"
echo -e "  • Arch:  ${YELLOW}ARCHITECTURE.md${NC}\n"

echo -e "🚀 Useful Commands:"
echo -e "  View logs:      ${YELLOW}docker-compose logs -f${NC}"
echo -e "  Stop services:  ${YELLOW}docker-compose down${NC}"
echo -e "  Restart:        ${YELLOW}docker-compose restart${NC}"
echo -e "  Shell:          ${YELLOW}docker-compose exec backend bash${NC}\n"

log_success "Setup complete!"
