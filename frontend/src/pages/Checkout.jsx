import { useEffect, useState } from 'react'
import { Link, Navigate, useNavigate } from 'react-router-dom'
import { bookingApi } from '../api'
import { getErrorMessage, getFieldErrors } from '../api/client'
import { useAuth } from '../context/AuthContext'
import { useCart } from '../context/CartContext'
import { fmtDate, money } from '../utils/format'
import { track } from '../tracking/tracker'

const PHONE_RE = /^(0|\+84)[0-9]{9,10}$/
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

export default function Checkout() {
  const { user } = useAuth()
  const { cart, loading, refresh } = useCart()
  const navigate = useNavigate()
  useEffect(() => {
    track('begin_checkout')
  }, [])
  const [form, setForm] = useState({
    contactName: user?.fullName || '',
    contactPhone: user?.phone || '',
    contactEmail: user?.email || '',
    specialRequest: '',
  })
  const [errors, setErrors] = useState({})
  const [error, setError] = useState('')
  const [busy, setBusy] = useState(false)

  if (loading) return <div className="container page"><div className="skeleton" style={{ height: 240 }} /></div>
  if (cart.items.length === 0) return <Navigate to="/cart" replace />

  const onChange = (e) => setForm((f) => ({ ...f, [e.target.name]: e.target.value }))

  const validate = () => {
    const e = {}
    if (!form.contactName.trim()) e.contactName = 'Vui lòng nhập họ tên người liên hệ'
    if (!PHONE_RE.test(form.contactPhone.replace(/\s/g, ''))) e.contactPhone = 'Số điện thoại không hợp lệ (ví dụ 0901234567)'
    if (!EMAIL_RE.test(form.contactEmail.trim())) e.contactEmail = 'Email không đúng định dạng'
    return e
  }

  const onSubmit = async (ev) => {
    ev.preventDefault()
    setError('')
    const e = validate()
    setErrors(e)
    if (Object.keys(e).length) return
    setBusy(true)
    try {
      const booking = await bookingApi.create({
        contactName: form.contactName.trim(),
        contactPhone: form.contactPhone.replace(/\s/g, ''),
        contactEmail: form.contactEmail.trim(),
        specialRequest: form.specialRequest.trim() || null,
      })
      await refresh()
      navigate(`/booking-success/${booking.id}`, { replace: true })
    } catch (err) {
      setErrors(getFieldErrors(err))
      setError(getErrorMessage(err, 'Đặt tour thất bại, vui lòng thử lại!'))
      refresh()
      setBusy(false)
    }
  }

  const field = (name, label, props = {}) => (
    <div className="form-field">
      <label htmlFor={name}>
        {label} {props.required !== false && <span className="required" aria-hidden="true">*</span>}
      </label>
      <input id={name} name={name} className="input" value={form[name]} onChange={onChange} aria-invalid={Boolean(errors[name])} aria-describedby={errors[name] ? `${name}-err` : undefined} {...props} />
      {errors[name] && <span id={`${name}-err`} className="field-error">{errors[name]}</span>}
    </div>
  )

  return (
    <div className="container">
      <header className="page-head">
        <h1>Xác nhận đặt tour</h1>
        <p>Điền thông tin người liên hệ. Sau khi xác nhận, chỗ sẽ được giữ và bạn có thể thanh toán ngay.</p>
      </header>

      <div className="cart-layout">
        <form className="form" onSubmit={onSubmit} noValidate>
          {error && <div className="alert alert-error" role="alert">{error}</div>}
          <h2 style={{ fontSize: '1.5rem', marginBottom: 0 }}>Người liên hệ</h2>
          {field('contactName', 'Họ và tên', { autoComplete: 'name', maxLength: 100 })}
          <div className="form-row">
            {field('contactPhone', 'Số điện thoại', { type: 'tel', inputMode: 'tel', autoComplete: 'tel', maxLength: 15 })}
            {field('contactEmail', 'Email nhận xác nhận', { type: 'email', autoComplete: 'email', maxLength: 150 })}
          </div>
          <div className="form-field">
            <label htmlFor="specialRequest">Yêu cầu đặc biệt (không bắt buộc)</label>
            <textarea id="specialRequest" name="specialRequest" className="input" rows={4} maxLength={1000} value={form.specialRequest} onChange={onChange} placeholder="Ăn chay, phòng gần nhau, đón tại nhà…" />
          </div>
          <div style={{ display: 'flex', gap: 'var(--s3)', flexWrap: 'wrap' }}>
            <button type="submit" className="btn btn-accent" disabled={busy}>
              {busy && <span className="spinner" aria-hidden="true" />} {busy ? 'Đang giữ chỗ…' : 'Xác nhận đặt tour'}
            </button>
            <Link to="/cart" className="btn btn-outline">Quay lại phiếu</Link>
          </div>
        </form>

        <aside className="summary" aria-label="Tóm tắt đơn">
          <h2 style={{ fontSize: '1.4rem' }}>Tóm tắt</h2>
          {cart.items.map((it) => (
            <div key={it.tourId} className="copy-row" style={{ alignItems: 'start' }}>
              <div>
                <strong>{it.name}</strong>
                <small>
                  {fmtDate(it.departureDate)} · {it.adultQuantity} người lớn{it.childQuantity ? `, ${it.childQuantity} trẻ em` : ''}
                </small>
              </div>
              <span className="num">{money(it.subtotal)}</span>
            </div>
          ))}
          <div className="sum-row">
            <span>Tổng thanh toán</span>
            <strong>{money(cart.totalAmount)}</strong>
          </div>
        </aside>
      </div>
    </div>
  )
}
