#!/usr/bin/env python3
"""
KnowNet X - Complete Backend (All-in-One)
Single file with all backend functionality
"""

import os
import sys
from datetime import datetime, timedelta
from typing import Optional, List, Dict
import uuid

# ============================================================================
# CONFIGURATION
# ============================================================================

class Config:
    """Complete Configuration"""
    # App
    APP_NAME = "KnowNet X"
    DEBUG = os.getenv("DEBUG", "True") == "True"
    
    # Database
    DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://knownet:knownet_password@localhost:5432/knownet_db")
    
    # Redis
    REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379/0")
    
    # JWT
    JWT_SECRET = os.getenv("JWT_SECRET", "your-secret-key-change-in-production")
    JWT_ALGORITHM = "HS256"
    JWT_EXPIRATION_HOURS = 24
    
    # OpenAI
    OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
    
    # CORS
    CORS_ORIGINS = ["http://localhost:3000", "http://localhost:8000"]


# ============================================================================
# MODELS (SQLAlchemy)
# ============================================================================

from sqlalchemy import Column, String, Integer, DateTime, Boolean, Text, JSON, ForeignKey, create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship, sessionmaker

Base = declarative_base()


class User(Base):
    __tablename__ = "users"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    email = Column(String(255), unique=True, nullable=False, index=True)
    username = Column(String(100), unique=True, nullable=False, index=True)
    full_name = Column(String(255))
    password_hash = Column(String(255), nullable=False)
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    mfa_enabled = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    projects = relationship("Project", back_populates="owner")
    knowledge = relationship("Knowledge", back_populates="creator")


class Project(Base):
    __tablename__ = "projects"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    owner_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    name = Column(String(255), nullable=False)
    description = Column(Text)
    color = Column(String(7), default="#00C853")
    is_public = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    owner = relationship("User", back_populates="projects")
    knowledge_entries = relationship("Knowledge", back_populates="project")


class Knowledge(Base):
    __tablename__ = "knowledge"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    project_id = Column(String(36), ForeignKey("projects.id"), nullable=False)
    creator_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    title = Column(String(255), nullable=False)
    content = Column(Text)
    tags = Column(JSON, default=list)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    project = relationship("Project", back_populates="knowledge_entries")
    creator = relationship("User", back_populates="knowledge")


# ============================================================================
# SCHEMAS (Pydantic)
# ============================================================================

from pydantic import BaseModel, EmailStr
from typing import Optional as OptionalType


class UserRegister(BaseModel):
    email: EmailStr
    username: str
    password: str
    full_name: str


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class ProjectCreate(BaseModel):
    name: str
    description: OptionalType[str] = None
    color: str = "#00C853"


class KnowledgeCreate(BaseModel):
    project_id: str
    title: str
    content: str
    tags: List[str] = []


# ============================================================================
# SECURITY
# ============================================================================

from passlib.context import CryptContext
from jose import JWTError, jwt

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


class Security:
    """Security utilities"""
    
    @staticmethod
    def hash_password(password: str) -> str:
        return pwd_context.hash(password)
    
    @staticmethod
    def verify_password(plain: str, hashed: str) -> bool:
        return pwd_context.verify(plain, hashed)
    
    @staticmethod
    def create_token(data: Dict, expires_delta: OptionalType[timedelta] = None) -> str:
        to_encode = data.copy()
        if expires_delta:
            expire = datetime.utcnow() + expires_delta
        else:
            expire = datetime.utcnow() + timedelta(hours=Config.JWT_EXPIRATION_HOURS)
        
        to_encode.update({"exp": expire})
        return jwt.encode(to_encode, Config.JWT_SECRET, algorithm=Config.JWT_ALGORITHM)
    
    @staticmethod
    def verify_token(token: str) -> OptionalType[Dict]:
        try:
            return jwt.decode(token, Config.JWT_SECRET, algorithms=[Config.JWT_ALGORITHM])
        except JWTError:
            return None


# ============================================================================
# DATABASE
# ============================================================================

engine = create_engine(Config.DATABASE_URL, echo=Config.DEBUG)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db():
    Base.metadata.create_all(bind=engine)


# ============================================================================
# FASTAPI APPLICATION
# ============================================================================

from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

app = FastAPI(title=Config.APP_NAME, version="0.1.0")

# Add CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=Config.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================================
# ROUTES
# ============================================================================

# ROOT ENDPOINTS
@app.get("/")
async def root():
    return {"app": Config.APP_NAME, "status": "running"}


@app.get("/health")
async def health():
    return {"status": "healthy"}


# AUTHENTICATION ENDPOINTS
@app.post("/api/v1/auth/register", response_model=TokenResponse)
async def register(user: UserRegister, db: Session = Depends(get_db)):
    """Register new user"""
    # Check if user exists
    existing = db.query(User).filter(User.email == user.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="User already exists")
    
    # Create user
    db_user = User(
        email=user.email,
        username=user.username,
        full_name=user.full_name,
        password_hash=Security.hash_password(user.password),
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    token = Security.create_token({"sub": db_user.id})
    return {"access_token": token}


@app.post("/api/v1/auth/login", response_model=TokenResponse)
async def login(user: UserLogin, db: Session = Depends(get_db)):
    """Login user"""
    db_user = db.query(User).filter(User.email == user.email).first()
    if not db_user or not Security.verify_password(user.password, db_user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    token = Security.create_token({"sub": db_user.id})
    return {"access_token": token}


# HELPER: Get current user
async def get_current_user(token: str, db: Session = Depends(get_db)):
    """Get current authenticated user"""
    payload = Security.verify_token(token)
    if not payload:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    user_id = payload.get("sub")
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
    
    return user


# PROJECTS ENDPOINTS
@app.post("/api/v1/projects/create")
async def create_project(
    project: ProjectCreate,
    token: str,
    db: Session = Depends(get_db)
):
    """Create project"""
    user = await get_current_user(token, db)
    
    db_project = Project(
        owner_id=user.id,
        name=project.name,
        description=project.description,
        color=project.color,
    )
    db.add(db_project)
    db.commit()
    db.refresh(db_project)
    
    return {
        "id": db_project.id,
        "name": db_project.name,
        "description": db_project.description,
        "color": db_project.color,
        "created_at": db_project.created_at,
    }


@app.get("/api/v1/projects")
async def list_projects(token: str, db: Session = Depends(get_db)):
    """List user projects"""
    user = await get_current_user(token, db)
    projects = db.query(Project).filter(Project.owner_id == user.id).all()
    
    return {
        "projects": [
            {
                "id": p.id,
                "name": p.name,
                "description": p.description,
                "color": p.color,
                "created_at": p.created_at,
            }
            for p in projects
        ]
    }


# KNOWLEDGE ENDPOINTS
@app.post("/api/v1/knowledge/create")
async def create_knowledge(
    knowledge: KnowledgeCreate,
    token: str,
    db: Session = Depends(get_db)
):
    """Create knowledge entry"""
    user = await get_current_user(token, db)
    
    db_knowledge = Knowledge(
        project_id=knowledge.project_id,
        creator_id=user.id,
        title=knowledge.title,
        content=knowledge.content,
        tags=knowledge.tags,
    )
    db.add(db_knowledge)
    db.commit()
    db.refresh(db_knowledge)
    
    return {
        "id": db_knowledge.id,
        "title": db_knowledge.title,
        "content": db_knowledge.content,
        "tags": db_knowledge.tags,
        "created_at": db_knowledge.created_at,
    }


@app.get("/api/v1/knowledge/{knowledge_id}")
async def get_knowledge(knowledge_id: str, token: str, db: Session = Depends(get_db)):
    """Get knowledge entry"""
    user = await get_current_user(token, db)
    knowledge = db.query(Knowledge).filter(Knowledge.id == knowledge_id).first()
    
    if not knowledge:
        raise HTTPException(status_code=404, detail="Knowledge not found")
    
    return {
        "id": knowledge.id,
        "title": knowledge.title,
        "content": knowledge.content,
        "tags": knowledge.tags,
        "created_at": knowledge.created_at,
    }


@app.get("/api/v1/knowledge/search")
async def search_knowledge(
    q: str,
    project_id: str,
    token: str,
    db: Session = Depends(get_db)
):
    """Search knowledge entries"""
    user = await get_current_user(token, db)
    
    results = db.query(Knowledge).filter(
        Knowledge.project_id == project_id,
        Knowledge.title.ilike(f"%{q}%")
    ).all()
    
    return {
        "results": [
            {
                "id": k.id,
                "title": k.title,
                "content": k.content[:100],
                "created_at": k.created_at,
            }
            for k in results
        ]
    }


# ============================================================================
# STARTUP/SHUTDOWN
# ============================================================================

@app.on_event("startup")
async def startup_event():
    """Initialize database on startup"""
    init_db()
    print("✓ Database initialized")


# ============================================================================
# MAIN
# ============================================================================

if __name__ == "__main__":
    import uvicorn
    init_db()
    uvicorn.run(app, host="0.0.0.0", port=8000)
