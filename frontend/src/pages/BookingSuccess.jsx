import { Link, useParams } from 'react-router-dom'
import { Check } from 'lucide-react'
import { bookingApi } from '../api'
import { useAsync } from '../hooks/useAsync'
import { fmtDate, money } from '../utils/format'

export default function BookingSuccess() {
  const { id } = useParams()
  const { data: b, loading, error } = useAsync(() => bookingApi.detail(id), [id])

  if (loading) return <div className="container page"><div className="skeleton" style={{ height: 260 }} /></div>
  if (error || !b) {
    return (
      <div className="container page">
        <div className="empty">
          <h3>Không tìm thấy đơn đặt tour</h3>
          <p>{error}</p>
          <Link to="/my-bookings" className="btn btn-primary">Xem đơn của tôi</Link>
        </div>
      </div>
    )
  }

  return (
    <div className="container page" style={{ maxWidth: 820 }}>
      <span className="success-mark">
        <Check size={32} aria-hidden="true" />
      </span>
      <span className="eyebrow">Đặt tour thành công</span>
      <h1 style={{ fontSize: 'clamp(2rem, 4vw, 3rem)' }}>Chỗ của bạn đã được giữ</h1>
      <p className="lead">
        Mã đơn <strong className="num">{b.bookingCode}</strong>. Chúng tôi đã gửi email xác nhận đến {b.contactEmail}.
        Hoàn tất thanh toán để đơn được duyệt nhanh hơn.
      </p>

      <div className="card" style={{ margin: 'var(--s6) 0' }}>
        {b.items.map((it) => (
          <div key={it.tourId} className="copy-row" style={{ borderTop: 0, alignItems: 'start' }}>
            <div>
              <strong>{it.tourName}</strong>
              <small>
                Khởi hành {fmtDate(it.departureDate)} · {it.adultQuantity} người lớn{it.childQuantity ? `, ${it.childQuantity} trẻ em` : ''}
              </small>
            </div>
            <span className="num">{money(it.subtotal)}</span>
          </div>
        ))}
        <div className="sum-row">
          <span>Tổng thanh toán</span>
          <strong>{money(b.totalAmount)}</strong>
        </div>
      </div>

      <div style={{ display: 'flex', gap: 'var(--s3)', flexWrap: 'wrap' }}>
        {b.paymentStatus === 'UNPAID' && b.bookingStatus !== 'CANCELLED' && (
          <Link to={`/payment/${b.id}`} className="btn btn-accent">Thanh toán chuyển khoản QR</Link>
        )}
        <Link to={`/my-bookings/${b.id}`} className="btn btn-outline">Xem chi tiết đơn</Link>
        <Link to="/tours" className="btn btn-ghost">Tiếp tục khám phá</Link>
      </div>
    </div>
  )
}
