import { useState } from 'react'
import { publicApi } from '../api'
import { getErrorMessage, getFieldErrors } from '../api/client'
import { useAuth } from '../context/AuthContext'

// Địa chỉ văn phòng dùng cho bản đồ Google Maps (nhúng không cần API key). Đổi ở đây nếu đổi địa chỉ.
const OFFICE_ADDRESS = '12 Nguyễn Văn Bảo, Phường 4, Gò Vấp, TP.HCM'
const MAP_QUERY = encodeURIComponent(OFFICE_ADDRESS)

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
const PHONE_RE = /^(0|\+84)[0-9]{9,10}$/

export default function Contact() {
  const { user } = useAuth()
  const [form, setForm] = useState({
    fullName: user?.fullName || '',
    email: user?.email || '',
    phone: user?.phone || '',
    subject: '',
    message: '',
  })
  const [errors, setErrors] = useState({})
  const [error, setError] = useState('')
  const [busy, setBusy] = useState(false)
  const [done, setDone] = useState(false)

  const onChange = (e) => {
    const { name, value } = e.target
    setForm((f) => ({ ...f, [name]: value }))
    if (errors[name]) setErrors((x) => ({ ...x, [name]: undefined }))
  }

  const onSubmit = async (ev) => {
    ev.preventDefault()
    setError('')
    const e = {}
    if (!form.fullName.trim()) e.fullName = 'Vui lòng nhập họ tên'
    if (!EMAIL_RE.test(form.email.trim())) e.email = 'Email không đúng định dạng'
    if (form.phone.trim() && !PHONE_RE.test(form.phone.replace(/\s/g, ''))) e.phone = 'Số điện thoại không hợp lệ'
    if (!form.subject.trim()) e.subject = 'Vui lòng nhập tiêu đề'
    if (form.message.trim().length < 10) e.message = 'Nội dung cần ít nhất 10 ký tự'
    setErrors(e)
    if (Object.keys(e).length) return
    setBusy(true)
    try {
      await publicApi.sendContact({ ...form, fullName: form.fullName.trim(), email: form.email.trim(), phone: form.phone.trim() || null })
      setDone(true)
    } catch (err) {
      setErrors(getFieldErrors(err))
      setError(getErrorMessage(err, 'Gửi liên hệ thất bại, vui lòng thử lại sau!'))
    } finally {
      setBusy(false)
    }
  }

  const f = (name, label, props = {}, required = true) => (
    <div className="form-field">
      <label htmlFor={name}>
        {label} {required && <span className="required" aria-hidden="true">*</span>}
      </label>
      {props.rows ? (
        <textarea id={name} name={name} className="input" value={form[name]} onChange={onChange} aria-invalid={Boolean(errors[name])} {...props} />
      ) : (
        <input id={name} name={name} className="input" value={form[name]} onChange={onChange} aria-invalid={Boolean(errors[name])} {...props} />
      )}
      {errors[name] && <span className="field-error" role="alert">{errors[name]}</span>}
    </div>
  )

  return (
    <div className="container">
      <header className="page-head">
        <h1>Nói cho chúng tôi biết bạn muốn đi đâu</h1>
        <p>Tư vấn viên phản hồi trong ngày làm việc. Cho biết ngân sách, số người và thời gian dự kiến để gợi ý được sát hơn.</p>
      </header>

      <div className="contact-layout">
        <div className="contact-side">
        <dl className="contact-info" style={{ margin: 0 }}>
          <div><dt>Văn phòng</dt><dd>12 Nguyễn Văn Bảo, P.4, Gò Vấp, TP.HCM</dd></div>
          <div><dt>Điện thoại</dt><dd><a href="tel:19001234" style={{ color: 'inherit', textDecoration: 'none' }}>1900 1234</a></dd></div>
          <div><dt>Email</dt><dd>hotro@tourdulich.local</dd></div>
          <div><dt>Giờ làm việc</dt><dd>Thứ 2 – Thứ 7, 8:00 – 18:00</dd></div>
        </dl>
        <div className="contact-map">
          <iframe
            title="Bản đồ vị trí văn phòng: 12 Nguyễn Văn Bảo, Gò Vấp, TP.HCM"
            src={`https://www.google.com/maps?q=${MAP_QUERY}&z=16&output=embed`}
            loading="lazy"
            referrerPolicy="no-referrer-when-downgrade"
            allowFullScreen
          />
          <a
            className="link-arrow"
            href={`https://www.google.com/maps/search/?api=1&query=${MAP_QUERY}`}
            target="_blank"
            rel="noopener noreferrer"
          >
            Mở bản đồ lớn hơn
          </a>
        </div>
        </div>

        {done ? (
          <div className="card" role="status">
            <h2>Đã nhận yêu cầu của bạn</h2>
            <p className="muted">Cảm ơn {form.fullName}. Chúng tôi sẽ phản hồi qua email {form.email} sớm nhất có thể.</p>
            <button type="button" className="btn btn-outline" onClick={() => { setDone(false); setForm((x) => ({ ...x, subject: '', message: '' })) }}>
              Gửi yêu cầu khác
            </button>
          </div>
        ) : (
          <form className="form" onSubmit={onSubmit} noValidate>
            {error && <div className="alert alert-error" role="alert">{error}</div>}
            <div className="form-row">
              {f('fullName', 'Họ và tên', { autoComplete: 'name', maxLength: 100 })}
              {f('email', 'Email', { type: 'email', autoComplete: 'email', maxLength: 150 })}
            </div>
            <div className="form-row">
              {f('phone', 'Số điện thoại', { type: 'tel', autoComplete: 'tel', maxLength: 15 }, false)}
              {f('subject', 'Tiêu đề', { maxLength: 200, placeholder: 'Ví dụ: Tư vấn tour Nhật Bản tháng 4' })}
            </div>
            {f('message', 'Nội dung', { rows: 6, maxLength: 2000 })}
            <div>
              <button type="submit" className="btn btn-primary" disabled={busy}>
                {busy && <span className="spinner" aria-hidden="true" />} {busy ? 'Đang gửi…' : 'Gửi yêu cầu'}
              </button>
            </div>
          </form>
        )}
      </div>
    </div>
  )
}
