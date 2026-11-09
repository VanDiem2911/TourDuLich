import { useEffect, useMemo, useRef, useState } from 'react'
import { Link } from 'react-router-dom'
import { ArrowRight, RefreshCw } from 'lucide-react'
import { adminApi } from '../../api'
import { useAsync } from '../../hooks/useAsync'
import { BOOKING_STATUS, PAYMENT_STATUS, fmtDate, money } from '../../utils/format'
import StatusTag from '../../components/StatusTag'
import { EmptyState, ErrorState, fmtCompact } from './AdminKit'

/* ------------------------------ Biểu đồ doanh thu (SVG thuần) ------------------------------ */

const monthLabel = (m) => {
  const [y, mm] = String(m).split('-')
  return `T${Number(mm)}/${String(y).slice(2)}`
}
const monthLong = (m) => {
  const [y, mm] = String(m).split('-')
  return `tháng ${Number(mm)}/${y}`
}

/** Chọn mức trần "tròn" để 4 vạch chia đều đẹp (1, 2, 2.5, 5 x 10^k). */
function niceMax(maxVal) {
  if (maxVal <= 0) return 4_000_000
  const raw = maxVal / 4
  const mag = 10 ** Math.floor(Math.log10(raw))
  const step = [1, 2, 2.5, 5, 10].map((k) => k * mag).find((s) => s >= raw)
  return step * 4
}

function useWidth() {
  const ref = useRef(null)
  const [w, setW] = useState(0)
  useEffect(() => {
    const el = ref.current
    if (!el) return
    const ro = new ResizeObserver(([e]) => setW(Math.floor(e.contentRect.width)))
    ro.observe(el)
    return () => ro.disconnect()
  }, [])
  return [ref, w]
}

function RevenueChart({ months }) {
  const [wrapRef, w] = useWidth()
  const width = Math.max(w, 640)
  const height = 300
  const m = { t: 30, r: 12, b: 34, l: 54 }
  const cw = width - m.l - m.r
  const ch = height - m.t - m.b

  const values = months.map((x) => Number(x.revenue) || 0)
  const total = values.reduce((a, b) => a + b, 0)
  const max = niceMax(Math.max(0, ...values))
  const slot = cw / Math.max(months.length, 1)
  const bw = Math.min(40, slot * 0.58)
  const y = (v) => m.t + ch - (v / max) * ch
  const ticks = [0, 1, 2, 3, 4].map((i) => (max / 4) * i)

  const summary = useMemo(() => {
    if (!months.length) return 'Không có dữ liệu doanh thu.'
    let hi = 0
    let lo = 0
    values.forEach((v, i) => {
      if (v > values[hi]) hi = i
      if (v < values[lo]) lo = i
    })
    return (
      `Biểu đồ cột doanh thu ${months.length} tháng gần nhất, từ ${monthLong(months[0].month)} đến ${monthLong(months[months.length - 1].month)}. ` +
      `Tổng ${money(total)}. Cao nhất ${monthLong(months[hi].month)} đạt ${money(values[hi])}` +
      (values[hi] === values[lo] ? '.' : `, thấp nhất ${monthLong(months[lo].month)} đạt ${money(values[lo])}.`)
    )
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [months])

  return (
    <>
      <div ref={wrapRef} className="chart-scroll" tabIndex={0} role="region" aria-label="Biểu đồ doanh thu theo tháng, cuộn ngang để xem đủ">
        <svg
          className="chart"
          width={width}
          height={height}
          viewBox={`0 0 ${width} ${height}`}
          role="img"
          aria-label={summary}
        >
          {ticks.map((t, i) => (
            <g key={t}>
              <line className={i === 0 ? 'base' : 'grid'} x1={m.l} x2={width - m.r} y1={y(t)} y2={y(t)} />
              <text className="tick" x={m.l - 8} y={y(t) + 4}>
                {fmtCompact(t)}
              </text>
            </g>
          ))}
          {months.map((mo, i) => {
            const v = values[i]
            const h = (v / max) * ch
            const x = m.l + i * slot + (slot - bw) / 2
            const now = i === months.length - 1
            return (
              <g key={mo.month} className="bar-hit">
                <title>{`${monthLabel(mo.month)}: ${money(v)}, ${mo.bookings ?? 0} đơn`}</title>
                {v > 0 && <rect className={`bar ${now ? 'bar--now' : ''}`} x={x} y={y(v)} width={bw} height={h} rx="1" />}
                <text className={`vlab ${v > 0 ? '' : 'vlab--zero'}`} x={m.l + i * slot + slot / 2} y={y(v) - 6}>
                  {v > 0 ? fmtCompact(v) : '0'}
                </text>
                <text className={`xlab ${now ? 'xlab--now' : ''}`} x={m.l + i * slot + slot / 2} y={height - 12}>
                  {monthLabel(mo.month)}
                </text>
              </g>
            )
          })}
        </svg>
      </div>
      <ul className="chart-legend">
        <li>
          <span className="sw sw--forest" aria-hidden="true" /> Các tháng trước
        </li>
        <li>
          <span className="sw sw--clay" aria-hidden="true" /> Tháng hiện tại (chữ đậm)
        </li>
        <li>Đơn vị: đồng; tr = triệu, k = nghìn</li>
      </ul>
      <table className="visually-hidden">
        <caption>Doanh thu và số đơn theo tháng</caption>
        <thead>
          <tr>
            <th scope="col">Tháng</th>
            <th scope="col">Doanh thu</th>
            <th scope="col">Số đơn</th>
          </tr>
        </thead>
        <tbody>
          {months.map((mo) => (
            <tr key={mo.month}>
              <th scope="row">{monthLabel(mo.month)}</th>
              <td>{money(mo.revenue)}</td>
              <td>{mo.bookings ?? 0}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </>
  )
}

/* ------------------------------ Cơ cấu trạng thái đơn ------------------------------ */

const STATUS_ORDER = [
  ['PENDING', 'seg--pending'],
  ['CONFIRMED', 'seg--confirmed'],
  ['COMPLETED', 'seg--completed'],
  ['CANCELLED', 'seg--cancelled'],
]

function StatusBreakdown({ counts }) {
  const total = STATUS_ORDER.reduce((s, [k]) => s + (counts?.[k] || 0), 0)
  if (!total) return <p className="muted">Chưa có đơn đặt tour nào.</p>
  return (
    <>
      <div className="stack" aria-hidden="true">
        {STATUS_ORDER.filter(([k]) => counts[k] > 0).map(([k, cls]) => (
          <i key={k} className={cls} style={{ flexGrow: counts[k] }} />
        ))}
      </div>
      <ul className="legend">
        {STATUS_ORDER.map(([k, cls]) => {
          const n = counts?.[k] || 0
          return (
            <li key={k}>
              <span className={`sw ${cls}`} aria-hidden="true" />
              <Link to={`/admin/bookings?status=${k}`}>{BOOKING_STATUS[k].label}</Link>
              <span className="legend__n">{n}</span>
              <span className="legend__p">{Math.round((n / total) * 100)}%</span>
            </li>
          )
        })}
      </ul>
    </>
  )
}

/* ------------------------------ Trang ------------------------------ */

function Tile({ label, value, note, to, attn, wide, goLabel }) {
  const cls = `stat ${wide ? 'stat--wide' : ''} ${attn ? 'stat--attn' : ''}`
  const body = (
    <>
      <span>{label}</span>
      <strong className="num">{value}</strong>
      {note && <small>{note}</small>}
      {attn && goLabel && (
        <em className="stat__go">
          {goLabel} <ArrowRight size={14} aria-hidden="true" />
        </em>
      )}
    </>
  )
  return to ? (
    <Link to={to} className={cls}>
      {body}
    </Link>
  ) : (
    <div className={cls}>{body}</div>
  )
}

function DashSkeleton() {
  return (
    <div aria-busy="true">
      <span className="visually-hidden" role="status">
        Đang tải số liệu
      </span>
      <div className="stat-grid stat-grid--dash">
        <div className="skeleton stat--wide" style={{ height: 118 }} />
        {Array.from({ length: 6 }, (_, i) => (
          <div key={i} className="skeleton" style={{ height: 118 }} />
        ))}
      </div>
      <div className="dash-grid">
        <div className="skeleton" style={{ height: 400 }} />
        <div className="skeleton" style={{ height: 400 }} />
      </div>
    </div>
  )
}

export default function AdminDashboard() {
  const { data, loading, error, reload } = useAsync(() => adminApi.stats(), [])

  return (
    <>
      <div className="admin-head">
        <div>
          <span className="eyebrow">Tổng quan</span>
          <h1>Bảng điều khiển</h1>
          <p>Số liệu kinh doanh và việc đang chờ xử lý. Doanh thu chỉ tính các đơn đã thanh toán.</p>
        </div>
        <div className="admin-head__actions">
          <button type="button" className="btn btn-outline btn-sm" onClick={reload} disabled={loading}>
            <RefreshCw size={16} aria-hidden="true" />
            Làm mới
          </button>
        </div>
      </div>

      {error ? (
        <ErrorState message={error} onRetry={reload} />
      ) : !data ? (
        <DashSkeleton />
      ) : (
        <div aria-busy={loading}>
          <div className="stat-grid stat-grid--dash">
            <Tile wide label="Doanh thu" value={money(data.totalRevenue)} note="Tổng các đơn đã thanh toán" />
            <Tile label="Tổng đơn đặt tour" value={data.totalBookings} to="/admin/bookings" />
            <Tile
              label="Đơn chờ xác nhận"
              value={data.pendingBookings}
              to="/admin/bookings?status=PENDING"
              attn={data.pendingBookings > 0}
              goLabel="Xử lý ngay"
            />
            <Tile label="Tour đang mở bán" value={data.totalActiveTours} to="/admin/tours" />
            <Tile label="Danh mục" value={data.totalCategories} to="/admin/categories" />
            <Tile label="Khách hàng" value={data.totalCustomers} to="/admin/users" />
            <Tile
              label="Liên hệ mới"
              value={data.newContacts}
              to="/admin/contacts?status=NEW"
              attn={data.newContacts > 0}
              goLabel="Xem tin nhắn"
            />
          </div>

          <div className="dash-grid">
            <section className="panel" aria-labelledby="h-rev">
              <h2 id="h-rev">Doanh thu theo tháng</h2>
              <p className="panel__sub">12 tháng gần nhất, tính theo đơn đã thanh toán.</p>
              <RevenueChart months={data.revenueByMonth ?? []} />
            </section>
            <section className="panel" aria-labelledby="h-status">
              <h2 id="h-status">Trạng thái đơn</h2>
              <p className="panel__sub">Phân bổ toàn bộ đơn theo tiến độ xử lý.</p>
              <StatusBreakdown counts={data.bookingsByStatus} />
            </section>
          </div>

          <div className="dash-grid dash-grid--even">
            <section className="panel" aria-labelledby="h-top">
              <h2 id="h-top">Tour bán chạy</h2>
              <p className="panel__sub">Top 5 theo số chỗ đã đặt.</p>
              {data.topTours?.length ? (
                <div className="table-wrap" tabIndex={0} role="region" aria-label="Bảng tour bán chạy">
                  <table className="table">
                    <thead>
                      <tr>
                        <th scope="col">Tour</th>
                        <th scope="col" className="r">
                          Chỗ đặt
                        </th>
                        <th scope="col" className="r">
                          Doanh thu
                        </th>
                      </tr>
                    </thead>
                    <tbody>
                      {data.topTours.map((t, i) => (
                        <tr key={t.tourId}>
                          <td>
                            <span className="rank" aria-hidden="true">
                              {i + 1}
                            </span>
                            <span className="cell-main">{t.name}</span>
                          </td>
                          <td className="r num">{t.bookedSeats}</td>
                          <td className="r num nowrap">{money(t.revenue)}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              ) : (
                <EmptyState title="Chưa có dữ liệu">
                  <p>Tour bán chạy sẽ xuất hiện khi có đơn đặt đầu tiên.</p>
                </EmptyState>
              )}
            </section>

            <section className="panel" aria-labelledby="h-recent">
              <h2 id="h-recent">Đơn mới nhất</h2>
              <p className="panel__sub">
                8 đơn gần đây. <Link to="/admin/bookings">Xem tất cả đơn</Link>
              </p>
              {data.recentBookings?.length ? (
                <div className="table-wrap" tabIndex={0} role="region" aria-label="Bảng đơn mới nhất">
                  <table className="table table--mid">
                    <thead>
                      <tr>
                        <th scope="col">Mã đơn</th>
                        <th scope="col">Khách hàng</th>
                        <th scope="col" className="r">
                          Tổng tiền
                        </th>
                        <th scope="col">Đơn</th>
                        <th scope="col">Thanh toán</th>
                      </tr>
                    </thead>
                    <tbody>
                      {data.recentBookings.map((b) => (
                        <tr key={b.id}>
                          <td className="nowrap">
                            <Link className="cell-main" to={`/admin/bookings?open=${b.id}`}>
                              {b.bookingCode}
                            </Link>
                            <span className="cell-sub">{fmtDate(b.createdAt)}</span>
                          </td>
                          <td>
                            <span className="cell-main">{b.customerName || '—'}</span>
                            <span className="cell-sub">{b.firstTourName}</span>
                          </td>
                          <td className="r num nowrap">{money(b.totalAmount)}</td>
                          <td>
                            <StatusTag map={BOOKING_STATUS} value={b.bookingStatus} />
                          </td>
                          <td>
                            <StatusTag map={PAYMENT_STATUS} value={b.paymentStatus} />
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              ) : (
                <EmptyState title="Chưa có đơn nào">
                  <p>Đơn đặt tour của khách sẽ hiện ở đây.</p>
                </EmptyState>
              )}
            </section>
          </div>
        </div>
      )}
    </>
  )
}
