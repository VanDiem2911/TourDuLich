import { useState } from 'react'
import { accountApi } from '../api'
import { getErrorMessage, getFieldErrors } from '../api/client'
import { useAuth } from '../context/AuthContext'
import { useToast } from '../components/Toast'

export default function Account() {
  const { user, refreshUser } = useAuth()
  const toast = useToast()
  const [profile, setProfile] = useState({ fullName: user.fullName || '', phone: user.phone || '', address: user.address || '' })
  const [pw, setPw] = useState({ currentPassword: '', newPassword: '', confirm: '' })
  const [pErr, setPErr] = useState({})
  const [wErr, setWErr] = useState({})
  const [busy, setBusy] = useState('')

  const saveProfile = async (e) => {
    e.preventDefault()
    const er = {}
    if (!profile.fullName.trim()) er.fullName = 'Vui lòng nhập họ tên'
    if (profile.phone.trim() && !/^0\d{9}$/.test(profile.phone.trim())) er.phone = 'Số điện thoại phải gồm 10 chữ số, bắt đầu bằng 0'
    setPErr(er)
    if (Object.keys(er).length) return
    setBusy('profile')
    try {
      await accountApi.update({ fullName: profile.fullName.trim(), phone: profile.phone.trim() || null, address: profile.address.trim() || null })
      await refreshUser()
      toast.success('Đã cập nhật thông tin')
    } catch (err) {
      setPErr(getFieldErrors(err))
      toast.error(getErrorMessage(err))
    } finally {
      setBusy('')
    }
  }

  const savePw = async (e) => {
    e.preventDefault()
    const er = {}
    if (!pw.currentPassword) er.currentPassword = 'Vui lòng nhập mật khẩu hiện tại'
    if (pw.newPassword.length < 6) er.newPassword = 'Mật khẩu mới phải có ít nhất 6 ký tự'
    if (pw.confirm !== pw.newPassword) er.confirm = 'Xác nhận mật khẩu không khớp'
    setWErr(er)
    if (Object.keys(er).length) return
    setBusy('pw')
    try {
      await accountApi.changePassword({ currentPassword: pw.currentPassword, newPassword: pw.newPassword })
      setPw({ currentPassword: '', newPassword: '', confirm: '' })
      toast.success('Đã đổi mật khẩu')
    } catch (err) {
      setWErr(getFieldErrors(err))
      toast.error(getErrorMessage(err))
    } finally {
      setBusy('')
    }
  }

  return (
    <div className="container">
      <header className="page-head">
        <span className="eyebrow">Tài khoản</span>
        <h1>Thông tin của bạn</h1>
        <p>{user.email}</p>
      </header>

      <div className="contact-layout" style={{ gridTemplateColumns: '1fr 1fr' }}>
        <form className="form" onSubmit={saveProfile} noValidate>
          <h2 style={{ fontSize: '1.5rem', marginBottom: 0 }}>Hồ sơ</h2>
          <div className="form-field">
            <label htmlFor="fullName">Họ và tên</label>
            <input id="fullName" className="input" value={profile.fullName} maxLength={100} aria-invalid={Boolean(pErr.fullName)} onChange={(e) => setProfile({ ...profile, fullName: e.target.value })} />
            {pErr.fullName && <span className="field-error">{pErr.fullName}</span>}
          </div>
          <div className="form-field">
            <label htmlFor="phone">Số điện thoại</label>
            <input id="phone" className="input" type="tel" value={profile.phone} maxLength={10} aria-invalid={Boolean(pErr.phone)} onChange={(e) => setProfile({ ...profile, phone: e.target.value })} />
            {pErr.phone && <span className="field-error">{pErr.phone}</span>}
          </div>
          <div className="form-field">
            <label htmlFor="address">Địa chỉ</label>
            <input id="address" className="input" value={profile.address} maxLength={255} onChange={(e) => setProfile({ ...profile, address: e.target.value })} />
          </div>
          <div>
            <button type="submit" className="btn btn-primary" disabled={busy === 'profile'}>
              {busy === 'profile' && <span className="spinner" aria-hidden="true" />} Lưu thay đổi
            </button>
          </div>
        </form>

        <form className="form" onSubmit={savePw} noValidate>
          <h2 style={{ fontSize: '1.5rem', marginBottom: 0 }}>Đổi mật khẩu</h2>
          {[
            ['currentPassword', 'Mật khẩu hiện tại', 'current-password'],
            ['newPassword', 'Mật khẩu mới', 'new-password'],
            ['confirm', 'Nhập lại mật khẩu mới', 'new-password'],
          ].map(([k, label, ac]) => (
            <div className="form-field" key={k}>
              <label htmlFor={k}>{label}</label>
              <input id={k} className="input" type="password" autoComplete={ac} maxLength={72} value={pw[k]} aria-invalid={Boolean(wErr[k])} onChange={(e) => setPw({ ...pw, [k]: e.target.value })} />
              {wErr[k] && <span className="field-error">{wErr[k]}</span>}
            </div>
          ))}
          <div>
            <button type="submit" className="btn btn-outline" disabled={busy === 'pw'}>
              {busy === 'pw' && <span className="spinner" aria-hidden="true" />} Đổi mật khẩu
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
