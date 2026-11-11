import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { Minus, Plus, Trash2 } from 'lucide-react'
import { useCart } from '../context/CartContext'
import { useAuth } from '../context/AuthContext'
import { useToast } from '../components/Toast'
import ConfirmDialog from '../components/ConfirmDialog'
import { getErrorMessage } from '../api/client'
import { fmtDate, money } from '../utils/format'
import { track } from '../tracking/tracker'

function Qty({ label, value, min, max, disabled, onChange }) {
  return (
    <div className="stepper" role="group" aria-label={label}>
      <button type="button" disabled={disabled || value <= min} onClick={() => onChange(value - 1)} aria-label={`Giảm ${label}`}>
        <Minus size={15} aria-hidden="true" />
      </button>
      <output>{value}</output>
      <button type="button" disabled={disabled || value >= max} onClick={() => onChange(value + 1)} aria-label={`Tăng ${label}`}>
        <Plus size={15} aria-hidden="true" />
      </button>
    </div>
  )
}

export default function Cart() {
  const { cart, loading, update, remove, clear } = useCart()
  const { isAuthenticated } = useAuth()
  const navigate = useNavigate()
  const toast = useToast()
  const [busyId, setBusyId] = useState(null)
  const [confirm, setConfirm] = useState(null) // { type: 'one'|'all', item? }

  const change = async (item, patch) => {
    setBusyId(item.tourId)
    try {
      await update(item.tourId, {
        adultQuantity: patch.adultQuantity ?? item.adultQuantity,
        childQuantity: patch.childQuantity ?? item.childQuantity,
      })
    } catch (e) {
      toast.error(getErrorMessage(e, 'Không thể cập nhật số lượng'))
    } finally {
      setBusyId(null)
    }
  }

  const doConfirm = async () => {
    const c = confirm
    setConfirm(null)
    try {
      if (c.type === 'all') await clear()
      else {
        await remove(c.item.tourId)
        track('remove_from_cart', { tourId: c.item.tourId })
      }
    } catch (e) {
      toast.error(getErrorMessage(e))
    }
  }

  const goCheckout = () => {
    if (!isAuthenticated) navigate('/login', { state: { from: '/checkout' } })
    else navigate('/checkout')
  }

  if (loading) {
    return (
      <div className="container page">
        <div className="skeleton" style={{ height: 240 }} />
      </div>
    )
  }

  if (cart.items.length === 0) {
    return (
      <div className="container page">
        <div className="empty">
          <h3>Phiếu đặt tour đang trống</h3>
          <p>Chọn một hành trình để bắt đầu, tour được lưu tạm ở đây cho đến khi bạn xác nhận đặt.</p>
          <Link to="/tours" className="btn btn-primary">
            Khám phá tour
          </Link>
        </div>
      </div>
    )
  }

  const people = cart.items.reduce((s, i) => s + i.adultQuantity + i.childQuantity, 0)

  return (
    <div className="container">
      <header className="page-head">
        <h1>Hành trình đã chọn</h1>
        <p>Kiểm tra lại số lượng trước khi xác nhận. Giá cuối cùng được tính lại ở máy chủ khi đặt tour.</p>
      </header>

      <div className="cart-layout">
        <div>
          {cart.items.map((it) => {
            const busy = busyId === it.tourId
            return (
              <article key={it.tourId} className="cart-item">
                <Link to={`/tours/${it.tourId}`} className="cart-item__img">
                  <img src={it.imageUrl} alt="" />
                </Link>
                <div>
                  <h3>
                    <Link to={`/tours/${it.tourId}`}>{it.name}</Link>
                  </h3>
                  <p className="cart-item__meta">
                    {it.tourCode} · {it.duration} · Khởi hành {fmtDate(it.departureDate)}
                  </p>
                  <div className="cart-item__qty">
                    <div>
                      <small>Người lớn · {money(it.adultPrice)}</small>
                      <Qty label="người lớn" value={it.adultQuantity} min={1} max={Math.max(1, it.availableSeats - it.childQuantity)} disabled={busy} onChange={(v) => change(it, { adultQuantity: v })} />
                    </div>
                    <div>
                      <small>Trẻ em · {money(it.childPrice ?? it.adultPrice)}</small>
                      <Qty label="trẻ em" value={it.childQuantity} min={0} max={Math.max(0, it.availableSeats - it.adultQuantity)} disabled={busy} onChange={(v) => change(it, { childQuantity: v })} />
                    </div>
                  </div>
                </div>
                <div className="cart-item__side">
                  <span className="price">{money(it.subtotal)}</span>
                  <button type="button" className="btn btn-ghost btn-sm" onClick={() => setConfirm({ type: 'one', item: it })}>
                    <Trash2 size={16} aria-hidden="true" /> Bỏ tour
                  </button>
                </div>
              </article>
            )
          })}
          <p style={{ marginTop: 'var(--s4)' }}>
            <button type="button" className="btn btn-ghost btn-sm" onClick={() => setConfirm({ type: 'all' })}>
              Xóa toàn bộ phiếu
            </button>
          </p>
        </div>

        <aside className="summary" aria-label="Tổng cộng">
          <h2 style={{ fontSize: '1.4rem' }}>Tổng cộng</h2>
          <dl>
            <div><dt>Số tour</dt><dd>{cart.items.length}</dd></div>
            <div><dt>Số khách</dt><dd>{people}</dd></div>
          </dl>
          <div className="sum-row">
            <span>Tạm tính</span>
            <strong>{money(cart.totalAmount)}</strong>
          </div>
          <button type="button" className="btn btn-accent btn-block" onClick={goCheckout}>
            {isAuthenticated ? 'Tiếp tục đặt tour' : 'Đăng nhập để đặt tour'}
          </button>
          <p className="field-hint" style={{ marginTop: 'var(--s3)' }}>
            Chỗ chỉ được giữ sau khi bạn xác nhận đặt tour ở bước tiếp theo.
          </p>
        </aside>
      </div>

      <ConfirmDialog
        open={Boolean(confirm)}
        danger
        title={confirm?.type === 'all' ? 'Xóa toàn bộ phiếu' : 'Bỏ tour khỏi phiếu'}
        message={confirm?.type === 'all' ? 'Tất cả tour trong phiếu đặt tạm sẽ bị xóa.' : `Bỏ “${confirm?.item?.name}” khỏi phiếu đặt tạm?`}
        confirmLabel="Xóa"
        onConfirm={doConfirm}
        onCancel={() => setConfirm(null)}
      />
    </div>
  )
}
