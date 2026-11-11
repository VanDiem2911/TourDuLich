import { useEffect, useState } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'
import { ChevronDown, Minus, Plus } from 'lucide-react'
import { publicApi } from '../api'
import { getErrorMessage } from '../api/client'
import { useAsync } from '../hooks/useAsync'
import { useCart } from '../context/CartContext'
import { useToast } from '../components/Toast'
import TourCard from '../components/TourCard'
import { discountPct } from '../components/TourCard'
import { rememberTour, track } from '../tracking/tracker'
import { fmtDateLong, money, parseItinerary, parseNotes } from '../utils/format'

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
  const { data: tour, loading, error, status, reload } = useAsync(() => publicApi.tour(id), [id])
  const [adults, setAdults] = useState(1)
  const [children, setChildren] = useState(0)
  const [busy, setBusy] = useState(false)
  const [activeImg, setActiveImg] = useState(0)

  // Ghi nhận lượt xem tour (mỗi lần mở một tour khác)
  useEffect(() => {
    if (!tour?.id) return
    track('view_tour', { tourId: tour.id, props: { name: tour.name, price: tour.adultPrice, region: tour.region } })
    rememberTour(tour.id)
  }, [tour?.id]) // eslint-disable-line react-hooks/exhaustive-deps

  if (loading) {
    return (
      <div className="container page">
        <div className="skeleton" style={{ aspectRatio: '21/9', marginBottom: 24 }} />
        <div className="skeleton" style={{ height: 120 }} />
      </div>
    )
  }
  if (error || !tour) {
    // 404: tour không còn; lỗi mạng/máy chủ (không có mã 404): cho phép thử tải lại
    const canRetry = error && status !== 404
    return (
      <div className="container page">
        <div className="empty">
          <h3>{canRetry ? 'Không thể tải thông tin tour' : 'Không tìm thấy tour này'}</h3>
          <p>{canRetry ? `${error} Vui lòng kiểm tra kết nối rồi thử lại.` : 'Tour du lịch không tồn tại hoặc đã ngừng mở bán!'}</p>
          <div style={{ display: 'flex', gap: 'var(--s3)', flexWrap: 'wrap', justifyContent: 'center' }}>
            {canRetry && (
              <button type="button" className="btn btn-primary" onClick={reload}>
                Thử lại
              </button>
            )}
            <Link to="/tours" className={canRetry ? 'btn btn-outline' : 'btn btn-primary'}>
              Xem các tour khác
            </Link>
          </div>
        </div>
      </div>
    )
  }

  const seats = tour.availableSeats
  const total = adults * tour.adultPrice + children * (tour.childPrice ?? tour.adultPrice)
  const soldOut = seats <= 0
  const days = parseItinerary(tour.itinerary)
  const notes = parseNotes(tour.notes)
  const images = [tour.imageUrl, ...(tour.gallery || [])].filter((u, i, a) => u && a.indexOf(u) === i)
  const onSale = tour.originalPrice > 0
  const maxAdults = Math.max(1, seats - children)
  const maxChildren = Math.max(0, seats - adults)

  const submit = async (goCart) => {
    setBusy(true)
    try {
      await add({ tourId: tour.id, adultQuantity: adults, childQuantity: children })
      track('add_to_cart', { tourId: tour.id, props: { adults, children, goCart } })
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
        <Link to="/">Trang chủ</Link> / <Link to={tour.region ? `/tours?region=${tour.region}` : '/tours'}>
          {tour.region === 'INTERNATIONAL' ? 'Tour nước ngoài' : tour.region === 'DOMESTIC' ? 'Tour trong nước' : 'Tour'}
        </Link>{' '}
        /{' '}
        <Link to={`/tours?categoryId=${tour.categoryId}`}>{tour.categoryName}</Link> / <span aria-current="page">{tour.tourCode}</span>
      </nav>

      <div className="detail-hero">
        <div>
          <h1 className="detail-title">
            {tour.name}
          </h1>
        </div>
        <div>
          <div className="detail-hero__img">
            <img src={images[Math.min(activeImg, images.length - 1)]} alt={tour.name} />
          </div>
          {images.length > 1 && (
            <div className="gallery" role="group" aria-label="Thư viện ảnh của tour">
              {images.map((src, i) => (
                <button
                  key={src}
                  type="button"
                  className="gallery__thumb"
                  aria-label={`Xem ảnh ${i + 1} trên ${images.length}`}
                  aria-pressed={i === activeImg}
                  onClick={() => setActiveImg(i)}
                >
                  <img src={src} alt="" loading="lazy" />
                </button>
              ))}
            </div>
          )}
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

          {notes.length > 0 && (
            <section className="notes" aria-labelledby="notes-title">
              <div className="section-head" style={{ marginBottom: 'var(--s3)', borderBottom: 0 }}>
                <h2 id="notes-title" style={{ fontSize: '1.9rem' }}>Giá tour &amp; lưu ý</h2>
              </div>
              {notes.map((n, i) => (
                <details key={n.title} open={i < 2}>
                  <summary>
                    {n.title}
                    <ChevronDown size={20} aria-hidden="true" />
                  </summary>
                  <div className="notes__body">
                    {n.lines.map((l, k) => (
                      <p key={k}>{l}</p>
                    ))}
                  </div>
                </details>
              ))}
            </section>
          )}
        </div>

        <aside className="booking-box" aria-label="Đặt tour">
          <div className="price">
            {onSale && <s className="price__old">{money(tour.originalPrice)}</s>}
            <small>từ</small>
            {money(tour.adultPrice)}
            {onSale && <span className="badge-sale">Giảm {discountPct(tour)}%</span>}
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
