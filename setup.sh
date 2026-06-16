#!/bin/bash
# KnowNet X - Quick Start Setup Script

set -e

echo "🚀 KnowNet X - Quick Start Setup"
echo "================================"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo -e "${GREEN}✓ Docker and Docker Compose found${NC}"

# Setup environment
echo -e "${YELLOW}Setting up environment...${NC}"

if [ ! -f .env ]; then
    cp .env.example .env
    echo -e "${GREEN}✓ Created .env file (update with your values)${NC}"
else
    echo -e "${GREEN}✓ .env file already exists${NC}"
fi

# Create necessary directories
mkdir -p ./backend/logs ./backend/uploads ./uploads ./logs
echo -e "${GREEN}✓ Created necessary directories${NC}"

# Start services
echo -e "${YELLOW}Starting services with Docker Compose...${NC}"
docker-compose up -d

# Wait for services to be ready
echo -e "${YELLOW}Waiting for services to be ready...${NC}"
sleep 10

# Check if services are running
if docker-compose ps | grep -q "knownet-postgres"; then
    echo -e "${GREEN}✓ PostgreSQL is running${NC}"
else
    echo -e "❌ PostgreSQL failed to start"
    docker-compose logs postgres
    exit 1
fi

if docker-compose ps | grep -q "knownet-redis"; then
    echo -e "${GREEN}✓ Redis is running${NC}"
else
    echo "❌ Redis failed to start"
    docker-compose logs redis
    exit 1
fi

# Display URLs
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}KnowNet X is ready!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Access the application at:"
echo -e "  Frontend:     ${GREEN}http://localhost:3000${NC}"
echo -e "  Backend API:  ${GREEN}http://localhost:8000${NC}"
echo -e "  API Docs:     ${GREEN}http://localhost:8000/docs${NC}"
echo -e "  Database:     ${GREEN}localhost:5432${NC}"
echo -e "  Redis:        ${GREEN}localhost:6379${NC}"
echo ""
echo "View logs:"
echo "  Frontend:     docker-compose logs -f frontend"
echo "  Backend:      docker-compose logs -f backend"
echo "  Database:     docker-compose logs -f postgres"
echo ""
echo "Stop services:"
echo "  docker-compose down"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Update .env with your configuration"
echo "2. Review documentation in /docs"
echo "3. Run tests: npm run test (frontend) and pytest (backend)"
echo "4. Read CONTRIBUTING.md for development guidelines"
echo ""
