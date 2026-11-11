import { useState } from 'react'
import { Link } from 'react-router-dom'
import { RefreshCw } from 'lucide-react'
import { adminApi } from '../../api'
import { useAsync } from '../../hooks/useAsync'
import { EmptyState, ErrorState, Tile } from './AdminKit'

const RANGES = [
  { v: 7, t: '7 ngày' },
  { v: 30, t: '30 ngày' },
  { v: 90, t: '90 ngày' },
]

const FUNNEL = [
  { k: 'view_tour', t: 'Xem chi tiết tour' },
  { k: 'add_to_cart', t: 'Thêm vào phiếu đặt tạm' },
  { k: 'begin_checkout', t: 'Vào trang đặt tour' },
  { k: 'booking_created', t: 'Đặt tour thành công' },
]

const TYPE_LABEL = {
  page_view: 'Xem trang',
  page_leave: 'Rời trang',
  click: 'Bấm nút / liên kết',
  view_tour: 'Xem chi tiết tour',
  search: 'Tìm kiếm',
  add_to_cart: 'Thêm vào phiếu đặt tạm',
  remove_from_cart: 'Xóa khỏi phiếu đặt tạm',
  begin_checkout: 'Vào trang đặt tour',
  booking_created: 'Đặt tour thành công',
  login: 'Đăng nhập',
  register: 'Đăng ký',
  chat_open: 'Mở khung chat',
  chat_message: 'Hỏi trợ lý AI',
  chat_error: 'Lỗi trợ lý AI',
}
const typeLabel = (t) => TYPE_LABEL[t] || t

const dayLabel = (d) => `${d.slice(8, 10)}/${d.slice(5, 7)}`

/** Biểu đồ cột số phiên mỗi ngày (HTML/CSS thuần, có mô tả cho trình đọc màn hình). */
function DailyBars({ daily }) {
  if (!daily?.length) return <p className="muted">Chưa có dữ liệu theo ngày.</p>
  const max = Math.max(1, ...daily.map((d) => Number(d.sessions)))
  const step = daily.length > 16 ? Math.ceil(daily.length / 12) : 1
  const summary = daily.map((d) => `${dayLabel(d.day)}: ${d.sessions} phiên`).join('; ')
  return (
    <div className="bars" role="img" aria-label={`Số phiên truy cập mỗi ngày. ${summary}`}>
      {daily.map((d, i) => (
        <div className="bars__col" key={d.day} title={`${dayLabel(d.day)}: ${d.sessions} phiên, ${d.pageViews} lượt xem trang`}>
          <span className="bars__val num">{d.sessions}</span>
          <span className="bars__bar" style={{ height: `${Math.max(4, (Number(d.sessions) / max) * 100)}%` }} />
          <small>{i % step === 0 ? dayLabel(d.day) : ''}</small>
        </div>
      ))}
    </div>
  )
}

export default function AdminTracking() {
  const [days, setDays] = useState(7)
  const { data, loading, error, reload } = useAsync(() => adminApi.trackingSummary(days), [days])

  const base = Number(data?.funnel?.view_tour || 0)
  const empty = data && Number(data.visitors) === 0

  return (
    <>
      <div className="admin-head">
        <div>
          <h1>Hành vi người dùng</h1>
          <p>Cách khách duyệt website: xem trang nào, tìm gì, bỏ ngang ở bước nào. Dữ liệu ẩn danh, chỉ từ khách đã đồng ý theo dõi.</p>
        </div>
        <div className="admin-head__actions">
          <div className="seg" role="group" aria-label="Khoảng thời gian">
            {RANGES.map((r) => (
              <button key={r.v} type="button" aria-pressed={days === r.v} onClick={() => setDays(r.v)}>
                {r.t}
              </button>
            ))}
          </div>
          <button type="button" className="btn btn-outline btn-sm" onClick={reload} disabled={loading}>
            <RefreshCw size={16} aria-hidden="true" />
            Làm mới
          </button>
        </div>
      </div>

      {error ? (
        <ErrorState message={error} onRetry={reload} />
      ) : !data ? (
        <div className="skeleton" style={{ height: 320 }} />
      ) : empty ? (
        <EmptyState title="Chưa có dữ liệu hành vi">
          <p>Sự kiện chỉ được ghi khi khách bấm “Đồng ý” ở thông báo quyền riêng tư trên website. Hãy mở trang khách, đồng ý và duyệt thử vài trang.</p>
        </EmptyState>
      ) : (
        <div aria-busy={loading}>
          <div className="stat-grid stat-grid--dash">
            <Tile label="Khách truy cập" value={data.visitors} note={`${days} ngày qua, tính theo mã ẩn danh`} />
            <Tile label="Phiên truy cập" value={data.sessions} />
            <Tile label="Lượt xem trang" value={data.byType?.page_view ?? 0} />
            <Tile label="Câu hỏi cho trợ lý AI" value={data.byType?.chat_message ?? 0} to="/admin/ai" />
          </div>

          <div className="dash-grid">
            <section className="panel" aria-labelledby="h-daily">
              <h2 id="h-daily">Phiên truy cập mỗi ngày</h2>
              <p className="panel__sub">Số phiên (mỗi phiên kết thúc sau 30 phút không hoạt động).</p>
              <DailyBars daily={data.daily} />
            </section>

            <section className="panel" aria-labelledby="h-funnel">
              <h2 id="h-funnel">Phễu đặt tour</h2>
              <p className="panel__sub">Số phiên đi tới từng bước.</p>
              <ol className="funnel">
                {FUNNEL.map((s, i) => {
                  const n = Number(data.funnel?.[s.k] || 0)
                  const prev = i === 0 ? n : Number(data.funnel?.[FUNNEL[i - 1].k] || 0)
                  const drop = i > 0 && prev > 0 ? Math.round(100 * (1 - n / prev)) : null
                  return (
                    <li key={s.k}>
                      <div className="funnel__row">
                        <span>{s.t}</span>
                        <strong className="num">
                          {n}
                          <small> · {base > 0 ? `${Math.round((100 * n) / base)}%` : '—'}</small>
                        </strong>
                      </div>
                      <div className="funnel__track" aria-hidden="true">
                        <span style={{ width: `${base > 0 ? Math.max(2, (n / base) * 100) : 0}%` }} />
                      </div>
                      {drop !== null && drop > 0 && <em className="funnel__drop">Rớt {drop}% so với bước trước</em>}
                    </li>
                  )
                })}
              </ol>
            </section>
          </div>

          <div className="dash-grid dash-grid--even">
            <section className="panel" aria-labelledby="h-tours">
              <h2 id="h-tours">Tour được xem nhiều</h2>
              <p className="panel__sub">Top 5 theo lượt xem chi tiết.</p>
              {data.topTours?.length ? (
                <div className="table-wrap" tabIndex={0} role="region" aria-label="Tour được xem nhiều">
                  <table className="table">
                    <thead>
                      <tr>
                        <th scope="col">Tour</th>
                        <th scope="col" className="r">Lượt xem</th>
                        <th scope="col" className="r">Phiên</th>
                      </tr>
                    </thead>
                    <tbody>
                      {data.topTours.map((t) => (
                        <tr key={t.tourId}>
                          <td>
                            <Link className="cell-main" to={`/tours/${t.tourId}`}>
                              {t.name || `Tour #${t.tourId}`}
                            </Link>
                          </td>
                          <td className="r num">{t.views}</td>
                          <td className="r num">{t.sessions}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              ) : (
                <p className="muted">Chưa có lượt xem tour nào.</p>
              )}

              <h3 style={{ fontSize: '1rem', marginTop: 'var(--s5)' }}>Từ khóa tìm kiếm</h3>
              {data.topSearches?.length ? (
                <ul className="chips-static">
                  {data.topSearches.map((s) => (
                    <li key={s.keyword}>
                      {s.keyword} <b className="num">{s.n}</b>
                    </li>
                  ))}
                </ul>
              ) : (
                <p className="muted">Chưa có tìm kiếm nào.</p>
              )}
            </section>

            <section className="panel" aria-labelledby="h-types">
              <h2 id="h-types">Hành động theo loại</h2>
              <p className="panel__sub">Tổng số sự kiện đã ghi trong {days} ngày.</p>
              <div className="table-wrap" tabIndex={0} role="region" aria-label="Hành động theo loại">
                <table className="table">
                  <thead>
                    <tr>
                      <th scope="col">Hành động</th>
                      <th scope="col" className="r">Số lần</th>
                    </tr>
                  </thead>
                  <tbody>
                    {Object.entries(data.byType || {}).map(([t, n]) => (
                      <tr key={t}>
                        <td>{typeLabel(t)}</td>
                        <td className="r num">{n}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </section>
          </div>

          <section className="panel" aria-labelledby="h-recent" style={{ marginTop: 'var(--s5)' }}>
            <h2 id="h-recent">Hoạt động gần đây</h2>
            <p className="panel__sub">25 sự kiện mới nhất. Chỉ hiện 6 ký tự đầu của mã ẩn danh, không có nội dung khách nhập.</p>
            <div className="table-wrap" tabIndex={0} role="region" aria-label="Hoạt động gần đây">
              <table className="table">
                <thead>
                  <tr>
                    <th scope="col">Thời gian</th>
                    <th scope="col">Khách</th>
                    <th scope="col">Hành động</th>
                    <th scope="col">Trang / đối tượng</th>
                  </tr>
                </thead>
                <tbody>
                  {(data.recent || []).map((e, i) => (
                    <tr key={`${e.at}-${i}`}>
                      <td className="nowrap num">{e.at}</td>
                      <td className="nowrap">
                        <span className="num">{e.visitor}…</span>
                        {Number(e.loggedIn) === 1 || e.loggedIn === true ? <span className="cell-sub">đã đăng nhập</span> : null}
                      </td>
                      <td>{typeLabel(e.type)}</td>
                      <td>
                        <span className="cell-main">{e.tourName || e.target || e.page}</span>
                        {(e.tourName || e.target) && <span className="cell-sub">{e.page}</span>}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </section>
        </div>
      )}
    </>
  )
}
