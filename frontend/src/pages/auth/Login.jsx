import { useState } from 'react'
import { Link, Navigate, useLocation, useNavigate } from 'react-router-dom'
import { useAuth } from '../../context/AuthContext'
import { getErrorMessage } from '../../api/client'

export default function Login() {
  const { login, isAuthenticated, isAdmin } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()
  const from = location.state?.from
  const justRegistered = location.state?.registered

  const [form, setForm] = useState({ email: '', password: '' })
  const [error, setError] = useState('')
  const [submitting, setSubmitting] = useState(false)

  if (isAuthenticated) return <Navigate to={from || (isAdmin ? '/admin' : '/')} replace />

  const onChange = (e) => setForm((f) => ({ ...f, [e.target.name]: e.target.value }))

  const onSubmit = async (e) => {
    e.preventDefault()
    setError('')
    if (!form.email.trim() || !form.password) {
      setError('Vui lòng nhập đầy đủ Email và Mật khẩu')
      return
    }
    setSubmitting(true)
    try {
      const user = await login(form.email.trim(), form.password)
      // Admin về Dashboard, khách hàng về trang chủ; nếu bị chuyển từ trang khác (vd. Checkout) thì quay lại đó
      navigate(from || (user.role === 'ROLE_ADMIN' ? '/admin' : '/'), { replace: true })
    } catch (err) {
      setError(getErrorMessage(err, 'Đăng nhập thất bại, vui lòng thử lại sau!'))
      setSubmitting(false)
    }
  }

  return (
    <div className="split">
      <div className="split__art" style={{ backgroundImage: 'url(/img/hero/hero-2.jpg)' }} aria-hidden="true">
        <div>
          <blockquote>Chuyến đi hay nhất là chuyến bạn đã kịp đặt chỗ.</blockquote>
          <cite>TourDuLich · Lữ hành</cite>
        </div>
      </div>
      <div className="split__form">
        <div className="auth-card">
        <span className="eyebrow">Chào mừng trở lại</span>
        <h1>Đăng nhập</h1>
        {justRegistered && (
          <p className="alert alert-success" role="status">
            Đăng ký tài khoản thành công! Vui lòng đăng nhập.
          </p>
        )}
        {from && !justRegistered && <p className="field-hint">Vui lòng đăng nhập để tiếp tục.</p>}

        <form className="form" onSubmit={onSubmit} noValidate>
          {error && (
            <div className="alert alert-error" role="alert">
              {error}
            </div>
          )}
          <div className="form-field">
            <label htmlFor="email">Email</label>
            <input
              id="email"
              name="email"
              type="email"
              className="input"
              autoComplete="email"
              inputMode="email"
              value={form.email}
              onChange={onChange}
              aria-invalid={Boolean(error)}
              required
            />
          </div>
          <div className="form-field">
            <label htmlFor="password">Mật khẩu</label>
            <input
              id="password"
              name="password"
              type="password"
              className="input"
              autoComplete="current-password"
              value={form.password}
              onChange={onChange}
              aria-invalid={Boolean(error)}
              required
            />
          </div>
          <button type="submit" className="btn btn-primary btn-block" disabled={submitting}>
            {submitting && <span className="spinner" aria-hidden="true" />}
            {submitting ? 'Đang đăng nhập...' : 'Đăng nhập'}
          </button>
        </form>

        <p className="auth-switch">
          Chưa có tài khoản? <Link to="/register">Đăng ký ngay</Link>
        </p>
      </div>
    </div>
    </div>
  )
}
