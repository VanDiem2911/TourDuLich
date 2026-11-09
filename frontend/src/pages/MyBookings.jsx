import { useState } from 'react'
import { Link } from 'react-router-dom'
import { bookingApi } from '../api'
import { useAsync } from '../hooks/useAsync'
import Pagination from '../components/Pagination'
import StatusTag from '../components/StatusTag'
import { BOOKING_STATUS, PAYMENT_STATUS, fmtDateTime, money } from '../utils/format'

const TABS = [
  { v: '', t: 'Tất cả' },
  { v: 'PENDING', t: 'Chờ xác nhận' },
  { v: 'CONFIRMED', t: 'Đã xác nhận' },
  { v: 'COMPLETED', t: 'Hoàn tất' },
  { v: 'CANCELLED', t: 'Đã hủy' },
]

export default function MyBookings() {
  const [status, setStatus] = useState('')
  const [page, setPage] = useState(1)
  const { data, loading, error, reload } = useAsync(() => bookingApi.mine({ page, size: 6, status }), [page, status])
  const rows = data?.content || []

  return (
    <div className="container">
      <header className="page-head">
        <span className="eyebrow">Tài khoản</span>
        <h1>Đơn đặt tour của tôi</h1>
        <p>Theo dõi trạng thái, thanh toán và hủy đơn khi còn chờ xác nhận.</p>
      </header>

      <div className="tabs" role="tablist" aria-label="Lọc theo trạng thái">
        {TABS.map((t) => (
          <button
            key={t.v}
            type="button"
            role="tab"
            aria-selected={status === t.v}
            className={status === t.v ? 'is-on' : ''}
            onClick={() => {
              setStatus(t.v)
              setPage(1)
            }}
          >
            {t.t}
          </button>
        ))}
      </div>

      {error ? (
        <div className="empty">
          <h3>Không tải được danh sách đơn</h3>
          <p>{error}</p>
          <button type="button" className="btn btn-primary" onClick={reload}>Thử lại</button>
        </div>
      ) : loading ? (
        <div className="skeleton" style={{ height: 280 }} />
      ) : rows.length === 0 ? (
        <div className="empty">
          <h3>{status ? 'Không có đơn nào ở trạng thái này' : 'Bạn chưa đặt tour nào'}</h3>
          <p>Khi đặt tour, đơn sẽ xuất hiện ở đây.</p>
          <Link to="/tours" className="btn btn-primary">Khám phá tour</Link>
        </div>
      ) : (
        <div>
          {rows.map((b) => (
            <article key={b.id} className="order-row">
              <div className="order-row__img">{b.firstTourImage && <img src={b.firstTourImage} alt="" loading="lazy" />}</div>
              <div>
                <h3>
                  <Link to={`/my-bookings/${b.id}`} style={{ color: 'var(--ink)', textDecoration: 'none' }}>
                    {b.firstTourName}
                    {b.itemCount > 1 ? ` và ${b.itemCount - 1} tour khác` : ''}
                  </Link>
                </h3>
                <div className="order-row__meta">
                  <span className="num">{b.bookingCode}</span>
                  <span>Đặt lúc {fmtDateTime(b.createdAt)}</span>
                </div>
                <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginTop: 10 }}>
                  <StatusTag map={BOOKING_STATUS} value={b.bookingStatus} />
                  <StatusTag map={PAYMENT_STATUS} value={b.paymentStatus} />
                </div>
              </div>
              <div className="order-row__side">
                <span className="price">{money(b.totalAmount)}</span>
                <div style={{ display: 'flex', gap: 8 }}>
                  {b.paymentStatus === 'UNPAID' && b.bookingStatus !== 'CANCELLED' && (
                    <Link to={`/payment/${b.id}`} className="btn btn-accent btn-sm">Thanh toán</Link>
                  )}
                  <Link to={`/my-bookings/${b.id}`} className="btn btn-outline btn-sm">Chi tiết</Link>
                </div>
              </div>
            </article>
          ))}
        </div>
      )}
      <Pagination page={data?.page || page} totalPages={data?.totalPages} onChange={setPage} />
    </div>
  )
}
