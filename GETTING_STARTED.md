# KnowNet X - Quick Start Guide

## 🚀 Getting Started in 5 Minutes

### Prerequisites
- Docker & Docker Compose (recommended)
- OR Node.js 18+, Python 3.11+, PostgreSQL 15+, Redis 7+

### Option 1: Using Docker Compose (Recommended)

```bash
# Clone the repository
git clone https://github.com/yourusername/knownet-x.git
cd knownet-x

# Copy environment file
cp .env.example .env

# Run setup script
./setup.sh          # Linux/Mac
# or
setup.bat           # Windows

# Access the application
# Frontend:  http://localhost:3000
# Backend:   http://localhost:8000
# API Docs:  http://localhost:8000/docs
```

### Option 2: Local Development (Without Docker)

#### Frontend Setup
```bash
cd frontend
npm install
npm run dev
# Runs on http://localhost:3000
```

#### Backend Setup (in new terminal)
```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python -m uvicorn app.main:app --reload
# Runs on http://localhost:8000
```

## 📁 Project Structure

```
knownet-x/
├── frontend/                    # Next.js Application
│   ├── src/
│   │   ├── app/                # Pages and layouts
│   │   ├── components/         # React components
│   │   │   ├── landing/       # Landing page
│   │   │   ├── ui/            # UI components
│   │   │   └── dashboard/     # Dashboard
│   │   ├── hooks/             # Custom hooks
│   │   ├── services/          # API clients
│   │   ├── lib/               # Utilities
│   │   ├── types/             # TypeScript types
│   │   └── styles/            # Global styles
│   ├── package.json
│   ├── tsconfig.json
│   ├── tailwind.config.ts
│   └── next.config.ts
│
├── backend/                     # FastAPI Application
│   ├── app/
│   │   ├── main.py            # Entry point
│   │   ├── models/            # Database models
│   │   ├── routers/           # API routes
│   │   │   ├── auth.py
│   │   │   ├── knowledge.py
│   │   │   └── ...
│   │   ├── services/          # Business logic
│   │   ├── agents/            # AI agents
│   │   ├── security/          # Auth & security
│   │   └── core/              # Database, config
│   ├── requirements.txt
│   ├── config.py
│   └── Dockerfile
│
├── infrastructure/
│   ├── docker/                # Docker configs
│   ├── k8s/                   # Kubernetes
│   └── terraform/             # IaC templates
│
├── docs/                        # Documentation
│   ├── ARCHITECTURE.md
│   ├── API.md
│   ├── DATABASE.md
│   ├── DEPLOYMENT.md
│   └── CONTRIBUTING.md
│
├── .github/
│   └── workflows/             # CI/CD pipelines
│
├── docker-compose.yml         # Local development
├── .env.example               # Environment template
├── LICENSE
├── README.md
├── SECURITY.md
├── CODE_OF_CONDUCT.md
├── CHANGELOG.md
└── setup.sh / setup.bat       # Quick setup
```

## 🔑 Key Endpoints

### Frontend
- `/` - Landing page with hero, features, architecture
- `/platform` - Application dashboard (to be built)
- `/docs` - Documentation links

### Backend API (http://localhost:8000)
- `GET /` - Root status
- `GET /health` - Health check
- `GET /docs` - OpenAPI documentation
- `POST /api/v1/auth/login` - Login
- `POST /api/v1/auth/signup` - Sign up
- `POST /api/v1/knowledge/create` - Create knowledge
- `GET /api/v1/knowledge/search` - Search knowledge
- `GET /api/v1/graph/visualization` - Get knowledge graph
- See [API.md](docs/API.md) for complete API documentation

## 🎨 Design System

### Colors
- **Primary**: Emerald Green (`#00C853`)
- **Secondary**: Dark Emerald (`#003D29`)
- **Accent**: Gold (`#FFD700`)
- **Background**: Matte Black (`#0D1117`)

### Features
- Glassmorphism effects
- Arabic geometric patterns (CSS)
- Smooth animations (Framer Motion)
- Responsive design
- Dark theme with accent highlights

## 📚 Documentation

- [Architecture Overview](docs/ARCHITECTURE.md) - System design and components
- [API Documentation](docs/API.md) - All endpoints and usage
- [Database Schema](docs/DATABASE.md) - Complete database design
- [Deployment Guide](docs/DEPLOYMENT.md) - Cloud deployment options
- [Contributing Guide](docs/CONTRIBUTING.md) - How to contribute

## 🛠️ Development

### Frontend Development
```bash
cd frontend
npm run dev          # Start dev server
npm run lint         # Run ESLint
npm run format       # Format with Prettier
npm run type-check   # Check types
npm run test         # Run tests
npm run build        # Production build
```

### Backend Development
```bash
cd backend
python -m uvicorn app.main:app --reload  # Start dev server
black .              # Format code
flake8 .             # Lint
mypy .               # Type check
pytest               # Run tests
pytest --cov         # Run with coverage
```

### Docker Commands
```bash
docker-compose up          # Start all services
docker-compose up -d       # Start in background
docker-compose down        # Stop all services
docker-compose logs -f     # View logs
docker-compose ps          # View running containers
```

## 🧪 Testing

### Frontend Tests
```bash
cd frontend
npm run test                # Run Jest tests
npm run test:watch         # Watch mode
npm run test:coverage      # With coverage report
```

### Backend Tests
```bash
cd backend
pytest                     # Run all tests
pytest tests/             # Run specific directory
pytest --cov              # With coverage
pytest -v                 # Verbose output
```

## 🔐 Environment Configuration

Create `.env` and `.env.local` files:

```bash
# Copy template
cp .env.example .env

# Edit .env with your values
# Important: Never commit .env file!
```

See `.env.example` for all available options.

## 📦 Deployment

### Quick Deploy with Docker Compose
```bash
docker-compose -f docker-compose.yml up -d
```

### Cloud Deployment
See [DEPLOYMENT.md](docs/DEPLOYMENT.md) for:
- AWS (ECS, RDS, ElastiCache)
- Google Cloud (Cloud Run, Cloud SQL)
- Heroku
- Kubernetes

## 🐛 Troubleshooting

### Port Already in Use
```bash
# Find and kill process on port 3000 or 8000
lsof -i :3000      # Linux/Mac
netstat -ano | findstr :3000  # Windows
```

### Database Connection Failed
```bash
# Check PostgreSQL is running
docker-compose ps postgres

# View logs
docker-compose logs postgres

# Reset database
docker-compose down -v
docker-compose up
```

### Module Not Found
```bash
# Frontend
cd frontend && npm install

# Backend
cd backend && pip install -r requirements.txt
```

## 📞 Support

- 📧 Email: support@knownet.ai
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/knownet-x/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/yourusername/knownet-x/discussions)
- 📖 Docs: [Full Documentation](docs/)

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for:
- Development setup
- Code standards
- Testing requirements
- Pull request process
- License: MIT

## 📜 License

MIT License - See [LICENSE](LICENSE) for details

## 🎯 Next Steps

1. ✅ Run `docker-compose up` or `./setup.sh`
2. 📖 Read the [Architecture Guide](docs/ARCHITECTURE.md)
3. 🔌 Explore the [API Documentation](docs/API.md)
4. 💡 Check out the [Contributing Guide](docs/CONTRIBUTING.md)
5. 🚀 Start building!

---

**KnowNet X** - Transform Information Into Intelligence ✨
