import { Navigate, Outlet, useLocation } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

function FullPageSpinner() {
  return (
    <div style={{ display: 'grid', placeItems: 'center', minHeight: '50vh' }} role="status" aria-live="polite">
      <span className="spinner" aria-hidden="true" />
      <span className="visually-hidden">Đang tải...</span>
    </div>
  )
}

/** Yêu cầu đã đăng nhập; chưa thì chuyển sang /login và nhớ URL để quay lại (vd. trang Checkout). */
export function RequireAuth() {
  const { isAuthenticated, loading } = useAuth()
  const location = useLocation()
  if (loading) return <FullPageSpinner />
  if (!isAuthenticated) return <Navigate to="/login" replace state={{ from: location.pathname + location.search }} />
  return <Outlet />
}

/** Yêu cầu ROLE_ADMIN; không đủ quyền thì về trang chủ. */
export function RequireAdmin() {
  const { isAuthenticated, isAdmin, loading } = useAuth()
  const location = useLocation()
  if (loading) return <FullPageSpinner />
  if (!isAuthenticated) return <Navigate to="/login" replace state={{ from: location.pathname }} />
  if (!isAdmin) return <Navigate to="/" replace />
  return <Outlet />
}
