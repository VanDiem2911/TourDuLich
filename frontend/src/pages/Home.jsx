import { useEffect, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { ArrowRight, Search } from 'lucide-react'
import { publicApi } from '../api'
import { useAsync } from '../hooks/useAsync'
import TourCard from '../components/TourCard'

const SLIDES = ['/img/hero/hero-1.jpg', '/img/hero/hero-2.jpg', '/img/hero/hero-3.jpg', '/img/hero/hero-4.jpg']

const STEPS = [
  { t: 'Chọn hành trình', d: 'Lọc theo điểm đến, ngân sách, ngày đi. Mỗi tour có lịch trình từng ngày và số chỗ còn lại.' },
  { t: 'Lưu vào phiếu đặt tạm', d: 'Thêm nhiều tour, chỉnh số người lớn và trẻ em, xem tổng tiền trước khi quyết định.' },
  { t: 'Xác nhận và giữ chỗ', d: 'Điền thông tin liên hệ. Chỗ được giữ ngay cho đơn của bạn, giá được tính lại ở máy chủ.' },
  { t: 'Chuyển khoản qua mã QR', d: 'Quét mã, nội dung chuyển khoản đã điền sẵn. Hệ thống tự ghi nhận khi tiền về.' },
]

const PROMISES = [
  { t: 'Lịch trình viết như người đã đi', d: 'Từng ngày có điểm dừng, bữa ăn và nơi nghỉ. Không có khoản "chi phí phát sinh" mập mờ.' },
  { t: 'Giá hiển thị là giá thanh toán', d: 'Giá người lớn và trẻ em tách riêng, tổng tiền tính lại phía máy chủ nên không lệch khi đặt.' },
  { t: 'Số chỗ là số thật', d: 'Chỗ trống được cập nhật theo từng đơn, hủy đơn thì chỗ được trả lại ngay.' },
]

function Hero() {
  const navigate = useNavigate()
  const [i, setI] = useState(0)
  const [q, setQ] = useState('')
  const [cat, setCat] = useState('')
  const [budget, setBudget] = useState('')
  const { data: cats } = useAsync(() => publicApi.categories(), [])

  useEffect(() => {
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return
    const t = setInterval(() => setI((n) => (n + 1) % SLIDES.length), 6500)
    return () => clearInterval(t)
  }, [])

  const onSubmit = (e) => {
    e.preventDefault()
    const p = new URLSearchParams()
    if (q.trim()) p.set('keyword', q.trim())
    if (cat) p.set('categoryId', cat)
    if (budget) {
      const [min, max] = budget.split('-')
      if (min) p.set('minPrice', min)
      if (max) p.set('maxPrice', max)
    }
    navigate(`/tours${p.toString() ? `?${p}` : ''}`)
  }

  return (
    <section className="hero" aria-label="Giới thiệu">
      <div className="hero__slides" aria-hidden="true">
        {SLIDES.map((s, n) => (
          <div key={s} className={`hero__slide ${n === i ? 'is-on' : ''}`} style={{ backgroundImage: `url(${s})` }} />
        ))}
      </div>
      <div className="container hero__inner">
        <span className="eyebrow">Tour trong nước &amp; quốc tế</span>
        <h1>
          Những chuyến đi đáng để <em>kể lại</em>
        </h1>
        <p className="hero__lead">
          Từ vịnh Hạ Long đến đảo Bali, mỗi hành trình đều có lịch trình từng ngày, giá rõ ràng và chỗ ngồi được giữ thật.
        </p>
        <form className="finder" role="search" onSubmit={onSubmit}>
          <label>
            <span className="cap">Điểm đến hoặc mã tour</span>
            <input
              className="bare"
              type="search"
              placeholder="Đà Nẵng, Phú Quốc, Nhật Bản…"
              value={q}
              onChange={(e) => setQ(e.target.value)}
              maxLength={100}
            />
          </label>
          <label>
            <span className="cap">Loại hành trình</span>
            <select className="bare" value={cat} onChange={(e) => setCat(e.target.value)}>
              <option value="">Tất cả</option>
              {(cats || []).map((c) => (
                <option key={c.id} value={c.id}>
                  {c.name}
                </option>
              ))}
            </select>
          </label>
          <label>
            <span className="cap">Ngân sách / người</span>
            <select className="bare" value={budget} onChange={(e) => setBudget(e.target.value)}>
              <option value="">Mọi mức giá</option>
              <option value="-5000000">Dưới 5 triệu</option>
              <option value="5000000-10000000">5 – 10 triệu</option>
              <option value="10000000-20000000">10 – 20 triệu</option>
              <option value="20000000-">Trên 20 triệu</option>
            </select>
          </label>
          <button type="submit" className="btn btn-accent">
            <Search size={19} aria-hidden="true" /> Tìm tour
          </button>
        </form>
      </div>
      <div className="hero__dots">
        {SLIDES.map((s, n) => (
          <button key={s} type="button" className={n === i ? 'is-on' : ''} aria-label={`Ảnh ${n + 1}`} onClick={() => setI(n)} />
        ))}
      </div>
    </section>
  )
}

function Destinations() {
  const { data, loading } = useAsync(() => publicApi.destinations(), [])
  const list = (data || []).slice(0, 6)
  if (!loading && list.length === 0) return null
  return (
    <section className="page" style={{ paddingBottom: 0 }}>
      <div className="container">
        <div className="section-head">
          <div>
            <span className="eyebrow">Điểm đến</span>
            <h2>Nơi mọi người đang muốn đi</h2>
          </div>
          <Link className="link-arrow" to="/tours">
            Xem tất cả tour <ArrowRight size={18} aria-hidden="true" />
          </Link>
        </div>
        <div className="dest-grid">
          {loading
            ? Array.from({ length: 6 }).map((_, n) => <div key={n} className="skeleton dest" />)
            : list.map((d) => (
                <Link key={d.destination} to={`/tours?destination=${encodeURIComponent(d.destination)}`} className="dest">
                  <img src={d.imageUrl} alt="" loading="lazy" />
                  <span className="dest__label">
                    <strong>{d.destination}</strong>
                    <small>{d.tourCount} hành trình</small>
                  </span>
                </Link>
              ))}
        </div>
      </div>
    </section>
  )
}

function Featured() {
  const { data, loading, error, reload } = useAsync(() => publicApi.featured(6), [])
  return (
    <section className="page" style={{ paddingBottom: 0 }}>
      <div className="container">
        <div className="section-head">
          <div>
            <span className="eyebrow">Sắp khởi hành</span>
            <h2>Chọn chỗ trước khi hết</h2>
          </div>
          <Link className="link-arrow" to="/tours?sort=departureAsc">
            Xem theo ngày đi <ArrowRight size={18} aria-hidden="true" />
          </Link>
        </div>
        {error ? (
          <div className="empty">
            <h3>Không thể tải danh sách tour</h3>
            <p>{error}</p>
            <button type="button" className="btn btn-outline" onClick={reload}>
              Tải lại
            </button>
          </div>
        ) : (
          <div className="tour-grid">
            {loading
              ? Array.from({ length: 3 }).map((_, n) => <div key={n} className="skeleton" style={{ aspectRatio: '4/5' }} />)
              : (data || []).map((t) => <TourCard key={t.id} tour={t} />)}
          </div>
        )}
      </div>
    </section>
  )
}

export default function Home() {
  return (
    <>
      <Hero />
      <Destinations />
      <Featured />

      <section className="page" style={{ paddingBottom: 0 }}>
        <div className="container promise">
          <div>
            <span className="eyebrow">Cam kết</span>
            <h2>Đặt tour không nên là một cuộc đoán mò</h2>
            <p className="lead">Ba điều chúng tôi giữ nhất quán ở mọi tour trên trang.</p>
          </div>
          <div className="promise__list">
            {PROMISES.map((p, n) => (
              <div key={p.t} className="promise__item">
                <span>0{n + 1}</span>
                <div>
                  <h3>{p.t}</h3>
                  <p>{p.d}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="page" style={{ paddingBottom: 0 }}>
        <div className="container">
          <div className="section-head">
            <div>
              <span className="eyebrow">Quy trình</span>
              <h2>Từ chọn tour đến lên đường</h2>
            </div>
          </div>
          <ol className="steps" style={{ listStyle: 'none', padding: 0, margin: 0 }}>
            {STEPS.map((s) => (
              <li key={s.t} className="step">
                <h3>{s.t}</h3>
                <p>{s.d}</p>
              </li>
            ))}
          </ol>
        </div>
      </section>

      <section className="page" style={{ paddingBottom: 0 }}>
        <div className="container">
          <div className="cta-band">
            <h2>Chưa chắc nên đi đâu? Kể cho chúng tôi nghe.</h2>
            <div>
              <p>Cho biết ngân sách, số người và thời gian rảnh, tư vấn viên sẽ gợi ý hành trình phù hợp trong ngày làm việc.</p>
              <Link to="/contact" className="btn btn-accent">
                Gửi yêu cầu tư vấn <ArrowRight size={18} aria-hidden="true" />
              </Link>
            </div>
          </div>
        </div>
      </section>
    </>
  )
}
