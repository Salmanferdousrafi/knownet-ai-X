'use client'

/**
 * KnowNet X - Complete Frontend (All-in-One)
 * Single file with all frontend functionality
 */

import React, { useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import { ChevronRight, Sparkles, Github, Brain, Network, History, Lock, Users, BarChart3, Cpu, BookOpen, Code2, Database, Cloud, ArrowRight } from 'lucide-react'

// ============================================================================
// CONFIGURATION
// ============================================================================

const CONFIG = {
  API_URL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000',
}

// ============================================================================
// API CLIENT
// ============================================================================

class APIClient {
  constructor(baseURL = CONFIG.API_URL) {
    this.baseURL = baseURL
    this.token = null
  }

  setToken(token) {
    this.token = token
  }

  async request(endpoint, options = {}) {
    const headers = {
      'Content-Type': 'application/json',
      ...options.headers,
    }

    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`
    }

    const response = await fetch(`${this.baseURL}${endpoint}`, {
      ...options,
      headers,
    })

    if (!response.ok) {
      throw new Error(`API Error: ${response.status}`)
    }

    return response.json()
  }

  // Auth
  async register(email, username, password, fullName) {
    return this.request('/api/v1/auth/register', {
      method: 'POST',
      body: JSON.stringify({ email, username, password, full_name: fullName }),
    })
  }

  async login(email, password) {
    return this.request('/api/v1/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    })
  }

  // Projects
  async createProject(name, description, color) {
    return this.request('/api/v1/projects/create', {
      method: 'POST',
      body: JSON.stringify({ name, description, color }),
    })
  }

  async listProjects() {
    return this.request('/api/v1/projects')
  }

  // Knowledge
  async createKnowledge(projectId, title, content, tags) {
    return this.request('/api/v1/knowledge/create', {
      method: 'POST',
      body: JSON.stringify({
        project_id: projectId,
        title,
        content,
        tags,
      }),
    })
  }

  async getKnowledge(id) {
    return this.request(`/api/v1/knowledge/${id}`)
  }

  async searchKnowledge(q, projectId) {
    return this.request(`/api/v1/knowledge/search?q=${q}&project_id=${projectId}`)
  }
}

const apiClient = new APIClient()

// ============================================================================
// CUSTOM HOOKS
// ============================================================================

function useAsync(asyncFunction, immediate = true) {
  const [status, setStatus] = useState('idle')
  const [value, setValue] = useState(null)
  const [error, setError] = useState(null)

  const execute = React.useCallback(async () => {
    setStatus('pending')
    try {
      const response = await asyncFunction()
      setValue(response)
      setStatus('success')
      return response
    } catch (error) {
      setError(error.message)
      setStatus('error')
    }
  }, [asyncFunction])

  React.useEffect(() => {
    if (immediate) execute()
  }, [immediate, execute])

  return { execute, status, value, error }
}

function useLocalStorage(key, initialValue) {
  const [storedValue, setStoredValue] = useState(initialValue)

  useEffect(() => {
    const item = localStorage?.getItem(key)
    if (item) setStoredValue(JSON.parse(item))
  }, [key])

  const setValue = (value) => {
    setStoredValue(value)
    localStorage?.setItem(key, JSON.stringify(value))
  }

  return [storedValue, setValue]
}

// ============================================================================
// COMPONENTS
// ============================================================================

function HeroSection() {
  return (
    <section className="relative min-h-screen overflow-hidden pt-20">
      <div className="absolute inset-0 -z-10 bg-gradient-to-br from-[#0D1117] via-emerald-950/5 to-[#0D1117]" />

      <motion.div
        className="container mx-auto max-w-6xl px-4 py-16 text-center"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ staggerChildren: 0.2, delayChildren: 0.3 }}
      >
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="mb-8">
          <span className="inline-flex items-center gap-2 rounded-full bg-emerald-950/30 px-3 py-1 text-sm font-medium text-emerald-400 border border-emerald-400/30">
            <Sparkles className="h-4 w-4" />
            Powered by AI & Enterprise Security
          </span>
        </motion.div>

        <motion.h1
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-4 text-5xl font-bold leading-tight text-white md:text-6xl lg:text-7xl"
        >
          Transform Information Into{' '}
          <span className="bg-gradient-to-r from-emerald-400 via-yellow-400 to-emerald-400 bg-clip-text text-transparent">
            Intelligence
          </span>
        </motion.h1>

        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mx-auto mb-12 max-w-2xl text-lg text-gray-300"
        >
          KnowNet X combines AI, knowledge graphs, and enterprise security for the world's most
          beautiful knowledge operating system.
        </motion.p>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-12 flex flex-col gap-4 sm:flex-row sm:justify-center"
        >
          <button className="flex items-center justify-center gap-2 rounded-lg bg-emerald-400 px-6 py-3 font-semibold text-black hover:scale-105 transition-transform">
            Launch Platform
            <ChevronRight className="h-5 w-5" />
          </button>
          <button className="flex items-center justify-center gap-2 rounded-lg border border-emerald-400/50 px-6 py-3 font-semibold text-emerald-400 hover:bg-emerald-950/20 transition-colors">
            <Github className="h-5 w-5" />
            GitHub Repository
          </button>
        </motion.div>
      </motion.div>
    </section>
  )
}

function FeaturesSection() {
  const features = [
    { icon: Brain, title: 'AI Research Engine', desc: 'Multi-source research with validation' },
    { icon: Network, title: 'Knowledge Graph', desc: 'Visual relationship mapping' },
    { icon: History, title: 'Memory System', desc: 'Long-term semantic memory' },
    { icon: Lock, title: 'Enterprise Security', desc: 'RBAC, MFA, Encryption' },
    { icon: Users, title: 'Team Collaboration', desc: 'Real-time workspace' },
    { icon: BarChart3, title: 'Analytics Dashboard', desc: 'Usage insights & trends' },
    { icon: Cpu, title: 'Multi-Agent AI', desc: 'Research, Memory, Learning agents' },
    { icon: BookOpen, title: 'Learning Hub', desc: 'Personalized learning paths' },
  ]

  return (
    <section className="py-24 sm:py-32">
      <div className="container mx-auto max-w-6xl px-4">
        <motion.div
          className="mb-16 text-center"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
        >
          <h2 className="mb-4 text-3xl font-bold text-white md:text-4xl lg:text-5xl">
            Powerful Features, Beautiful Design
          </h2>
        </motion.div>

        <motion.div
          className="grid gap-8 sm:grid-cols-2 lg:grid-cols-4"
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
        >
          {features.map((feature, i) => {
            const Icon = feature.icon
            return (
              <motion.div
                key={i}
                whileHover={{ y: -5 }}
                className="group rounded-xl border border-emerald-400/20 bg-emerald-950/10 p-6 backdrop-blur"
              >
                <div className="mb-4 inline-flex rounded-lg bg-emerald-400/10 p-3 text-emerald-400">
                  <Icon className="h-6 w-6" />
                </div>
                <h3 className="mb-2 text-lg font-semibold text-white">{feature.title}</h3>
                <p className="text-sm text-gray-400">{feature.desc}</p>
              </motion.div>
            )
          })}
        </motion.div>
      </div>
    </section>
  )
}

function ArchitectureSection() {
  const layers = [
    {
      icon: Code2,
      name: 'Frontend',
      tech: ['Next.js 15', 'React 19', 'TypeScript', 'TailwindCSS', 'Framer Motion'],
    },
    {
      icon: Database,
      name: 'Backend',
      tech: ['FastAPI', 'Python 3.11', 'PostgreSQL', 'Redis', 'Celery'],
    },
    {
      icon: Cloud,
      name: 'AI & Infrastructure',
      tech: ['LangGraph', 'OpenAI', 'Vector DB', 'Docker', 'Kubernetes'],
    },
  ]

  return (
    <section className="py-24 sm:py-32">
      <div className="container mx-auto max-w-6xl px-4">
        <motion.div
          className="mb-16 text-center"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
        >
          <h2 className="mb-4 text-3xl font-bold text-white md:text-4xl lg:text-5xl">
            Enterprise-Grade Architecture
          </h2>
        </motion.div>

        <motion.div
          className="grid gap-8 lg:grid-cols-3"
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
        >
          {layers.map((layer, i) => {
            const Icon = layer.icon
            return (
              <motion.div
                key={i}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.1 }}
                viewport={{ once: true }}
                className="rounded-xl border border-emerald-400/20 bg-emerald-950/10 p-8 backdrop-blur"
              >
                <div className="mb-6 inline-flex rounded-lg bg-gradient-to-r from-emerald-400 to-transparent p-4 text-white">
                  <Icon className="h-6 w-6" />
                </div>
                <h3 className="mb-4 text-xl font-semibold text-white">{layer.name}</h3>
                <ul className="space-y-2">
                  {layer.tech.map((t, j) => (
                    <li key={j} className="flex items-center gap-2 text-sm text-gray-400">
                      <span className="inline-block h-1.5 w-1.5 rounded-full bg-emerald-400" />
                      {t}
                    </li>
                  ))}
                </ul>
              </motion.div>
            )
          })}
        </motion.div>
      </div>
    </section>
  )
}

function CTASection() {
  return (
    <section className="py-24 sm:py-32">
      <div className="container mx-auto max-w-2xl px-4 text-center">
        <motion.h2
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="mb-6 text-3xl font-bold text-white md:text-4xl lg:text-5xl"
        >
          Ready to Transform Your Knowledge?
        </motion.h2>

        <motion.p
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          viewport={{ once: true }}
          className="mb-12 text-lg text-gray-400"
        >
          Join us in building the future of knowledge management. Start now with KnowNet X.
        </motion.p>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          viewport={{ once: true }}
          className="flex flex-col gap-4 sm:flex-row sm:justify-center"
        >
          <button className="flex items-center justify-center gap-2 rounded-lg bg-emerald-400 px-6 py-3 font-semibold text-black hover:scale-105 transition-transform">
            Launch Platform
            <ArrowRight className="h-5 w-5" />
          </button>
          <button className="flex items-center justify-center gap-2 rounded-lg border border-emerald-400/50 px-6 py-3 font-semibold text-emerald-400 hover:bg-emerald-950/20 transition-colors">
            <Github className="h-5 w-5" />
            View on GitHub
          </button>
        </motion.div>

        <motion.div
          className="mt-16 grid gap-8 sm:grid-cols-3"
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          transition={{ delay: 0.3 }}
          viewport={{ once: true }}
        >
          {[
            { value: '100%', label: 'Open Source' },
            { value: '4+', label: 'AI Agents' },
            { value: 'Enterprise', label: 'Grade Security' },
          ].map((stat, i) => (
            <div key={i}>
              <p className="text-3xl font-bold text-emerald-400 md:text-4xl">{stat.value}</p>
              <p className="mt-2 text-sm text-gray-400">{stat.label}</p>
            </div>
          ))}
        </motion.div>
      </div>
    </section>
  )
}

// ============================================================================
// MAIN APP
// ============================================================================

export default function App() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-[#0D1117] via-emerald-950/5 to-[#0D1117] text-white">
      <HeroSection />
      <FeaturesSection />
      <ArchitectureSection />
      <CTASection />
    </div>
  )
}
