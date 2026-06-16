# KnowNet X - Production Deployment Setup Script (Windows PowerShell)
# Automated setup and deployment for production environments

param(
    [string]$Environment = "production",
    [string]$Action = "deploy"
)

# ============================================================================
# CONFIGURATION
# ============================================================================

$PROJECT_NAME = "KnowNet X"
$PROJECT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ENVIRONMENT = $Environment
$DEPLOY_TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"

# Colors
$Colors = @{
    "Red" = 12
    "Green" = 10
    "Yellow" = 14
    "Blue" = 9
    "Default" = 15
}

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Level = "Info"
    )
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    
    switch ($Level) {
        "Info" {
            Write-Host "[$timestamp] [INFO]   " -ForegroundColor Cyan -NoNewline
            Write-Host $Message
        }
        "Success" {
            Write-Host "[$timestamp] [✓]     " -ForegroundColor Green -NoNewline
            Write-Host $Message
        }
        "Warning" {
            Write-Host "[$timestamp] [!]     " -ForegroundColor Yellow -NoNewline
            Write-Host $Message
        }
        "Error" {
            Write-Host "[$timestamp] [✗]     " -ForegroundColor Red -NoNewline
            Write-Host $Message
        }
    }
}

# ============================================================================
# PRE-DEPLOYMENT CHECKS
# ============================================================================

Write-Host "`n" + ("="*60) -ForegroundColor Blue
Write-Host "$PROJECT_NAME - Production Setup (Windows)" -ForegroundColor Blue
Write-Host "Environment: $ENVIRONMENT" -ForegroundColor Blue
Write-Host ("="*60) + "`n" -ForegroundColor Blue

Write-Log "Checking prerequisites..." "Info"

$prerequisites = @("docker", "git")

foreach ($cmd in $prerequisites) {
    try {
        $null = & $cmd --version
        Write-Log "$cmd is installed" "Success"
    }
    catch {
        Write-Log "$cmd is not installed" "Error"
        exit 1
    }
}

# ============================================================================
# ENVIRONMENT CONFIGURATION
# ============================================================================

Write-Log "Setting up environment configuration..." "Info"

$envPath = Join-Path $PROJECT_DIR ".env"

if (-not (Test-Path $envPath)) {
    Write-Log ".env file not found, creating from template..." "Warning"
    
    $envContent = @"
# Database Configuration
DB_NAME=knownet_db
DB_USER=knownet_user
DB_PASSWORD=secure_password_change_in_production
DB_HOST=postgres
DB_PORT=5432

# Redis Configuration
REDIS_PASSWORD=redis_secure_password_change_in_production
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

# Feature Flags
ENABLE_OAUTH=true
ENABLE_ANALYTICS=true
ENABLE_AI_AGENTS=true
ENABLE_KNOWLEDGE_GRAPH=true
"@
    
    Set-Content -Path $envPath -Value $envContent
    Write-Log ".env file created" "Success"
}
else {
    Write-Log ".env file found" "Success"
}

# ============================================================================
# DIRECTORY STRUCTURE
# ============================================================================

Write-Log "Creating directory structure..." "Info"

$directories = @(
    "scripts",
    "nginx/ssl",
    "logs",
    "data/postgres",
    "data/redis",
    "data/chroma"
)

foreach ($dir in $directories) {
    $fullPath = Join-Path $PROJECT_DIR $dir
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Log "Created directory: $dir" "Success"
    }
}

# ============================================================================
# DATABASE INITIALIZATION
# ============================================================================

Write-Log "Preparing database initialization script..." "Info"

$initSqlPath = Join-Path $PROJECT_DIR "scripts\init.sql"

$initSqlContent = @"
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
    mfa_enabled BOOLEAN DEFAULT false,
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
    is_public BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_projects_owner_id ON projects(owner_id);
CREATE INDEX IF NOT EXISTS idx_knowledge_project_id ON knowledge(project_id);
CREATE INDEX IF NOT EXISTS idx_knowledge_creator_id ON knowledge(creator_id);
"@

Set-Content -Path $initSqlPath -Value $initSqlContent
Write-Log "Database initialization script created" "Success"

# ============================================================================
# BUILD DOCKER IMAGES
# ============================================================================

Write-Log "Building Docker images..." "Info"

& docker-compose -f "$PROJECT_DIR\docker-compose.production.yml" build

if ($LASTEXITCODE -eq 0) {
    Write-Log "Docker images built successfully" "Success"
}
else {
    Write-Log "Failed to build Docker images" "Error"
    exit 1
}

# ============================================================================
# START SERVICES
# ============================================================================

Write-Log "Starting services..." "Info"

& docker-compose -f "$PROJECT_DIR\docker-compose.production.yml" up -d

if ($LASTEXITCODE -eq 0) {
    Write-Log "Services started" "Success"
}
else {
    Write-Log "Failed to start services" "Error"
    exit 1
}

# ============================================================================
# HEALTH CHECKS
# ============================================================================

Write-Log "Waiting for services to be ready..." "Info"
Start-Sleep -Seconds 10

Write-Log "Performing health checks..." "Info"
Write-Host ""

# Check Backend
$backendUrl = "http://localhost:8001/health"
try {
    $response = Invoke-WebRequest -Uri $backendUrl -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        Write-Log "Backend: OK" "Success"
    }
    else {
        Write-Log "Backend: FAILED (Status $($response.StatusCode))" "Error"
    }
}
catch {
    Write-Log "Backend: FAILED" "Error"
}

# Check Frontend
$frontendUrl = "http://localhost:3000"
try {
    $response = Invoke-WebRequest -Uri $frontendUrl -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        Write-Log "Frontend: OK" "Success"
    }
    else {
        Write-Log "Frontend: FAILED" "Error"
    }
}
catch {
    Write-Log "Frontend: FAILED" "Error"
}

# ============================================================================
# DEPLOYMENT SUMMARY
# ============================================================================

Write-Host ""
Write-Host ("="*60) -ForegroundColor Blue
Write-Host "✓ Deployment Complete!" -ForegroundColor Green
Write-Host ("="*60) -ForegroundColor Blue
Write-Host ""

Write-Host "📍 Service URLs:" -ForegroundColor Cyan
Write-Host "  Frontend:  http://localhost:3000" -ForegroundColor Yellow
Write-Host "  Backend:   http://localhost:8001" -ForegroundColor Yellow
Write-Host "  API Docs:  http://localhost:8001/docs" -ForegroundColor Yellow
Write-Host ""

Write-Host "📊 Database:" -ForegroundColor Cyan
Write-Host "  Host:     localhost:5432" -ForegroundColor Yellow
Write-Host "  Database: knownet_db" -ForegroundColor Yellow
Write-Host "  User:     knownet_user" -ForegroundColor Yellow
Write-Host ""

Write-Host "🔒 Important:" -ForegroundColor Cyan
Write-Host "  • Change .env passwords in production" -ForegroundColor Yellow
Write-Host "  • Set OPENAI_API_KEY if using AI features" -ForegroundColor Yellow
Write-Host "  • Configure email SMTP settings" -ForegroundColor Yellow
Write-Host "  • Review security settings before production" -ForegroundColor Yellow
Write-Host ""

Write-Host "🚀 Useful Commands:" -ForegroundColor Cyan
Write-Host "  View logs:      docker-compose logs -f" -ForegroundColor Yellow
Write-Host "  Stop services:  docker-compose down" -ForegroundColor Yellow
Write-Host "  Restart:        docker-compose restart" -ForegroundColor Yellow
Write-Host ""

Write-Log "Setup complete!" "Success"
Write-Host ""
