import { useState } from 'react'
import { Link, Navigate, useNavigate } from 'react-router-dom'
import { authApi } from '../../api/auth'
import { getErrorMessage, getFieldErrors } from '../../api/client'
import { useAuth } from '../../context/AuthContext'
import { track } from '../../tracking/tracker'

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
const PHONE_RE = /^0\d{9}$/

/** Kiểm tra phía client; Backend vẫn kiểm tra lại toàn bộ. */
function validate(f) {
  const e = {}
  if (!f.fullName.trim()) e.fullName = 'Vui lòng nhập họ tên'
  if (!f.email.trim()) e.email = 'Vui lòng nhập email'
  else if (!EMAIL_RE.test(f.email.trim())) e.email = 'Email không đúng định dạng'
  if (f.phone.trim() && !PHONE_RE.test(f.phone.trim())) e.phone = 'Số điện thoại phải gồm 10 chữ số, bắt đầu bằng 0'
  if (!f.password) e.password = 'Vui lòng nhập mật khẩu'
  else if (f.password.length < 6) e.password = 'Mật khẩu phải có ít nhất 6 ký tự'
  if (!f.confirmPassword) e.confirmPassword = 'Vui lòng xác nhận mật khẩu'
  else if (f.confirmPassword !== f.password) e.confirmPassword = 'Xác nhận mật khẩu không khớp'
  return e
}

function Field({ id, label, required, hint, error, children }) {
  return (
    <div className="form-field">
      <label htmlFor={id}>
        {label} {required && <span className="required" aria-hidden="true">*</span>}
      </label>
      {children}
      {hint && !error && <span className="field-hint">{hint}</span>}
      {error && (
        <span id={`${id}-error`} className="field-error" role="alert">
          {error}
        </span>
      )}
    </div>
  )
}

export default function Register() {
  const { isAuthenticated } = useAuth()
  const navigate = useNavigate()
  const [form, setForm] = useState({ fullName: '', email: '', phone: '', address: '', password: '', confirmPassword: '' })
  const [errors, setErrors] = useState({})
  const [formError, setFormError] = useState('')
  const [submitting, setSubmitting] = useState(false)

  if (isAuthenticated) return <Navigate to="/" replace />

  const onChange = (e) => {
    const { name, value } = e.target
    setForm((f) => ({ ...f, [name]: value }))
    if (errors[name]) setErrors((er) => ({ ...er, [name]: undefined }))
  }

  const inputProps = (name, extra = {}) => ({
    id: name,
    name,
    className: 'input',
    value: form[name],
    onChange,
    'aria-invalid': Boolean(errors[name]),
    'aria-describedby': errors[name] ? `${name}-error` : undefined,
    ...extra,
  })

  const onSubmit = async (e) => {
    e.preventDefault()
    setFormError('')
    const clientErrors = validate(form)
    setErrors(clientErrors)
    if (Object.keys(clientErrors).length) return

    setSubmitting(true)
    try {
      await authApi.register({ ...form, fullName: form.fullName.trim(), email: form.email.trim() })
      track('register')
      navigate('/login', { replace: true, state: { registered: true } })
    } catch (err) {
      setErrors(getFieldErrors(err))
      setFormError(getErrorMessage(err, 'Đăng ký tài khoản thất bại, vui lòng thử lại sau!'))
      setSubmitting(false)
    }
  }

  return (
    <div className="split">
      <div className="split__art" style={{ backgroundImage: 'url(/img/hero/hero-3.jpg)' }} aria-hidden="true">
        <div>
          <blockquote>Một tài khoản, mọi hành trình bạn từng đặt đều ở một chỗ.</blockquote>
          <cite>TourDuLich · Lữ hành</cite>
        </div>
      </div>
      <div className="split__form">
        <div className="auth-card">
        <h1>Tạo tài khoản</h1>
        <form className="form" onSubmit={onSubmit} noValidate>
          {formError && (
            <div className="alert alert-error" role="alert">
              {formError}
            </div>
          )}
          <Field id="fullName" label="Họ và tên" required error={errors.fullName}>
            <input {...inputProps('fullName', { autoComplete: 'name', maxLength: 100 })} />
          </Field>
          <Field id="email" label="Email" required error={errors.email}>
            <input {...inputProps('email', { type: 'email', autoComplete: 'email', inputMode: 'email', maxLength: 150 })} />
          </Field>
          <Field id="phone" label="Số điện thoại" error={errors.phone}>
            <input {...inputProps('phone', { type: 'tel', autoComplete: 'tel', inputMode: 'numeric', maxLength: 10 })} />
          </Field>
          <Field id="address" label="Địa chỉ" error={errors.address}>
            <input {...inputProps('address', { autoComplete: 'street-address', maxLength: 255 })} />
          </Field>
          <Field id="password" label="Mật khẩu" required hint="Tối thiểu 6 ký tự" error={errors.password}>
            <input {...inputProps('password', { type: 'password', autoComplete: 'new-password', maxLength: 72 })} />
          </Field>
          <Field id="confirmPassword" label="Xác nhận mật khẩu" required error={errors.confirmPassword}>
            <input {...inputProps('confirmPassword', { type: 'password', autoComplete: 'new-password', maxLength: 72 })} />
          </Field>
          <button type="submit" className="btn btn-primary btn-block" disabled={submitting}>
            {submitting && <span className="spinner" aria-hidden="true" />}
            {submitting ? 'Đang xử lý...' : 'Đăng ký'}
          </button>
        </form>
        <p className="auth-switch">
          Đã có tài khoản? <Link to="/login">Đăng nhập</Link>
        </p>
      </div>
    </div>
    </div>
  )
}
