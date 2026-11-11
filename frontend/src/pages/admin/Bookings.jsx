import { useState } from 'react'
import { useSearchParams } from 'react-router-dom'
import { Check, CircleDollarSign, Eye, RotateCcw, X } from 'lucide-react'
import { adminApi } from '../../api'
import { getErrorMessage } from '../../api/client'
import { BOOKING_STATUS, PAYMENT_STATUS, fmtDate, fmtDateTime, money } from '../../utils/format'
import { useAsync } from '../../hooks/useAsync'
import StatusTag from '../../components/StatusTag'
import ConfirmDialog from '../../components/ConfirmDialog'
import Pagination from '../../components/Pagination'
import { useToast } from '../../components/Toast'
import {
  EmptyState,
  ErrorState,
  Field,
  Modal,
  ResultCount,
  SearchBox,
  SkeletonRows,
  SubmitButton,
  useListPage,
} from './AdminKit'

const METHOD = { BANK_QR: 'Chuyển khoản QR', OFFICE: 'Thu tại văn phòng' }

/* ------------------------------ Dòng thời gian trạng thái ------------------------------ */

function StatusTimeline({ b }) {
  const steps =
    b.bookingStatus === 'CANCELLED'
      ? [
          { label: 'Khách đặt tour', time: b.createdAt, state: 'done' },
          {
            label: 'Đơn đã hủy',
            state: 'bad',
            note: b.cancelReason ? `Lý do: ${b.cancelReason}` : null,
            extra: b.paymentStatus === 'REFUNDED' ? 'Đã hoàn tiền cho khách.' : null,
          },
        ]
      : (() => {
          const flow = ['PENDING', 'CONFIRMED', 'COMPLETED']
          const idx = flow.indexOf(b.bookingStatus)
          const labels = ['Đặt tour, chờ xác nhận', 'Đã xác nhận đơn', 'Hoàn tất chuyến đi']
          return labels.map((label, i) => ({
            label,
            time: i === 0 ? b.createdAt : null,
            state: i < idx ? 'done' : i === idx ? 'now' : 'todo',
          }))
        })()

  const stateText = { done: 'Đã qua', now: 'Hiện tại', todo: 'Chưa tới', bad: 'Kết thúc' }
  return (
    <ol className="steps-log">
      {steps.map((s) => (
        <li key={s.label} className={`is-${s.state}`}>
          <span className="mk" aria-hidden="true">
            {s.state === 'done' && <Check size={12} strokeWidth={3} />}
            {s.state === 'bad' && <X size={12} strokeWidth={3} />}
          </span>
          <div>
            <strong>
              {s.label}
              <span className="state">{stateText[s.state]}</span>
            </strong>
            {s.time && <small>{fmtDateTime(s.time)}</small>}
            {s.note && <small>{s.note}</small>}
            {s.extra && <small> {s.extra}</small>}
          </div>
        </li>
      ))}
    </ol>
  )
}

/* ------------------------------ Ngăn chi tiết đơn ------------------------------ */

const ACTIONS = {
  confirm: {
    title: 'Xác nhận đơn này?',
    message: (b) => `Đơn ${b.bookingCode} sẽ chuyển sang “Đã xác nhận”. Bước này không thể quay lui.`,
    label: 'Xác nhận đơn',
    ok: 'Đã xác nhận đơn.',
    run: (b) => adminApi.setBookingStatus(b.id, 'CONFIRMED'),
  },
  complete: {
    title: 'Đánh dấu hoàn tất?',
    message: (b) => `Đơn ${b.bookingCode} sẽ chuyển sang “Hoàn tất” và không thể hủy nữa.`,
    label: 'Hoàn tất đơn',
    ok: 'Đơn đã hoàn tất.',
    run: (b) => adminApi.setBookingStatus(b.id, 'COMPLETED'),
  },
  cancel: {
    title: 'Hủy đơn này?',
    message: (b, reason) =>
      `Đơn ${b.bookingCode} sẽ bị hủy, số chỗ được trả lại cho tour${b.paymentStatus === 'PAID' ? ' và đơn được ghi nhận hoàn tiền' : ''}. Lý do: “${reason}”.`,
    label: 'Hủy đơn',
    ok: 'Đã hủy đơn.',
    danger: true,
    run: (b, reason) => adminApi.setBookingStatus(b.id, 'CANCELLED', reason),
  },
  paid: {
    title: 'Ghi nhận đã thu tiền?',
    message: (b) => `Đánh dấu đơn ${b.bookingCode} đã thanh toán ${money(b.totalAmount)} (thu tại văn phòng).`,
    label: 'Đã thu tiền',
    ok: 'Đã ghi nhận thanh toán.',
    run: (b) => adminApi.setBookingPayment(b.id, 'PAID'),
  },
  unpaid: {
    title: 'Bỏ ghi nhận thanh toán?',
    message: (b) => `Đơn ${b.bookingCode} sẽ trở lại trạng thái chưa thanh toán.`,
    label: 'Chuyển về chưa thu',
    ok: 'Đã chuyển đơn về chưa thanh toán.',
    danger: true,
    run: (b) => adminApi.setBookingPayment(b.id, 'UNPAID'),
  },
}

function CancelReasonModal({ booking, onClose, onSubmit }) {
  const [reason, setReason] = useState('')
  const [error, setError] = useState('')
  const submit = (e) => {
    e.preventDefault()
    const r = reason.trim()
    if (!r) return setError('Vui lòng nhập lý do hủy đơn.')
    if (r.length < 5) return setError('Lý do hủy quá ngắn, hãy mô tả rõ hơn.')
    onSubmit(r)
  }
  return (
    <Modal
      title="Hủy đơn đặt tour"
      subtitle={booking.bookingCode}
      onClose={onClose}
      footer={
        <>
          <button type="button" className="btn btn-outline" onClick={onClose}>
            Quay lại
          </button>
          <SubmitButton form="cancel-form" className="btn btn-danger">
            Tiếp tục hủy đơn
          </SubmitButton>
        </>
      }
    >
      <form id="cancel-form" className="form" onSubmit={submit} noValidate>
        <p className="muted">Lý do sẽ được lưu cùng đơn để khách và nhân viên khác nắm được.</p>
        <Field label="Lý do hủy" required error={error}>
          <textarea className="input" value={reason} onChange={(e) => setReason(e.target.value)} maxLength={500} autoFocus />
        </Field>
      </form>
    </Modal>
  )
}

function BookingDrawer({ id, onClose, onChanged }) {
  const toast = useToast()
  const { data: b, loading, error, reload } = useAsync(() => adminApi.booking(id), [id])
  const [cancelling, setCancelling] = useState(false) // mở hộp nhập lý do
  const [confirm, setConfirm] = useState(null) // { type, reason? }
  const [working, setWorking] = useState(false)

  const run = async () => {
    const { type, reason } = confirm
    setConfirm(null)
    setCancelling(false)
    setWorking(true)
    try {
      await ACTIONS[type].run(b, reason)
      toast.success(ACTIONS[type].ok)
      onChanged()
      reload()
    } catch (err) {
      toast.error(getErrorMessage(err, 'Không thực hiện được thao tác.'))
    } finally {
      setWorking(false)
    }
  }

  const st = b?.bookingStatus
  const canConfirm = st === 'PENDING'
  const canComplete = st === 'CONFIRMED'
  const canCancel = st === 'PENDING' || st === 'CONFIRMED'
  const canPay = b && st !== 'CANCELLED' && b.paymentStatus === 'UNPAID'
  const canUnpay = b && st !== 'CANCELLED' && b.paymentStatus === 'PAID'
  const noActions = b && !canConfirm && !canComplete && !canCancel && !canPay && !canUnpay

  const footer = b && (
    <>
      {noActions && <p className="muted spacer" style={{ margin: 0, alignSelf: 'center' }}>Đơn đã kết thúc, không còn thao tác khả dụng.</p>}
      {(canPay || canUnpay) && (
        <button
          type="button"
          className="btn btn-outline spacer"
          disabled={working}
          onClick={() => setConfirm({ type: canPay ? 'paid' : 'unpaid' })}
        >
          {canPay ? <CircleDollarSign size={16} aria-hidden="true" /> : <RotateCcw size={16} aria-hidden="true" />}
          {canPay ? 'Đánh dấu đã thu tiền' : 'Chuyển về chưa thu'}
        </button>
      )}
      {canCancel && (
        <button type="button" className="btn btn-outline" disabled={working} onClick={() => setCancelling(true)}>
          Hủy đơn
        </button>
      )}
      {canConfirm && (
        <button type="button" className="btn btn-accent" disabled={working} onClick={() => setConfirm({ type: 'confirm' })}>
          {working && <span className="spinner" aria-hidden="true" />}
          Xác nhận đơn
        </button>
      )}
      {canComplete && (
        <button type="button" className="btn btn-primary" disabled={working} onClick={() => setConfirm({ type: 'complete' })}>
          {working && <span className="spinner" aria-hidden="true" />}
          Hoàn tất đơn
        </button>
      )}
    </>
  )

  const cfg = confirm ? ACTIONS[confirm.type] : null

  return (
    <>
      <Modal
        drawer
        title={b ? `Đơn ${b.bookingCode}` : 'Chi tiết đơn'}
        subtitle={
          b && (
            <>
              <StatusTag map={BOOKING_STATUS} value={b.bookingStatus} />
              <StatusTag map={PAYMENT_STATUS} value={b.paymentStatus} />
              <span>Đặt lúc {fmtDateTime(b.createdAt)}</span>
            </>
          )
        }
        onClose={onClose}
        busy={working}
        footer={footer}
      >
        {error ? (
          <ErrorState message={error} onRetry={reload} />
        ) : !b ? (
          <div aria-busy="true">
            <span className="visually-hidden" role="status">
              Đang tải chi tiết đơn
            </span>
            {[120, 90, 160, 110].map((h, i) => (
              <div key={i} className="skeleton" style={{ height: h, marginBottom: 16 }} />
            ))}
          </div>
        ) : (
          <div aria-busy={loading}>
            <section className="det-block" aria-labelledby="d-cus">
              <h3 id="d-cus">Khách hàng</h3>
              <dl className="kv">
                <dt>Tài khoản</dt>
                <dd>{b.customerName || '—'}</dd>
                <dt>Email tài khoản</dt>
                <dd>{b.customerEmail || '—'}</dd>
              </dl>
            </section>

            <section className="det-block" aria-labelledby="d-contact">
              <h3 id="d-contact">Người liên hệ nhận tour</h3>
              <dl className="kv">
                <dt>Họ tên</dt>
                <dd>{b.contactName}</dd>
                <dt>Điện thoại</dt>
                <dd>
                  <a href={`tel:${b.contactPhone}`}>{b.contactPhone}</a>
                </dd>
                <dt>Email</dt>
                <dd>
                  <a href={`mailto:${b.contactEmail}`}>{b.contactEmail}</a>
                </dd>
                <dt>Yêu cầu đặc biệt</dt>
                <dd>{b.specialRequest || 'Không có'}</dd>
              </dl>
            </section>

            <section className="det-block" aria-labelledby="d-items">
              <h3 id="d-items">Tour đã đặt</h3>
              <ul className="det-items">
                {b.items?.map((it, i) => (
                  <li key={`${it.tourId}-${i}`} className="det-item">
                    {it.imageUrl ? <img src={it.imageUrl} alt="" loading="lazy" /> : <span className="thumb-ph" aria-hidden="true" />}
                    <div>
                      <h4>{it.tourName}</h4>
                      <p>Khởi hành {fmtDateTime(it.departureDate)}</p>
                      <p className="num">
                        {it.adultQuantity} người lớn × {money(it.adultPrice)}
                        {it.childQuantity > 0 && ` · ${it.childQuantity} trẻ em × ${money(it.childPrice)}`}
                      </p>
                    </div>
                    <strong className="num">{money(it.subtotal)}</strong>
                  </li>
                ))}
              </ul>
              <div className="det-total">
                <span>Tổng cộng</span>
                <strong className="num">{money(b.totalAmount)}</strong>
              </div>
            </section>

            <section className="det-block" aria-labelledby="d-pay">
              <h3 id="d-pay">Thanh toán</h3>
              <dl className="kv">
                <dt>Trạng thái</dt>
                <dd>
                  <StatusTag map={PAYMENT_STATUS} value={b.paymentStatus} />
                </dd>
                <dt>Hình thức</dt>
                <dd>{METHOD[b.paymentMethod] || b.paymentMethod || '—'}</dd>
                <dt>Thanh toán lúc</dt>
                <dd>{b.paidAt ? fmtDateTime(b.paidAt) : '—'}</dd>
              </dl>
            </section>

            <section className="det-block" aria-labelledby="d-log">
              <h3 id="d-log">Tiến trình đơn</h3>
              <StatusTimeline b={b} />
            </section>
          </div>
        )}
      </Modal>

      {cancelling && b && (
        <CancelReasonModal booking={b} onClose={() => setCancelling(false)} onSubmit={(reason) => setConfirm({ type: 'cancel', reason })} />
      )}

      <ConfirmDialog
        open={Boolean(cfg)}
        danger={Boolean(cfg?.danger)}
        title={cfg?.title ?? ''}
        message={cfg && b ? cfg.message(b, confirm.reason) : ''}
        confirmLabel={cfg?.label}
        onConfirm={run}
        onCancel={() => setConfirm(null)}
      />
    </>
  )
}

/* ------------------------------ Trang ------------------------------ */

export default function AdminBookings() {
  const [params, setParams] = useSearchParams()
  const initialStatus = BOOKING_STATUS[params.get('status')] ? params.get('status') : ''
  const list = useListPage((p) => adminApi.bookings(p), {
    keyword: '',
    bookingStatus: initialStatus,
    paymentStatus: '',
    from: '',
    to: '',
  })
  const openId = params.get('open')

  const openDrawer = (id) => {
    const next = new URLSearchParams(params)
    next.set('open', id)
    setParams(next)
  }
  const closeDrawer = () => {
    const next = new URLSearchParams(params)
    next.delete('open')
    setParams(next, { replace: true })
  }

  const f = list.filters
  const rangeBad = f.from && f.to && f.from > f.to

  return (
    <>
      <div className="admin-head">
        <div>
          <h1>Đơn đặt tour</h1>
          <p>Xác nhận, hoàn tất hoặc hủy đơn; ghi nhận thanh toán thu tại văn phòng.</p>
        </div>
      </div>

      <div className="toolbar" role="search">
        <SearchBox
          label="Tìm đơn"
          value={f.keyword}
          onChange={(v) => list.setFilter({ keyword: v })}
          placeholder="Mã đơn, tên hoặc email khách…"
        />
        <div className="form-field">
          <label htmlFor="b-status">Trạng thái đơn</label>
          <select id="b-status" className="input" value={f.bookingStatus} onChange={(e) => list.setFilter({ bookingStatus: e.target.value })}>
            <option value="">Tất cả</option>
            {Object.entries(BOOKING_STATUS).map(([v, s]) => (
              <option key={v} value={v}>
                {s.label}
              </option>
            ))}
          </select>
        </div>
        <div className="form-field">
          <label htmlFor="b-pay">Thanh toán</label>
          <select id="b-pay" className="input" value={f.paymentStatus} onChange={(e) => list.setFilter({ paymentStatus: e.target.value })}>
            <option value="">Tất cả</option>
            {Object.entries(PAYMENT_STATUS).map(([v, s]) => (
              <option key={v} value={v}>
                {s.label}
              </option>
            ))}
          </select>
        </div>
        <div className="range">
          <Field label="Từ ngày" error={rangeBad ? 'Phải trước ngày kết thúc.' : ''}>
            <input type="date" className="input" value={f.from} max={f.to || undefined} onChange={(e) => list.setFilter({ from: e.target.value })} />
          </Field>
          <Field label="Đến ngày">
            <input type="date" className="input" value={f.to} min={f.from || undefined} onChange={(e) => list.setFilter({ to: e.target.value })} />
          </Field>
        </div>
        {list.filtered && (
          <button type="button" className="btn btn-ghost" onClick={list.reset}>
            Xóa bộ lọc
          </button>
        )}
      </div>

      {list.error ? (
        <ErrorState message={list.error} onRetry={list.reload} />
      ) : !list.firstLoad && list.rows.length === 0 ? (
        <EmptyState title={list.filtered ? 'Không có đơn phù hợp' : 'Chưa có đơn đặt tour nào'}>
          <p>{list.filtered ? 'Thử đổi từ khóa, khoảng ngày hoặc bỏ bớt bộ lọc.' : 'Khi khách đặt tour, đơn sẽ hiện ở đây.'}</p>
          {list.filtered && (
            <button type="button" className="btn btn-outline" onClick={list.reset}>
              Xóa bộ lọc
            </button>
          )}
        </EmptyState>
      ) : (
        <>
          <div className="table-wrap" aria-busy={list.refreshing} tabIndex={0} role="region" aria-label="Bảng đơn đặt tour">
            <table className="table table--wide">
              <thead>
                <tr>
                  <th scope="col">Mã đơn</th>
                  <th scope="col">Khách hàng</th>
                  <th scope="col">Tour</th>
                  <th scope="col" className="r">
                    Tổng tiền
                  </th>
                  <th scope="col">Đơn</th>
                  <th scope="col">Thanh toán</th>
                  <th scope="col">
                    <span className="visually-hidden">Thao tác</span>
                  </th>
                </tr>
              </thead>
              <tbody>
                {list.firstLoad ? (
                  <SkeletonRows cols={7} />
                ) : (
                  list.rows.map((b) => (
                    <tr key={b.id}>
                      <td className="nowrap">
                        <button type="button" className="link-cell" onClick={() => openDrawer(b.id)}>
                          {b.bookingCode}
                        </button>
                        <span className="cell-sub">{fmtDate(b.createdAt)}</span>
                      </td>
                      <td>
                        <span className="cell-main">{b.customerName || '—'}</span>
                        <span className="cell-sub">{b.customerEmail}</span>
                      </td>
                      <td>
                        <span className="clamp-ink">
                          {b.firstTourName}
                        </span>
                        {b.itemCount > 1 && <span className="cell-sub">và {b.itemCount - 1} tour khác</span>}
                      </td>
                      <td className="r num nowrap">{money(b.totalAmount)}</td>
                      <td>
                        <StatusTag map={BOOKING_STATUS} value={b.bookingStatus} />
                      </td>
                      <td>
                        <StatusTag map={PAYMENT_STATUS} value={b.paymentStatus} />
                      </td>
                      <td>
                        <div className="icon-actions">
                          <button
                            type="button"
                            className="btn btn-ghost btn-icon"
                            onClick={() => openDrawer(b.id)}
                            aria-label={`Xem chi tiết đơn ${b.bookingCode}`}
                            title="Xem chi tiết"
                          >
                            <Eye size={18} aria-hidden="true" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
          <div className="table-foot">
            <ResultCount page={list.page} size={list.size} total={list.total} count={list.rows.length} />
            <Pagination page={list.page} totalPages={list.totalPages} onChange={list.setPage} />
          </div>
        </>
      )}

      {openId && <BookingDrawer key={openId} id={openId} onClose={closeDrawer} onChanged={list.reload} />}
    </>
  )
}
