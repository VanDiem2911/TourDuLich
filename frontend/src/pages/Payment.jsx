import { useEffect, useRef, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { Check, Copy } from 'lucide-react'
import { bookingApi } from '../api'
import { getErrorMessage } from '../api/client'
import { useToast } from '../components/Toast'
import { fmtDateTime, money } from '../utils/format'

function CopyRow({ label, value, copy }) {
  const toast = useToast()
  const onCopy = async () => {
    try {
      await navigator.clipboard.writeText(String(copy ?? value))
      toast.success(`Đã sao chép ${label.toLowerCase()}`)
    } catch {
      toast.error('Trình duyệt không cho phép sao chép')
    }
  }
  return (
    <div className="copy-row">
      <div>
        <small>{label}</small>
        <strong>{value}</strong>
      </div>
      <button type="button" className="btn btn-ghost btn-sm" onClick={onCopy} aria-label={`Sao chép ${label}`}>
        <Copy size={15} aria-hidden="true" /> Chép
      </button>
    </div>
  )
}

export default function Payment() {
  const { id } = useParams()
  const toast = useToast()
  const [info, setInfo] = useState(null)
  const [error, setError] = useState('')
  const [busy, setBusy] = useState(false)
  const timer = useRef(null)

  const load = async () => {
    try {
      const d = await bookingApi.paymentInfo(id)
      setInfo(d)
      setError('')
      return d
    } catch (e) {
      setError(getErrorMessage(e, 'Không tải được thông tin thanh toán'))
      return null
    }
  }

  // Hỏi lại trạng thái mỗi 5 giây cho đến khi đơn được ghi nhận đã thanh toán
  useEffect(() => {
    let stop = false
    const tick = async () => {
      const d = await load()
      if (!stop && d && d.paymentStatus === 'UNPAID' && d.bookingStatus !== 'CANCELLED') {
        timer.current = setTimeout(tick, 5000)
      }
    }
    tick()
    return () => {
      stop = true
      clearTimeout(timer.current)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id])

  const simulate = async () => {
    setBusy(true)
    try {
      await bookingApi.simulatePay(Number(id))
      await load()
      toast.success('Đã ghi nhận thanh toán (chế độ demo)')
    } catch (e) {
      toast.error(getErrorMessage(e))
    } finally {
      setBusy(false)
    }
  }

  if (error && !info) {
    return (
      <div className="container page">
        <div className="empty">
          <h3>Không thể thanh toán đơn này</h3>
          <p>{error}</p>
          <Link to="/my-bookings" className="btn btn-primary">Về đơn của tôi</Link>
        </div>
      </div>
    )
  }
  if (!info) return <div className="container page"><div className="skeleton" style={{ height: 320 }} /></div>

  const paid = info.paymentStatus === 'PAID'
  const cancelled = info.bookingStatus === 'CANCELLED'

  return (
    <div className="container">
      <header className="page-head">
        <span className="eyebrow">Đơn {info.bookingCode}</span>
        <h1>{paid ? 'Đã nhận thanh toán' : 'Thanh toán chuyển khoản'}</h1>
        <p>
          {paid
            ? `Chúng tôi đã nhận ${money(info.amount)}${info.paidAt ? ` lúc ${fmtDateTime(info.paidAt)}` : ''}. Cảm ơn bạn!`
            : 'Quét mã bằng ứng dụng ngân hàng. Số tiền và nội dung chuyển khoản đã được điền sẵn, vui lòng không sửa nội dung.'}
        </p>
      </header>

      {cancelled ? (
        <div className="alert alert-error">Đơn này đã bị hủy nên không thể thanh toán.</div>
      ) : paid ? (
        <div className="card" style={{ maxWidth: 560 }}>
          <span className="success-mark"><Check size={30} aria-hidden="true" /></span>
          <h2>Thanh toán thành công</h2>
          <p className="muted">Đơn đang chờ nhân viên xác nhận. Bạn sẽ nhận email khi đơn được duyệt.</p>
          <Link to={`/my-bookings/${info.bookingId}`} className="btn btn-primary">Xem chi tiết đơn</Link>
        </div>
      ) : (
        <div className="pay-layout">
          <div className="qr-frame">
            <img src={info.qrUrl} alt={`Mã QR chuyển khoản ${money(info.amount)} nội dung ${info.transferContent}`} />
            <p className="field-hint" style={{ margin: 'var(--s2) 0 0' }}>Hỗ trợ mọi ứng dụng ngân hàng tại Việt Nam</p>
          </div>
          <div>
            <CopyRow label="Ngân hàng" value={info.bankName} />
            <CopyRow label="Số tài khoản" value={info.accountNumber} />
            <CopyRow label="Chủ tài khoản" value={info.accountName} />
            <CopyRow label="Số tiền" value={money(info.amount)} copy={info.amount} />
            <CopyRow label="Nội dung chuyển khoản" value={info.transferContent} />
            <div className="alert alert-info" style={{ marginTop: 'var(--s4)' }} role="status">
              <span className="spinner" style={{ display: 'inline-block', verticalAlign: 'middle', marginRight: 8 }} aria-hidden="true" />
              Đang chờ ghi nhận giao dịch, trang sẽ tự cập nhật khi tiền về.
            </div>
            {info.simulateEnabled && (
              <div className="card" style={{ marginTop: 'var(--s5)', borderStyle: 'dashed' }}>
                <h3 style={{ fontSize: '1rem' }}>Chế độ demo</h3>
                <p className="muted" style={{ fontSize: '0.9rem' }}>
                  Đang chạy môi trường thử nghiệm. Bấm nút dưới để giả lập ngân hàng báo đã nhận tiền.
                </p>
                <button type="button" className="btn btn-outline btn-sm" onClick={simulate} disabled={busy}>
                  {busy && <span className="spinner" aria-hidden="true" />} Giả lập đã chuyển khoản
                </button>
              </div>
            )}
            <p style={{ marginTop: 'var(--s5)' }}>
              <Link to={`/my-bookings/${info.bookingId}`}>Thanh toán sau, xem chi tiết đơn</Link>
            </p>
          </div>
        </div>
      )}
    </div>
  )
}
