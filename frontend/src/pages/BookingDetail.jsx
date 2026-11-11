import { useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { bookingApi } from '../api'
import { getErrorMessage } from '../api/client'
import { useAsync } from '../hooks/useAsync'
import { useToast } from '../components/Toast'
import StatusTag from '../components/StatusTag'
import { BOOKING_STATUS, PAYMENT_STATUS, fmtDate, fmtDateTime, money } from '../utils/format'

function CancelDialog({ open, busy, onClose, onSubmit }) {
  const [reason, setReason] = useState('')
  const [err, setErr] = useState('')
  if (!open) return null
  const submit = (e) => {
    e.preventDefault()
    if (reason.trim().length < 5) return setErr('Vui lòng nhập lý do hủy (ít nhất 5 ký tự)')
    onSubmit(reason.trim())
  }
  return (
    <div className="modal-backdrop" onClick={onClose}>
      <form className="modal" role="alertdialog" aria-modal="true" aria-labelledby="cancel-title" onClick={(e) => e.stopPropagation()} onSubmit={submit}>
        <h2 id="cancel-title" style={{ fontSize: '1.4rem' }}>Hủy đơn đặt tour</h2>
        <p>Bạn có chắc chắn muốn hủy đơn đặt tour này không? Hành động này không thể hoàn tác.</p>
        <div className="form-field">
          <label htmlFor="reason">Lý do hủy</label>
          <textarea id="reason" className="input" rows={3} maxLength={500} value={reason} aria-invalid={Boolean(err)} onChange={(e) => { setReason(e.target.value); setErr('') }} autoFocus />
          {err && <span className="field-error">{err}</span>}
        </div>
        <div className="modal__actions">
          <button type="button" className="btn btn-outline" onClick={onClose}>Giữ lại đơn</button>
          <button type="submit" className="btn btn-danger" disabled={busy}>
            {busy && <span className="spinner" aria-hidden="true" />} Xác nhận hủy
          </button>
        </div>
      </form>
    </div>
  )
}

export default function BookingDetail() {
  const { id } = useParams()
  const toast = useToast()
  const { data: b, loading, error, reload } = useAsync(() => bookingApi.detail(id), [id])
  const [cancelOpen, setCancelOpen] = useState(false)
  const [busy, setBusy] = useState(false)

  const cancel = async (reason) => {
    setBusy(true)
    try {
      await bookingApi.cancel(id, reason)
      toast.success('Đã hủy đơn đặt tour')
      setCancelOpen(false)
      reload()
    } catch (e) {
      toast.error(getErrorMessage(e, 'Không thể hủy đơn, vui lòng thử lại'))
    } finally {
      setBusy(false)
    }
  }

  if (loading) return <div className="container page"><div className="skeleton" style={{ height: 320 }} /></div>
  if (error || !b) {
    return (
      <div className="container page">
        <div className="empty">
          <h3>Không tìm thấy đơn đặt tour</h3>
          <p>{error}</p>
          <Link to="/my-bookings" className="btn btn-primary">Về danh sách đơn</Link>
        </div>
      </div>
    )
  }

  const unpaid = b.paymentStatus === 'UNPAID' && b.bookingStatus !== 'CANCELLED'

  return (
    <div className="container">
      <nav className="crumbs" aria-label="Đường dẫn">
        <Link to="/my-bookings">Đơn đặt tour</Link> / <span aria-current="page">{b.bookingCode}</span>
      </nav>
      <header className="page-head" style={{ paddingTop: 0 }}>
        <h1 className="num">{b.bookingCode}</h1>
        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
          <StatusTag map={BOOKING_STATUS} value={b.bookingStatus} />
          <StatusTag map={PAYMENT_STATUS} value={b.paymentStatus} />
          <span className="muted">Đặt lúc {fmtDateTime(b.createdAt)}</span>
        </div>
      </header>

      <div className="cart-layout">
        <div>
          <h2 style={{ fontSize: '1.5rem' }}>Hành trình</h2>
          {b.items.map((it) => (
            <article key={`${it.tourId}-${it.tourName}`} className="cart-item" style={{ gridTemplateColumns: '140px 1fr auto' }}>
              <Link to={`/tours/${it.tourId}`} className="cart-item__img">{it.imageUrl && <img src={it.imageUrl} alt="" />}</Link>
              <div>
                <h3><Link to={`/tours/${it.tourId}`}>{it.tourName}</Link></h3>
                <p className="cart-item__meta">Khởi hành {fmtDate(it.departureDate)}</p>
                <p style={{ margin: 0, fontSize: '0.92rem' }}>
                  {it.adultQuantity} người lớn × {money(it.adultPrice)}
                  {it.childQuantity > 0 && <><br />{it.childQuantity} trẻ em × {money(it.childPrice)}</>}
                </p>
              </div>
              <span className="price">{money(it.subtotal)}</span>
            </article>
          ))}

          <h2 style={{ fontSize: '1.5rem', marginTop: 'var(--s7)' }}>Thông tin liên hệ</h2>
          <dl className="kv">
            <dt>Họ tên</dt><dd>{b.contactName}</dd>
            <dt>Điện thoại</dt><dd>{b.contactPhone}</dd>
            <dt>Email</dt><dd>{b.contactEmail}</dd>
            {b.specialRequest && (<><dt>Yêu cầu đặc biệt</dt><dd>{b.specialRequest}</dd></>)}
            {b.paidAt && (<><dt>Thanh toán lúc</dt><dd>{fmtDateTime(b.paidAt)}</dd></>)}
            {b.cancelReason && (<><dt>Lý do hủy</dt><dd>{b.cancelReason}</dd></>)}
          </dl>
        </div>

        <aside className="summary" aria-label="Thanh toán và thao tác">
          <h2 style={{ fontSize: '1.4rem' }}>Thanh toán</h2>
          <div className="sum-row" style={{ borderTop: 0, marginTop: 0, paddingTop: 0 }}>
            <span>Tổng tiền</span>
            <strong>{money(b.totalAmount)}</strong>
          </div>
          <div className="form" style={{ gap: 'var(--s2)' }}>
            {unpaid && <Link to={`/payment/${b.id}`} className="btn btn-accent btn-block">Thanh toán chuyển khoản QR</Link>}
            {b.canCancel && (
              <button type="button" className="btn btn-outline btn-block" onClick={() => setCancelOpen(true)}>Hủy đơn</button>
            )}
          </div>
          {!b.canCancel && b.bookingStatus !== 'CANCELLED' && b.bookingStatus !== 'PENDING' && (
            <p className="field-hint" style={{ marginTop: 'var(--s3)' }}>
              Đơn đã được xác nhận nên không thể tự hủy trực tuyến. Vui lòng <Link to="/contact">liên hệ bộ phận hỗ trợ</Link>.
            </p>
          )}
        </aside>
      </div>

      <CancelDialog open={cancelOpen} busy={busy} onClose={() => setCancelOpen(false)} onSubmit={cancel} />
    </div>
  )
}
