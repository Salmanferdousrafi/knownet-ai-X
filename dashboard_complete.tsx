'use client'

/**
 * KnowNet X - Complete Dashboard & Admin UI (All-in-One)
 * Full featured dashboard with all pages
 */

import React, { useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import {
  LayoutDashboard,
  Brain,
  Network,
  Settings,
  LogOut,
  Plus,
  Search,
  Menu,
  X,
  FileText,
  TrendingUp,
  Lock,
  Users,
  Activity,
  ChevronRight,
} from 'lucide-react'

// ============================================================================
// STATE MANAGEMENT (Mini Zustand alternative)
// ============================================================================

class AppStore {
  constructor() {
    this.state = {
      user: null,
      currentPage: 'dashboard',
      sidebarOpen: true,
      projects: [],
      knowledge: [],
      agents: [],
      analytics: {},
    }
    this.listeners = []
  }

  setState(updates) {
    this.state = { ...this.state, ...updates }
    this.listeners.forEach((listener) => listener(this.state))
  }

  subscribe(listener) {
    this.listeners.push(listener)
    return () => {
      this.listeners = this.listeners.filter((l) => l !== listener)
    }
  }

  getState() {
    return this.state
  }
}

const store = new AppStore()

// ============================================================================
// HOOKS
// ============================================================================

function useStore(selector) {
  const [state, setState] = useState(store.getState())

  useEffect(() => {
    return store.subscribe((newState) => {
      setState(newState)
    })
  }, [])

  return selector ? selector(state) : state
}

// ============================================================================
// COMPONENTS
// ============================================================================

// Sidebar Navigation
function Sidebar() {
  const { currentPage, sidebarOpen } = useStore()

  const menuItems = [
    { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
    { id: 'knowledge', label: 'Knowledge Base', icon: FileText },
    { id: 'graph', label: 'Knowledge Graph', icon: Network },
    { id: 'research', label: 'Research', icon: Brain },
    { id: 'analytics', label: 'Analytics', icon: TrendingUp },
    { id: 'security', label: 'Security', icon: Lock },
    { id: 'team', label: 'Team', icon: Users },
    { id: 'settings', label: 'Settings', icon: Settings },
  ]

  return (
    <motion.aside
      initial={{ x: -300 }}
      animate={{ x: sidebarOpen ? 0 : -300 }}
      className="fixed left-0 top-0 h-screen w-64 border-r border-emerald-900/30 bg-emerald-950/50 backdrop-blur"
    >
      <div className="p-6">
        <h1 className="text-2xl font-bold text-emerald-400">KnowNet X</h1>
      </div>

      <nav className="space-y-2 px-4">
        {menuItems.map((item) => {
          const Icon = item.icon
          return (
            <button
              key={item.id}
              onClick={() => store.setState({ currentPage: item.id })}
              className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg transition-all ${
                currentPage === item.id
                  ? 'bg-emerald-500/20 text-emerald-400 border-l-2 border-emerald-400'
                  : 'text-gray-300 hover:bg-emerald-500/10'
              }`}
            >
              <Icon className="h-5 w-5" />
              {item.label}
            </button>
          )
        })}
      </nav>

      <div className="absolute bottom-0 left-0 right-0 border-t border-emerald-900/30 p-4">
        <button className="flex w-full items-center gap-3 rounded-lg px-4 py-3 text-gray-300 hover:bg-red-500/10">
          <LogOut className="h-5 w-5" />
          Logout
        </button>
      </div>
    </motion.aside>
  )
}

// Top Header
function Header() {
  const { sidebarOpen } = useStore()
  const [query, setQuery] = useState('')

  return (
    <header className="fixed right-0 top-0 left-0 border-b border-emerald-900/30 bg-emerald-950/50 backdrop-blur md:left-64">
      <div className="flex items-center justify-between p-4">
        <div className="flex items-center gap-4">
          <button
            onClick={() => store.setState({ sidebarOpen: !sidebarOpen })}
            className="md:hidden"
          >
            {sidebarOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
          </button>

          <div className="hidden md:flex items-center gap-2 rounded-lg bg-emerald-950/80 px-4 py-2 border border-emerald-900/30 flex-1 max-w-md">
            <Search className="h-4 w-4 text-gray-500" />
            <input
              type="text"
              placeholder="Search knowledge, projects..."
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              className="flex-1 bg-transparent outline-none text-white placeholder-gray-500"
            />
          </div>
        </div>

        <div className="flex items-center gap-4">
          <button className="rounded-lg bg-emerald-500/20 px-4 py-2 text-emerald-400 hover:bg-emerald-500/30 transition-all">
            <Plus className="h-5 w-5" />
          </button>
          <img
            src="https://via.placeholder.com/40"
            alt="User"
            className="h-10 w-10 rounded-full border-2 border-emerald-400"
          />
        </div>
      </div>
    </header>
  )
}

// Dashboard Page
function DashboardPage() {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="space-y-6"
    >
      <h1 className="text-3xl font-bold text-white">Dashboard</h1>

      {/* Stats Cards */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {[
          { label: 'Total Knowledge', value: '248', icon: FileText, color: 'emerald' },
          { label: 'Projects', value: '12', icon: Network, color: 'blue' },
          { label: 'Team Members', value: '8', icon: Users, color: 'purple' },
          { label: 'AI Queries', value: '1.2K', icon: Brain, color: 'orange' },
        ].map((stat, i) => {
          const Icon = stat.icon
          return (
            <motion.div
              key={i}
              whileHover={{ scale: 1.05 }}
              className="rounded-xl border border-emerald-900/30 bg-emerald-950/50 p-6 backdrop-blur"
            >
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-gray-400 text-sm">{stat.label}</p>
                  <p className="text-3xl font-bold text-white mt-2">{stat.value}</p>
                </div>
                <Icon className="h-12 w-12 text-emerald-400/30" />
              </div>
            </motion.div>
          )
        })}
      </div>

      {/* Recent Activity */}
      <div className="rounded-xl border border-emerald-900/30 bg-emerald-950/50 p-6 backdrop-blur">
        <h2 className="text-xl font-bold text-white mb-4 flex items-center gap-2">
          <Activity className="h-5 w-5 text-emerald-400" />
          Recent Activity
        </h2>
        <div className="space-y-3">
          {[
            { action: 'Created knowledge entry', time: '2 hours ago', user: 'You' },
            { action: 'Research completed', time: '5 hours ago', user: 'Research Agent' },
            { action: 'New team member added', time: '1 day ago', user: 'Admin' },
          ].map((item, i) => (
            <div key={i} className="flex items-center justify-between border-b border-emerald-900/20 pb-3">
              <div>
                <p className="text-white">{item.action}</p>
                <p className="text-gray-400 text-sm">{item.user}</p>
              </div>
              <p className="text-gray-500 text-sm">{item.time}</p>
            </div>
          ))}
        </div>
      </div>
    </motion.div>
  )
}

// Knowledge Base Page
function KnowledgePage() {
  const [entries, setEntries] = useState([
    { id: 1, title: 'AI Fundamentals', content: 'Introduction to AI...', tags: ['AI', 'Basics'] },
    { id: 2, title: 'Database Design', content: 'Relational databases...', tags: ['Database', 'SQL'] },
  ])
  const [newEntry, setNewEntry] = useState({ title: '', content: '', tags: [] })

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="space-y-6"
    >
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold text-white">Knowledge Base</h1>
        <button className="flex items-center gap-2 rounded-lg bg-emerald-500 px-4 py-2 text-black font-semibold hover:bg-emerald-600 transition-all">
          <Plus className="h-5 w-5" />
          New Entry
        </button>
      </div>

      {/* Knowledge Entries */}
      <div className="grid gap-4">
        {entries.map((entry) => (
          <motion.div
            key={entry.id}
            whileHover={{ scale: 1.02 }}
            className="rounded-xl border border-emerald-900/30 bg-emerald-950/50 p-6 backdrop-blur cursor-pointer"
          >
            <div className="flex items-start justify-between">
              <div className="flex-1">
                <h3 className="text-lg font-bold text-white">{entry.title}</h3>
                <p className="text-gray-400 text-sm mt-2 line-clamp-2">{entry.content}</p>
                <div className="flex gap-2 mt-4">
                  {entry.tags.map((tag) => (
                    <span
                      key={tag}
                      className="inline-block rounded-full bg-emerald-500/20 px-3 py-1 text-xs text-emerald-300"
                    >
                      {tag}
                    </span>
                  ))}
                </div>
              </div>
              <ChevronRight className="h-5 w-5 text-gray-500" />
            </div>
          </motion.div>
        ))}
      </div>
    </motion.div>
  )
}

// Research Page
function ResearchPage() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])

  const handleSearch = () => {
    // Call research agent
    setResults([
      { title: 'Result 1', source: 'Source A', relevance: 0.95 },
      { title: 'Result 2', source: 'Source B', relevance: 0.87 },
    ])
  }

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="space-y-6"
    >
      <h1 className="text-3xl font-bold text-white">Research Assistant</h1>

      {/* Search Box */}
      <div className="rounded-xl border border-emerald-900/30 bg-emerald-950/50 p-6 backdrop-blur">
        <div className="flex gap-2">
          <input
            type="text"
            placeholder="Enter your research query..."
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && handleSearch()}
            className="flex-1 rounded-lg bg-emerald-900/20 px-4 py-3 text-white placeholder-gray-500 outline-none"
          />
          <button
            onClick={handleSearch}
            className="rounded-lg bg-emerald-500 px-6 py-3 font-semibold text-black hover:bg-emerald-600 transition-all"
          >
            Search
          </button>
        </div>
      </div>

      {/* Results */}
      {results.length > 0 && (
        <div className="space-y-4">
          {results.map((result, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              className="rounded-xl border border-emerald-900/30 bg-emerald-950/50 p-6 backdrop-blur"
            >
              <h3 className="text-lg font-bold text-white">{result.title}</h3>
              <div className="flex items-center justify-between mt-4">
                <p className="text-gray-400 text-sm">{result.source}</p>
                <div className="flex items-center gap-2">
                  <div className="h-2 bg-gray-700 rounded-full w-20">
                    <div
                      className="h-full bg-emerald-500 rounded-full"
                      style={{ width: `${result.relevance * 100}%` }}
                    />
                  </div>
                  <span className="text-emerald-400 text-sm">{(result.relevance * 100).toFixed(0)}%</span>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      )}
    </motion.div>
  )
}

// Analytics Page
function AnalyticsPage() {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="space-y-6"
    >
      <h1 className="text-3xl font-bold text-white">Analytics</h1>

      {/* Charts Container */}
      <div className="grid gap-6 lg:grid-cols-2">
        {/* Usage Chart */}
        <div className="rounded-xl border border-emerald-900/30 bg-emerald-950/50 p-6 backdrop-blur">
          <h2 className="text-lg font-bold text-white mb-4">Usage Over Time</h2>
          <div className="h-64 flex items-end gap-2">
            {[40, 60, 80, 50, 90, 70, 85].map((height, i) => (
              <div
                key={i}
                className="flex-1 bg-gradient-to-t from-emerald-500 to-emerald-400 rounded-t"
                style={{ height: `${height}%` }}
              />
            ))}
          </div>
        </div>

        {/* Queries Distribution */}
        <div className="rounded-xl border border-emerald-900/30 bg-emerald-950/50 p-6 backdrop-blur">
          <h2 className="text-lg font-bold text-white mb-4">Query Distribution</h2>
          <div className="space-y-4">
            {[
              { label: 'Research', value: 45, color: 'emerald' },
              { label: 'Memory', value: 30, color: 'blue' },
              { label: 'Learning', value: 20, color: 'purple' },
              { label: 'Security', value: 5, color: 'orange' },
            ].map((item, i) => (
              <div key={i}>
                <div className="flex justify-between mb-2">
                  <span className="text-gray-300">{item.label}</span>
                  <span className="text-emerald-400">{item.value}%</span>
                </div>
                <div className="h-2 bg-gray-700 rounded-full overflow-hidden">
                  <div
                    className={`h-full bg-${item.color}-500 rounded-full`}
                    style={{ width: `${item.value}%` }}
                  />
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </motion.div>
  )
}

// Settings Page
function SettingsPage() {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="space-y-6"
    >
      <h1 className="text-3xl font-bold text-white">Settings</h1>

      {/* Account Settings */}
      <div className="rounded-xl border border-emerald-900/30 bg-emerald-950/50 p-6 backdrop-blur">
        <h2 className="text-lg font-bold text-white mb-4">Account</h2>
        <div className="space-y-4">
          <div>
            <label className="block text-gray-300 text-sm mb-2">Full Name</label>
            <input
              type="text"
              defaultValue="Your Name"
              className="w-full rounded-lg bg-emerald-900/20 px-4 py-2 text-white outline-none"
            />
          </div>
          <div>
            <label className="block text-gray-300 text-sm mb-2">Email</label>
            <input
              type="email"
              defaultValue="you@example.com"
              className="w-full rounded-lg bg-emerald-900/20 px-4 py-2 text-white outline-none"
            />
          </div>
          <button className="rounded-lg bg-emerald-500 px-6 py-2 font-semibold text-black hover:bg-emerald-600 transition-all">
            Save Changes
          </button>
        </div>
      </div>

      {/* Security Settings */}
      <div className="rounded-xl border border-emerald-900/30 bg-emerald-950/50 p-6 backdrop-blur">
        <h2 className="text-lg font-bold text-white mb-4 flex items-center gap-2">
          <Lock className="h-5 w-5 text-emerald-400" />
          Security
        </h2>
        <div className="space-y-4">
          <button className="w-full rounded-lg border border-emerald-900/30 px-6 py-3 text-emerald-400 hover:bg-emerald-950/50 transition-all">
            Change Password
          </button>
          <button className="w-full rounded-lg border border-emerald-900/30 px-6 py-3 text-emerald-400 hover:bg-emerald-950/50 transition-all">
            Enable Two-Factor Authentication
          </button>
        </div>
      </div>
    </motion.div>
  )
}

// ============================================================================
// MAIN DASHBOARD
// ============================================================================

export default function Dashboard() {
  const { currentPage } = useStore()

  useEffect(() => {
    // Load initial data
    store.setState({
      user: { name: 'User', email: 'user@knownet.ai' },
    })
  }, [])

  const renderPage = () => {
    switch (currentPage) {
      case 'dashboard':
        return <DashboardPage />
      case 'knowledge':
        return <KnowledgePage />
      case 'research':
        return <ResearchPage />
      case 'analytics':
        return <AnalyticsPage />
      case 'settings':
        return <SettingsPage />
      default:
        return <DashboardPage />
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#0D1117] via-emerald-950/5 to-[#0D1117]">
      <Sidebar />
      <Header />

      {/* Main Content */}
      <main className="pt-20 md:ml-64">
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="p-6"
        >
          {renderPage()}
        </motion.div>
      </main>
    </div>
  )
}
