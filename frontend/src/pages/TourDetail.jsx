import { useState } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'
import { Minus, Plus } from 'lucide-react'
import { publicApi } from '../api'
import { getErrorMessage } from '../api/client'
import { useAsync } from '../hooks/useAsync'
import { useCart } from '../context/CartContext'
import { useToast } from '../components/Toast'
import TourCard from '../components/TourCard'
import { fmtDateLong, money, parseItinerary } from '../utils/format'

function Stepper({ label, value, min, max, onChange }) {
  return (
    <div className="stepper" role="group" aria-label={label}>
      <button type="button" onClick={() => onChange(value - 1)} disabled={value <= min} aria-label={`Giảm ${label}`}>
        <Minus size={16} aria-hidden="true" />
      </button>
      <output aria-live="polite">{value}</output>
      <button type="button" onClick={() => onChange(value + 1)} disabled={value >= max} aria-label={`Tăng ${label}`}>
        <Plus size={16} aria-hidden="true" />
      </button>
    </div>
  )
}

export default function TourDetail() {
  const { id } = useParams()
  const navigate = useNavigate()
  const toast = useToast()
  const { add } = useCart()
  const { data: tour, loading, error } = useAsync(() => publicApi.tour(id), [id])
  const [adults, setAdults] = useState(1)
  const [children, setChildren] = useState(0)
  const [busy, setBusy] = useState(false)

  if (loading) {
    return (
      <div className="container page">
        <div className="skeleton" style={{ aspectRatio: '21/9', marginBottom: 24 }} />
        <div className="skeleton" style={{ height: 120 }} />
      </div>
    )
  }
  if (error || !tour) {
    return (
      <div className="container page">
        <div className="empty">
          <h3>Không tìm thấy tour này</h3>
          <p>{error || 'Tour không tồn tại hoặc đã ngừng mở bán.'}</p>
          <Link to="/tours" className="btn btn-primary">
            Xem các tour khác
          </Link>
        </div>
      </div>
    )
  }

  const seats = tour.availableSeats
  const total = adults * tour.adultPrice + children * (tour.childPrice ?? tour.adultPrice)
  const soldOut = seats <= 0
  const days = parseItinerary(tour.itinerary)
  const maxAdults = Math.max(1, seats - children)
  const maxChildren = Math.max(0, seats - adults)

  const submit = async (goCart) => {
    setBusy(true)
    try {
      await add({ tourId: tour.id, adultQuantity: adults, childQuantity: children })
      if (goCart) navigate('/cart')
      else toast.success('Đã thêm vào phiếu đặt tạm')
    } catch (e) {
      toast.error(getErrorMessage(e, 'Không thể thêm tour vào phiếu đặt tạm'))
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className="container">
      <nav className="crumbs" aria-label="Đường dẫn">
        <Link to="/">Trang chủ</Link> / <Link to="/tours">Tour</Link> /{' '}
        <Link to={`/tours?categoryId=${tour.categoryId}`}>{tour.categoryName}</Link> / <span aria-current="page">{tour.tourCode}</span>
      </nav>

      <div className="detail-hero">
        <div>
          <span className="eyebrow">
            {tour.categoryName} · {tour.tourCode}
          </span>
          <h1 className="detail-title" style={{ marginTop: 8 }}>
            {tour.name}
          </h1>
        </div>
        <div className="detail-hero__img">
          <img src={tour.imageUrl} alt={tour.name} />
        </div>
      </div>

      <div className="detail-layout">
        <div>
          <dl className="facts" style={{ marginTop: 0 }}>
            <div className="fact"><dt>Thời gian</dt><dd>{tour.duration}</dd></div>
            <div className="fact"><dt>Phương tiện</dt><dd>{tour.transport}</dd></div>
            <div className="fact"><dt>Xuất phát</dt><dd>{tour.departureLocation}</dd></div>
            <div className="fact"><dt>Điểm đến</dt><dd>{tour.destination}</dd></div>
          </dl>

          {tour.shortDescription && <p className="lead" style={{ marginBottom: 'var(--s6)' }}>{tour.shortDescription}</p>}

          <div className="section-head" style={{ marginBottom: 0, borderBottom: 0 }}>
            <h2 style={{ fontSize: '1.9rem' }}>Lịch trình</h2>
          </div>
          {days.length ? (
            <ol className="timeline">
              {days.map((d) => (
                <li key={d.day}>
                  <div className="timeline__day">
                    Ngày
                    <b>{String(d.day).padStart(2, '0')}</b>
                  </div>
                  <div>
                    <h3>{d.title}</h3>
                    {d.body && <p>{d.body}</p>}
                  </div>
                </li>
              ))}
            </ol>
          ) : (
            <p className="muted">Lịch trình chi tiết đang được cập nhật.</p>
          )}
        </div>

        <aside className="booking-box" aria-label="Đặt tour">
          <div className="price">
            <small>từ</small>
            {money(tour.adultPrice)}
          </div>
          <p className="muted" style={{ fontSize: '0.86rem', marginBottom: 'var(--s3)' }}>mỗi người lớn</p>

          <div className="qty-row">
            <span>Khởi hành<small>{fmtDateLong(tour.departureDate)}</small></span>
          </div>
          <div className="qty-row">
            <span>Chỗ còn lại<small>{soldOut ? 'Đã hết chỗ' : `${seats} / ${tour.totalSeats} chỗ`}</small></span>
          </div>

          {!soldOut && (
            <>
              <div className="qty-row">
                <span>Người lớn<small>{money(tour.adultPrice)}</small></span>
                <Stepper label="người lớn" value={adults} min={1} max={maxAdults} onChange={setAdults} />
              </div>
              <div className="qty-row">
                <span>Trẻ em<small>{money(tour.childPrice ?? tour.adultPrice)}</small></span>
                <Stepper label="trẻ em" value={children} min={0} max={maxChildren} onChange={setChildren} />
              </div>
              <div className="sum-row">
                <span>Tạm tính</span>
                <strong>{money(total)}</strong>
              </div>
              <div className="form" style={{ gap: 'var(--s2)' }}>
                <button type="button" className="btn btn-accent btn-block" disabled={busy} onClick={() => submit(true)}>
                  {busy && <span className="spinner" aria-hidden="true" />} Đặt tour này
                </button>
                <button type="button" className="btn btn-outline btn-block" disabled={busy} onClick={() => submit(false)}>
                  Thêm vào phiếu đặt tạm
                </button>
              </div>
            </>
          )}
          {soldOut && (
            <div className="alert alert-warn" style={{ marginTop: 'var(--s3)' }}>
              Tour đã hết chỗ. <Link to="/contact">Liên hệ</Link> để được báo khi có chỗ trống.
            </div>
          )}
        </aside>
      </div>

      {tour.relatedTours?.length > 0 && (
        <section style={{ marginTop: 'var(--s8)' }}>
          <div className="section-head">
            <h2>Có thể bạn cũng thích</h2>
          </div>
          <div className="tour-grid">
            {tour.relatedTours.map((t) => (
              <TourCard key={t.id} tour={t} />
            ))}
          </div>
        </section>
      )}
    </div>
  )
}
