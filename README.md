# KnowNet X

**The world's most beautiful AI knowledge operating system.**

![Status](https://img.shields.io/badge/status-in%20development-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue)
![Next.js](https://img.shields.io/badge/Next.js-15-black)
![FastAPI](https://img.shields.io/badge/FastAPI-0.104-009688)

## Overview

KnowNet X is an enterprise-grade **AI-Powered Knowledge Intelligence Platform** that combines the best of Notion, Perplexity, Obsidian, GraphRAG, and enterprise security into a single, beautiful system.

## Vision

Transform information into intelligence through:
-  **AI Research Engine** - Deep research with source validation
-  **Knowledge Graph** - Visual relationship mapping
-  **Memory System** - Long-term semantic memory
-  **Cybersecurity Hub** - Threat monitoring and vault
-  **Team Collaboration** - Real-time workspace
-  **Analytics Engine** - Beautiful dashboards
-  **Multi-Agent Architecture** - Research, Memory, Learning, Security agents
-  **Enterprise Security** - RBAC, MFA, Encryption, Audit logs

## Features

###  Core Features
- **AI Search Engine** - Semantic search powered by LangGraph
- **Knowledge Graph** - Connected notes with relationship visualization
- **Document Intelligence** - AI-powered document analysis
- **Semantic Memory** - Long-term knowledge retention
- **Research Assistant** - Multi-source research aggregation
- **Learning Hub** - Personalized learning paths
- **Team Workspace** - Collaborative knowledge building
- **Analytics Dashboard** - Usage insights and trends

### 🔒 Security
- OAuth 2.0 & WebAuthn authentication
- Multi-factor authentication (MFA)
- Role-based access control (RBAC)
- AES-256 encryption for sensitive data
- JWT token management
- Audit logging and compliance tracking
- API rate limiting and gateway protection
- Real-time threat detection

###  Architecture

#### Frontend Stack
```
├─ Next.js 15
├─ React 19
├─ TypeScript 5
├─ TailwindCSS
├─ Framer Motion
└─ shadcn/ui
```

#### Backend Stack
```
├─ FastAPI
├─ Python 3.11+
├─ PostgreSQL
├─ Redis
├─ Celery
└─ SQLAlchemy ORM
```

#### AI & ML Stack
```
├─ LangGraph
├─ OpenAI API
├─ Ollama (local models)
├─ Chroma/Pinecone (Vector DB)
└─ NLTK/Spacy (NLP)
```

#### Deployment
```
├─ Docker & Docker Compose
├─ Kubernetes ready
├─ GitHub Actions (CI/CD)
├─ PostgreSQL 16
└─ Redis 7
```

## Design Aesthetic

### Theme: Ancient Arabic × Modern Cyber

**Color Palette:**
-  Emerald Green: `#00C853` (Primary)
-  Dark Emerald: `#003D29` (Secondary)
-  Gold Accent: `#FFD700` (Highlights)
-  Matte Black: `#0D1117` (Background)

**Design Elements:**
- Glassmorphism with soft effects
- Arabic geometric patterns
- Arabic calligraphy animations
- Smooth transitions (inspired by Linear.app)
- Apple-level attention to detail

## Quick Start

### Prerequisites
- Node.js 18+
- Python 3.11+
- PostgreSQL 15+
- Redis 7+
- Docker & Docker Compose (optional)

### Development Setup

#### Option 1: Local Development
```bash
# Clone the repository
git clone https://github.com/yourusername/knownet-x.git
cd knownet-x

# Frontend setup
cd frontend
npm install
npm run dev

# Backend setup (in new terminal)
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python -m uvicorn app.main:app --reload
```

#### Option 2: Docker Compose
```bash
docker-compose up --build
```

### Access the Application
- **Frontend:** http://localhost:3000
- **Backend API:** http://localhost:8000
- **API Docs:** http://localhost:8000/docs

## Environment Variables

Create `.env.local` in the frontend and `.env` in the backend:

```bash
# Frontend (.env.local)
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_OPENAI_API_KEY=your_key_here

# Backend (.env)
DATABASE_URL=postgresql://user:password@localhost:5432/knownet
REDIS_URL=redis://localhost:6379
OPENAI_API_KEY=your_key_here
JWT_SECRET=your_secret_key
```

See `.env.example` for complete configuration.

## Project Structure

```
knownet-x/
├── frontend/                 # Next.js application
│   ├── src/
│   │   ├── app/            # App router pages
│   │   ├── components/     # React components
│   │   ├── lib/            # Utilities & hooks
│   │   └── styles/         # Global styles
│   ├── public/             # Static assets
│   ├── package.json
│   ├── tsconfig.json
│   ├── tailwind.config.ts
│   └── next.config.ts
│
├── backend/                 # FastAPI application
│   ├── app/
│   │   ├── models/         # SQLAlchemy models
│   │   ├── services/       # Business logic
│   │   ├── routers/        # API endpoints
│   │   ├── agents/         # AI agents (LangGraph)
│   │   ├── security/       # Auth & security
│   │   └── core/           # Config & utilities
│   ├── migrations/         # Alembic migrations
│   ├── requirements.txt
│   ├── main.py
│   └── config.py
│
├── infrastructure/
│   ├── docker/             # Docker files
│   ├── k8s/                # Kubernetes configs
│   └── terraform/          # IaC templates
│
├── docs/                   # Documentation
│   ├── ARCHITECTURE.md
│   ├── API.md
│   ├── DEPLOYMENT.md
│   └── CONTRIBUTING.md
│
├── docker-compose.yml      # Local development
├── .env.example            # Environment template
├── .gitignore
└── README.md
```

## Database Schema

**Core Tables:**
- `users` - User accounts & profiles
- `projects` - Knowledge projects/workspaces
- `knowledge` - Knowledge entries
- `documents` - Uploaded documents
- `research` - Research queries & results
- `notes` - User notes & annotations
- `graphs` - Knowledge graph metadata
- `agents` - AI agent configurations
- `security_logs` - Security audit logs
- `audit_logs` - System audit logs
- `analytics` - Usage analytics

See [ARCHITECTURE.md](docs/ARCHITECTURE.md) for complete schema.

## API Documentation

Interactive API documentation available at: `http://localhost:8000/docs`

**Key Endpoints:**
- `POST /api/auth/login` - User authentication
- `POST /api/knowledge/create` - Create knowledge entry
- `GET /api/graph/visualization` - Get knowledge graph
- `POST /api/research/query` - Initiate research
- `GET /api/memory/search` - Search memory system
- `POST /api/agents/research` - Run research agent

See [API.md](docs/API.md) for complete documentation.

## AI Agents

### 🔍 Research Agent
- Multi-source search and aggregation
- Source validation and citation
- Report generation
- Real-time search updates

### 💭 Memory Agent
- Knowledge retention and retrieval
- Semantic similarity matching
- Connection discovery
- Insight generation

### 📚 Learning Agent
- Personalized learning paths
- Quiz generation
- Resource recommendation
- Progress tracking

### 🛡️ Security Agent
- Log analysis
- Threat detection
- Anomaly identification
- Security recommendations

## Development Roadmap

- [x] Project initialization
- [ ] Frontend landing page
- [ ] Authentication system
- [ ] Knowledge management
- [ ] AI integration
- [ ] Knowledge graph visualization
- [ ] Research agent
- [ ] Security dashboard
- [ ] Analytics engine
- [ ] Team collaboration
- [ ] Mobile app
- [ ] Advanced NLP features

## Contributing

We welcome contributions! See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](LICENSE) for details

## Acknowledgments

**Design Inspiration:**
- Apple - Design excellence
- Linear.app - Smooth interactions
- Notion - Workspace flexibility
- Obsidian - Knowledge management
- Vercel - Modern tech stack

**Technologies:**
- Next.js team
- FastAPI community
- LangChain/LangGraph
- OpenAI

## Contact & Support

-  Email: support@knownet.ai
-  Issues: [GitHub Issues](https://github.com/yourusername/knownet-x/issues)
-  Discussions: [GitHub Discussions](https://github.com/yourusername/knownet-x/discussions)
-  Website: [knownet.ai](https://knownet.ai)

---

**Made with  by the KnowNet X team**
