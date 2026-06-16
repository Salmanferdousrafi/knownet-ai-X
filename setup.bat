@echo off
REM KnowNet X - Quick Start Setup Script for Windows

echo.
echo 🚀 KnowNet X - Quick Start Setup
echo ================================
echo.

REM Check prerequisites
echo Checking prerequisites...

where docker >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Docker is not installed. Please install Docker first.
    exit /b 1
)

where docker-compose >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Docker Compose is not installed. Please install Docker Compose first.
    exit /b 1
)

echo ✓ Docker and Docker Compose found
echo.

REM Setup environment
echo Setting up environment...

if not exist .env (
    copy .env.example .env
    echo ✓ Created .env file (update with your values)
) else (
    echo ✓ .env file already exists
)

REM Create necessary directories
if not exist backend\logs mkdir backend\logs
if not exist backend\uploads mkdir backend\uploads
if not exist uploads mkdir uploads
if not exist logs mkdir logs
echo ✓ Created necessary directories
echo.

REM Start services
echo Starting services with Docker Compose...
docker-compose up -d

REM Wait for services to be ready
echo Waiting for services to be ready...
timeout /t 10 /nobreak

REM Display URLs
echo.
echo ========================================
echo KnowNet X is ready!
echo ========================================
echo.
echo Access the application at:
echo   Frontend:     http://localhost:3000
echo   Backend API:  http://localhost:8000
echo   API Docs:     http://localhost:8000/docs
echo   Database:     localhost:5432
echo   Redis:        localhost:6379
echo.
echo View logs:
echo   Frontend:     docker-compose logs -f frontend
echo   Backend:      docker-compose logs -f backend
echo   Database:     docker-compose logs -f postgres
echo.
echo Stop services:
echo   docker-compose down
echo.
echo Next steps:
echo 1. Update .env with your configuration
echo 2. Review documentation in /docs
echo 3. Run tests: npm run test (frontend) and pytest (backend)
echo 4. Read CONTRIBUTING.md for development guidelines
echo.
pause
