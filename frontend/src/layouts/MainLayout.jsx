import { useEffect, useRef, useState } from 'react'
import { Link, NavLink, Outlet, useLocation, useNavigate } from 'react-router-dom'
import { ChevronDown, ClipboardList, LayoutDashboard, LogOut, Menu, ShoppingBag, UserRound, X } from 'lucide-react'
import { useAuth } from '../context/AuthContext'
import { useCart } from '../context/CartContext'
import ConfirmDialog from '../components/ConfirmDialog'

const NAV = [
  { to: '/', label: 'Trang chủ', end: true },
  { to: '/tours', label: 'Tour du lịch' },
  { to: '/contact', label: 'Liên hệ' },
]

export function Wordmark() {
  return (
    <>
      Tour<b>Du</b>Lich
    </>
  )
}

function UserMenu() {
  const { user, isAdmin, logout } = useAuth()
  const navigate = useNavigate()
  const [open, setOpen] = useState(false)
  const [confirmOpen, setConfirmOpen] = useState(false)
  const ref = useRef(null)

  useEffect(() => {
    if (!open) return
    const onDown = (e) => !ref.current?.contains(e.target) && setOpen(false)
    const onKey = (e) => e.key === 'Escape' && setOpen(false)
    document.addEventListener('mousedown', onDown)
    document.addEventListener('keydown', onKey)
    return () => {
      document.removeEventListener('mousedown', onDown)
      document.removeEventListener('keydown', onKey)
    }
  }, [open])

  const doLogout = async () => {
    setConfirmOpen(false)
    setOpen(false)
    await logout()
    navigate('/', { replace: true })
  }

  return (
    <div className="user-menu" ref={ref}>
      <button
        type="button"
        className="btn btn-ghost"
        aria-haspopup="menu"
        aria-expanded={open}
        onClick={() => setOpen((v) => !v)}
      >
        <UserRound size={19} aria-hidden="true" />
        <span className="hide-mobile">{user.fullName}</span>
        <span className="visually-hidden">Menu tài khoản</span>
        <ChevronDown size={16} aria-hidden="true" />
      </button>
      {open && (
        <div className="user-menu__panel" role="menu">
          <div className="user-menu__name">
            <strong>{user.fullName}</strong>
            <small>{user.email}</small>
          </div>
          <Link to="/my-bookings" role="menuitem" onClick={() => setOpen(false)}>
            <ClipboardList size={18} aria-hidden="true" /> Đơn đặt tour của tôi
          </Link>
          <Link to="/account" role="menuitem" onClick={() => setOpen(false)}>
            <UserRound size={18} aria-hidden="true" /> Thông tin tài khoản
          </Link>
          {isAdmin && (
            <Link to="/admin" role="menuitem" onClick={() => setOpen(false)}>
              <LayoutDashboard size={18} aria-hidden="true" /> Khu vực quản trị
            </Link>
          )}
          <button type="button" role="menuitem" onClick={() => setConfirmOpen(true)}>
            <LogOut size={18} aria-hidden="true" /> Đăng xuất
          </button>
        </div>
      )}
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

export default function MainLayout() {
  const { isAuthenticated, loading } = useAuth()
  const { count } = useCart()
  const [menuOpen, setMenuOpen] = useState(false)
  const location = useLocation()

  useEffect(() => {
    setMenuOpen(false)
    window.scrollTo(0, 0)
  }, [location.pathname])

  return (
    <>
      <a href="#main" className="skip-link">
        Bỏ qua điều hướng
      </a>
      <header className="site-header">
        <div className="container site-header__inner">
          <Link to="/" className="brand" aria-label="TourDuLich - Trang chủ">
            <Wordmark />
            <small className="hide-mobile">Lữ hành</small>
          </Link>

          <nav id="main-nav" className={`main-nav ${menuOpen ? 'is-open' : ''}`} aria-label="Điều hướng chính">
            {NAV.map((item) => (
              <NavLink key={item.to} to={item.to} end={item.end}>
                {item.label}
              </NavLink>
            ))}
          </nav>

          <div className="header-actions">
            <Link
              to="/cart"
              className="btn btn-ghost btn-icon cart-link"
              aria-label={`Phiếu đặt tour tạm${count ? `, ${count} tour` : ''}`}
            >
              <ShoppingBag size={22} aria-hidden="true" />
              {count > 0 && <span className="cart-count">{count}</span>}
            </Link>
            {!loading &&
              (isAuthenticated ? (
                <UserMenu />
              ) : (
                <>
                  <Link to="/login" className="btn btn-ghost">
                    Đăng nhập
                  </Link>
                  <Link to="/register" className="btn btn-primary hide-mobile">
                    Đăng ký
                  </Link>
                </>
              ))}
            <button
              type="button"
              className="btn btn-ghost btn-icon menu-toggle"
              aria-controls="main-nav"
              aria-expanded={menuOpen}
              aria-label={menuOpen ? 'Đóng menu' : 'Mở menu'}
              onClick={() => setMenuOpen((v) => !v)}
            >
              {menuOpen ? <X size={24} aria-hidden="true" /> : <Menu size={24} aria-hidden="true" />}
            </button>
          </div>
        </div>
      </header>

      <main id="main">
        <Outlet />
      </main>

      <footer className="site-footer">
        <div className="container">
          <div className="footer-top">
            <div>
              <p className="footer-brand">
                Đi để <b>nhớ</b>,<br />
                về để kể lại.
              </p>
              <p style={{ maxWidth: '38ch' }}>
                TourDuLich tuyển chọn những hành trình trong nước và quốc tế, lịch trình rõ ràng từng ngày, giá minh bạch,
                đặt và thanh toán trực tuyến.
              </p>
            </div>
            <div>
              <h3>Khám phá</h3>
              <ul>
                <li><Link to="/tours">Tất cả tour</Link></li>
                <li><Link to="/tours?sort=departureAsc">Sắp khởi hành</Link></li>
                <li><Link to="/tours?sort=priceAsc">Giá tốt nhất</Link></li>
              </ul>
            </div>
            <div>
              <h3>Tài khoản</h3>
              <ul>
                <li><Link to="/cart">Phiếu đặt tạm</Link></li>
                <li><Link to="/my-bookings">Đơn đặt tour</Link></li>
                <li><Link to="/contact">Liên hệ tư vấn</Link></li>
              </ul>
            </div>
            <div>
              <h3>Văn phòng</h3>
              <ul>
                <li>12 Nguyễn Văn Bảo, Gò Vấp, TP.HCM</li>
                <li>Thứ 2 – Thứ 7, 8:00 – 18:00</li>
                <li><a href="tel:19001234">1900 1234</a></li>
              </ul>
            </div>
          </div>
          <div className="footer-bottom">
            <span>© {new Date().getFullYear()} TourDuLich</span>
            <span>Đề tài số 49 · Nhóm 22 · DHKTPM19B</span>
          </div>
        </div>
      </footer>
    </>
  )
}
