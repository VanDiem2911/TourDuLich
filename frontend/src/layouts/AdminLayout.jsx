import { useEffect, useState } from 'react'
import { Link, NavLink, Outlet, useLocation, useNavigate } from 'react-router-dom'
import {
  Activity,
  ArrowUpRight,
  ClipboardList,
  LayoutDashboard,
  LogOut,
  Mail,
  Map as MapIcon,
  Menu,
  Sparkles,
  Tags,
  Users,
  X,
} from 'lucide-react'
import { useAuth } from '../context/AuthContext'
import ConfirmDialog from '../components/ConfirmDialog'
import '../styles/admin.css'

const LINKS = [
  { to: '/admin', label: 'Dashboard', icon: LayoutDashboard, end: true },
  { to: '/admin/tours', label: 'Quản lý tour', icon: MapIcon },
  { to: '/admin/categories', label: 'Danh mục tour', icon: Tags },
  { to: '/admin/bookings', label: 'Đơn đặt tour', icon: ClipboardList },
  { to: '/admin/users', label: 'Tài khoản', icon: Users },
  { to: '/admin/contacts', label: 'Liên hệ', icon: Mail },
  { to: '/admin/tracking', label: 'Hành vi người dùng', icon: Activity },
  { to: '/admin/ai', label: 'Trợ lý AI', icon: Sparkles },
]

export default function AdminLayout() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const [confirmOpen, setConfirmOpen] = useState(false)

  useEffect(() => setSidebarOpen(false), [location.pathname])

  // Esc đóng menu trượt trên di động
  useEffect(() => {
    if (!sidebarOpen) return
    const onKey = (e) => e.key === 'Escape' && setSidebarOpen(false)
    document.addEventListener('keydown', onKey)
    return () => document.removeEventListener('keydown', onKey)
  }, [sidebarOpen])

  const current = LINKS.find((l) => (l.end ? location.pathname === l.to : location.pathname.startsWith(l.to)))

  const doLogout = async () => {
    setConfirmOpen(false)
    await logout()
    navigate('/login', { replace: true })
  }

  return (
    <div className="admin">
      <aside className={`admin__sidebar ${sidebarOpen ? 'is-open' : ''}`} aria-label="Menu quản trị">
        <button
          type="button"
          className="btn btn-ghost admin__sidebar-close"
          aria-label="Đóng menu"
          onClick={() => setSidebarOpen(false)}
        >
          <X size={24} aria-hidden="true" />
        </button>
        <Link to="/admin" className="brand">
          Tour<b>Du</b>Lich<small>Quản trị</small>
        </Link>
        <nav className="admin__nav" aria-label="Điều hướng quản trị">
          {LINKS.map(({ to, label, icon: Icon, end }) => (
            <NavLink key={to} to={to} end={end}>
              <Icon size={20} aria-hidden="true" />
              {label}
            </NavLink>
          ))}
        </nav>
        <Link to="/" className="admin__back">
          Về trang khách hàng
          <ArrowUpRight size={16} aria-hidden="true" />
        </Link>
      </aside>
      <div className={`admin__scrim ${sidebarOpen ? 'is-open' : ''}`} onClick={() => setSidebarOpen(false)} aria-hidden="true" />

      <div className="admin__main">
        <header className="admin__topbar">
          <button
            type="button"
            className="btn btn-ghost btn-icon menu-toggle"
            aria-label="Mở menu quản trị"
            aria-expanded={sidebarOpen}
            onClick={() => setSidebarOpen(true)}
          >
            <Menu size={24} aria-hidden="true" />
          </button>
          <span className="admin__title">{current?.label ?? 'Quản trị'}</span>
          <span className="spacer" />
          <span className="admin__user hide-mobile">{user?.fullName}</span>
          <button type="button" className="btn btn-ghost" onClick={() => setConfirmOpen(true)}>
            <LogOut size={20} aria-hidden="true" />
            <span>Đăng xuất</span>
          </button>
        </header>
        <main className="admin__content">
          <Outlet />
        </main>
      </div>

      <ConfirmDialog
        open={confirmOpen}
        title="Đăng xuất"
        message="Bạn có chắc chắn muốn đăng xuất khỏi hệ thống?"
        confirmLabel="Đăng xuất"
        onConfirm={doLogout}
        onCancel={() => setConfirmOpen(false)}
      />
    </div>
  )
}
