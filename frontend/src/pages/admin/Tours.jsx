import { useEffect, useRef, useState } from 'react'
import { ArrowDown, ArrowUp, ChevronDown, Image as ImageIcon, Pencil, Plus, Trash2, Upload } from 'lucide-react'
import { adminApi } from '../../api'
import { getErrorMessage } from '../../api/client'
import { TOUR_STATUS, fmtDateTime, money, parseItinerary } from '../../utils/format'
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
  fromLocalInput,
  serverFormErrors,
  toLocalInput,
  useListPage,
} from './AdminKit'

/* ------------------------------ Lịch trình <-> văn bản ------------------------------ */

let rowSeq = 0
const newDay = (title = '', body = '') => ({ key: ++rowSeq, title, body })

/** Văn bản hợp đồng -> danh sách ngày để biên tập. */
function itineraryToRows(text) {
  const parsed = parseItinerary(text)
  return parsed.map((d) => newDay(d.title, d.body))
}

/** Danh sách ngày -> "Ngày N: Tiêu đề\nMô tả" cách nhau 1 dòng trống. */
function rowsToItinerary(rows) {
  return rows
    .filter((r) => r.title.trim() || r.body.trim())
    .map((r, i) => {
      const body = r.body.replace(/\r/g, '').split('\n').map((l) => l.trim()).filter(Boolean).join('\n')
      return `Ngày ${i + 1}: ${r.title.trim()}${body ? `\n${body}` : ''}`
    })
    .join('\n\n')
}

/* ------------------------------ Form tour ------------------------------ */

const EMPTY = {
  categoryId: '',
  tourCode: '',
  name: '',
  departureLocation: '',
  destination: '',
  duration: '',
  transport: '',
  departureDate: '',
  adultPrice: '',
  childPrice: '',
  totalSeats: '',
  imageUrl: '',
  shortDescription: '',
  status: 'ACTIVE',
}

const fromTour = (t) => ({
  categoryId: t.categoryId != null ? String(t.categoryId) : '',
  tourCode: t.tourCode ?? '',
  name: t.name ?? '',
  departureLocation: t.departureLocation ?? '',
  destination: t.destination ?? '',
  duration: t.duration ?? '',
  transport: t.transport ?? '',
  departureDate: toLocalInput(t.departureDate),
  adultPrice: t.adultPrice != null ? String(t.adultPrice) : '',
  childPrice: t.childPrice != null ? String(t.childPrice) : '',
  totalSeats: t.totalSeats != null ? String(t.totalSeats) : '',
  imageUrl: t.imageUrl ?? '',
  shortDescription: t.shortDescription ?? '',
  status: t.status ?? 'ACTIVE',
})

function validate(f, days) {
  const e = {}
  if (!f.categoryId) e.categoryId = 'Vui lòng chọn danh mục.'
  if (!f.tourCode.trim()) e.tourCode = 'Vui lòng nhập mã tour.'
  if (!f.name.trim()) e.name = 'Vui lòng nhập tên tour.'
  if (!f.departureLocation.trim()) e.departureLocation = 'Vui lòng nhập nơi khởi hành.'
  if (!f.destination.trim()) e.destination = 'Vui lòng nhập điểm đến.'
  if (!f.duration.trim()) e.duration = 'Vui lòng nhập thời lượng, ví dụ “3 ngày 2 đêm”.'
  if (!f.transport.trim()) e.transport = 'Vui lòng nhập phương tiện.'
  if (!f.departureDate) e.departureDate = 'Vui lòng chọn ngày giờ khởi hành.'
  const adult = Number(f.adultPrice)
  const child = Number(f.childPrice)
  if (f.adultPrice === '' || !(adult > 0)) e.adultPrice = 'Giá người lớn phải lớn hơn 0.'
  if (f.childPrice === '' || child < 0) e.childPrice = 'Giá trẻ em không được âm.'
  else if (!e.adultPrice && child > adult) e.childPrice = 'Giá trẻ em không được cao hơn giá người lớn.'
  const seats = Number(f.totalSeats)
  if (f.totalSeats === '' || !Number.isInteger(seats) || seats < 1) e.totalSeats = 'Tổng số chỗ phải là số nguyên từ 1 trở lên.'
  days.forEach((d, i) => {
    if (d.body.trim() && !d.title.trim()) e[`day${d.key}`] = `Ngày ${i + 1} cần có tiêu đề.`
  })
  return e
}

function ImageField({ value, onChange, error }) {
  const toast = useToast()
  const fileRef = useRef(null)
  const [uploading, setUploading] = useState(false)
  const [broken, setBroken] = useState(false)

  useEffect(() => setBroken(false), [value])

  const pick = async (e) => {
    const file = e.target.files?.[0]
    e.target.value = ''
    if (!file) return
    if (!/^image\/(jpeg|png|webp)$/.test(file.type)) return toast.error('Chỉ nhận ảnh JPG, PNG hoặc WebP.')
    if (file.size > 5 * 1024 * 1024) return toast.error('Ảnh vượt quá 5MB, hãy chọn ảnh nhỏ hơn.')
    setUploading(true)
    try {
      const { url } = await adminApi.upload(file)
      onChange(url)
      toast.success('Đã tải ảnh lên.')
    } catch (err) {
      toast.error(getErrorMessage(err, 'Không tải được ảnh lên.'))
    } finally {
      setUploading(false)
    }
  }

  return (
    <div className="img-field">
      <div className="img-field__preview">
        {value && !broken ? (
          <img src={value} alt="Ảnh đại diện tour" onError={() => setBroken(true)} />
        ) : (
          <span>
            <ImageIcon size={26} aria-hidden="true" style={{ display: 'block', margin: '0 auto 4px' }} />
            {broken ? 'Không hiển thị được ảnh từ đường dẫn này' : 'Chưa có ảnh'}
          </span>
        )}
      </div>
      <div className="img-field__controls">
        <div className="img-field__row">
          <input ref={fileRef} type="file" accept="image/jpeg,image/png,image/webp" hidden onChange={pick} />
          <button type="button" className="btn btn-outline btn-sm" disabled={uploading} onClick={() => fileRef.current?.click()}>
            {uploading ? <span className="spinner" aria-hidden="true" /> : <Upload size={16} aria-hidden="true" />}
            {uploading ? 'Đang tải lên…' : 'Tải ảnh từ máy'}
          </button>
          {value && (
            <button type="button" className="btn btn-ghost btn-sm" onClick={() => onChange('')}>
              Bỏ ảnh
            </button>
          )}
          <span className="field-hint">JPG, PNG, WebP tối đa 5MB.</span>
        </div>
        <Field label="Hoặc dán đường dẫn ảnh" error={error}>
          <input className="input" type="text" inputMode="url" placeholder="https://… hoặc /uploads/anh.jpg" value={value} onChange={(e) => onChange(e.target.value)} />
        </Field>
      </div>
    </div>
  )
}

function ItineraryEditor({ days, setDays, errors }) {
  const move = (i, dir) =>
    setDays((list) => {
      const next = [...list]
      const j = i + dir
      if (j < 0 || j >= next.length) return list
      ;[next[i], next[j]] = [next[j], next[i]]
      return next
    })
  const patch = (key, field, v) => setDays((list) => list.map((d) => (d.key === key ? { ...d, [field]: v } : d)))

  return (
    <div>
      {days.length === 0 ? (
        <p className="muted">Chưa có ngày nào. Thêm từng ngày để khách xem hành trình chi tiết.</p>
      ) : (
        <ol className="itin">
          {days.map((d, i) => {
            const err = errors[`day${d.key}`]
            return (
              <li key={d.key} className="itin__row">
                <div className="itin__day">
                  Ngày<b>{i + 1}</b>
                </div>
                <div className="itin__fields">
                  <Field label={`Tiêu đề ngày ${i + 1}`} error={err}>
                    <input className="input input--sm" value={d.title} onChange={(e) => patch(d.key, 'title', e.target.value)} placeholder="Ví dụ: Hà Nội – Sa Pa" />
                  </Field>
                  <Field label={`Mô tả ngày ${i + 1}`}>
                    <textarea className="input input--sm" value={d.body} onChange={(e) => patch(d.key, 'body', e.target.value)} rows={3} placeholder="Các hoạt động trong ngày…" />
                  </Field>
                </div>
                <div className="itin__tools">
                  <button type="button" className="btn btn-ghost btn-icon" onClick={() => move(i, -1)} disabled={i === 0} aria-label={`Chuyển ngày ${i + 1} lên trên`} title="Lên">
                    <ArrowUp size={18} aria-hidden="true" />
                  </button>
                  <button type="button" className="btn btn-ghost btn-icon" onClick={() => move(i, 1)} disabled={i === days.length - 1} aria-label={`Chuyển ngày ${i + 1} xuống dưới`} title="Xuống">
                    <ArrowDown size={18} aria-hidden="true" />
                  </button>
                  <button type="button" className="btn btn-ghost btn-icon" onClick={() => setDays((l) => l.filter((x) => x.key !== d.key))} aria-label={`Xóa ngày ${i + 1}`} title="Xóa ngày">
                    <Trash2 size={18} aria-hidden="true" />
                  </button>
                </div>
              </li>
            )
          })}
        </ol>
      )}
      <button type="button" className="btn btn-outline btn-sm" style={{ marginTop: 'var(--s3)' }} onClick={() => setDays((l) => [...l, newDay()])}>
        <Plus size={16} aria-hidden="true" />
        Thêm ngày
      </button>
    </div>
  )
}

function TourModal({ id, categories, onClose, onSaved }) {
  const toast = useToast()
  const detail = useAsync(() => (id ? adminApi.tour(id) : Promise.resolve(null)), [id])
  const [form, setForm] = useState(id ? null : EMPTY)
  const [days, setDays] = useState(() => (id ? [] : [newDay()]))
  const [errors, setErrors] = useState({})
  const [formError, setFormError] = useState('')
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (id && detail.data) {
      setForm(fromTour(detail.data))
      setDays(itineraryToRows(detail.data.itinerary))
    }
  }, [id, detail.data])

  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))
  const t = detail.data
  const booked = t ? (t.totalSeats ?? 0) - (t.availableSeats ?? 0) : 0

  const submit = async (e) => {
    e.preventDefault()
    const found = validate(form, days)
    setErrors(found)
    setFormError('')
    if (Object.keys(found).length) {
      setFormError('Còn trường chưa hợp lệ, vui lòng kiểm tra các mục được đánh dấu.')
      requestAnimationFrame(() => document.querySelector('.adm-modal [aria-invalid="true"]')?.focus())
      return
    }
    const body = {
      categoryId: Number(form.categoryId),
      tourCode: form.tourCode.trim(),
      name: form.name.trim(),
      departureLocation: form.departureLocation.trim(),
      destination: form.destination.trim(),
      duration: form.duration.trim(),
      transport: form.transport.trim(),
      departureDate: fromLocalInput(form.departureDate),
      adultPrice: Number(form.adultPrice),
      childPrice: Number(form.childPrice),
      totalSeats: Number(form.totalSeats),
      imageUrl: form.imageUrl.trim() || null,
      shortDescription: form.shortDescription.trim(),
      itinerary: rowsToItinerary(days),
      status: form.status,
    }
    setSaving(true)
    try {
      if (id) await adminApi.updateTour(id, body)
      else await adminApi.createTour(body)
      toast.success(id ? 'Đã cập nhật tour.' : 'Đã thêm tour mới.')
      onSaved()
    } catch (err) {
      const r = serverFormErrors(err, 'tourCode')
      setErrors(r.errors)
      setFormError(r.message)
    } finally {
      setSaving(false)
    }
  }

  const ready = Boolean(form)

  return (
    <Modal
      wide
      title={id ? 'Sửa tour' : 'Thêm tour mới'}
      subtitle={t ? `${t.tourCode} · đã đặt ${booked}/${t.totalSeats} chỗ` : undefined}
      onClose={onClose}
      busy={saving}
      footer={
        ready && (
          <>
            <button type="button" className="btn btn-outline" onClick={onClose} disabled={saving}>
              Hủy bỏ
            </button>
            <SubmitButton form="tour-form" busy={saving}>
              {id ? 'Lưu thay đổi' : 'Thêm tour'}
            </SubmitButton>
          </>
        )
      }
    >
      {detail.error ? (
        <ErrorState message={detail.error} onRetry={detail.reload} />
      ) : !ready ? (
        <div aria-busy="true">
          <span className="visually-hidden" role="status">
            Đang tải thông tin tour
          </span>
          {[60, 60, 60, 140].map((h, i) => (
            <div key={i} className="skeleton" style={{ height: h, marginBottom: 16 }} />
          ))}
        </div>
      ) : (
        <form id="tour-form" onSubmit={submit} noValidate>
          {formError && (
            <div className="alert alert-error" role="alert" style={{ marginBottom: 'var(--s4)' }}>
              {formError}
            </div>
          )}

          <section className="form-section" aria-label="Thông tin chung">
            <h3>Thông tin chung</h3>
            <div className="form-row">
              <Field label="Mã tour" required error={errors.tourCode} hint="Duy nhất, ví dụ DN-0612.">
                <input className="input" value={form.tourCode} onChange={set('tourCode')} maxLength={30} autoFocus autoComplete="off" />
              </Field>
              <Field label="Danh mục" required error={errors.categoryId}>
                <select className="input" value={form.categoryId} onChange={set('categoryId')}>
                  <option value="">Chọn danh mục…</option>
                  {categories.map((c) => (
                    <option key={c.id} value={c.id}>
                      {c.name}
                      {c.status === 'INACTIVE' ? ' (đang ẩn)' : ''}
                    </option>
                  ))}
                </select>
              </Field>
            </div>
            <Field label="Tên tour" required error={errors.name}>
              <input className="input" value={form.name} onChange={set('name')} maxLength={200} />
            </Field>
            <Field label="Mô tả ngắn" error={errors.shortDescription} hint="Hiện trên thẻ tour ở trang khách, nên viết 1–2 câu.">
              <textarea className="input input--sm" value={form.shortDescription} onChange={set('shortDescription')} maxLength={500} />
            </Field>
            <Field label="Trạng thái" error={errors.status}>
              <select className="input" value={form.status} onChange={set('status')}>
                {Object.entries(TOUR_STATUS).map(([v, s]) => (
                  <option key={v} value={v}>
                    {s.label}
                  </option>
                ))}
              </select>
            </Field>
          </section>

          <section className="form-section" aria-label="Hành trình">
            <h3>Hành trình</h3>
            <div className="form-row">
              <Field label="Nơi khởi hành" required error={errors.departureLocation}>
                <input className="input" value={form.departureLocation} onChange={set('departureLocation')} />
              </Field>
              <Field label="Điểm đến" required error={errors.destination}>
                <input className="input" value={form.destination} onChange={set('destination')} />
              </Field>
            </div>
            <div className="form-row-3 form-row">
              <Field label="Thời lượng" required error={errors.duration}>
                <input className="input" value={form.duration} onChange={set('duration')} placeholder="3 ngày 2 đêm" />
              </Field>
              <Field label="Phương tiện" required error={errors.transport}>
                <input className="input" list="transport-list" value={form.transport} onChange={set('transport')} />
              </Field>
              <Field label="Khởi hành" required error={errors.departureDate}>
                <input className="input" type="datetime-local" value={form.departureDate} onChange={set('departureDate')} />
              </Field>
            </div>
            <datalist id="transport-list">
              <option value="Máy bay" />
              <option value="Ô tô" />
              <option value="Tàu hỏa" />
              <option value="Tàu thủy" />
            </datalist>
          </section>

          <section className="form-section" aria-label="Giá và số chỗ">
            <h3>Giá và số chỗ</h3>
            <div className="form-row-3 form-row">
              <Field label="Giá người lớn (đ)" required error={errors.adultPrice} hint={Number(form.adultPrice) > 0 ? money(form.adultPrice) : undefined}>
                <input className="input" type="number" min="0" step="1000" inputMode="numeric" value={form.adultPrice} onChange={set('adultPrice')} />
              </Field>
              <Field label="Giá trẻ em (đ)" required error={errors.childPrice} hint={form.childPrice !== '' && Number(form.childPrice) >= 0 ? money(form.childPrice) : 'Không cao hơn giá người lớn.'}>
                <input className="input" type="number" min="0" step="1000" inputMode="numeric" value={form.childPrice} onChange={set('childPrice')} />
              </Field>
              <Field
                label="Tổng số chỗ"
                required
                error={errors.totalSeats}
                hint={id ? `Đã đặt ${booked} chỗ, không thể đặt thấp hơn số này.` : undefined}
              >
                <input className="input" type="number" min="1" step="1" inputMode="numeric" value={form.totalSeats} onChange={set('totalSeats')} />
              </Field>
            </div>
          </section>

          <section className="form-section" aria-label="Hình ảnh">
            <h3>Hình ảnh đại diện</h3>
            <ImageField value={form.imageUrl} onChange={(v) => setForm((f) => ({ ...f, imageUrl: v }))} error={errors.imageUrl} />
          </section>

          <section className="form-section" aria-label="Lịch trình">
            <h3>Lịch trình theo ngày</h3>
            <p className="form-section__intro">Số ngày được đánh tự động theo thứ tự. Dùng mũi tên để đổi vị trí.</p>
            <ItineraryEditor days={days} setDays={setDays} errors={errors} />
            {errors.itinerary && <span className="field-error">{errors.itinerary}</span>}
          </section>
        </form>
      )}
    </Modal>
  )
}

/* ------------------------------ Menu đổi trạng thái nhanh ------------------------------ */

function StatusMenu({ tour, busy, onPick }) {
  const [pos, setPos] = useState(null)
  const btnRef = useRef(null)
  const popRef = useRef(null)
  const open = Boolean(pos)

  useEffect(() => {
    if (!open) return
    const close = () => setPos(null)
    const onDown = (e) => {
      if (!popRef.current?.contains(e.target) && !btnRef.current?.contains(e.target)) close()
    }
    const onKey = (e) => {
      if (e.key === 'Escape') {
        e.stopPropagation()
        close()
        btnRef.current?.focus()
      }
    }
    document.addEventListener('mousedown', onDown)
    document.addEventListener('keydown', onKey)
    window.addEventListener('resize', close)
    window.addEventListener('scroll', close, true)
    popRef.current?.querySelector('[aria-checked="true"]')?.focus()
    return () => {
      document.removeEventListener('mousedown', onDown)
      document.removeEventListener('keydown', onKey)
      window.removeEventListener('resize', close)
      window.removeEventListener('scroll', close, true)
    }
  }, [open])

  const toggle = () => {
    if (open) return setPos(null)
    const r = btnRef.current.getBoundingClientRect()
    const above = r.bottom + 170 > window.innerHeight
    setPos(above ? { bottom: window.innerHeight - r.top + 4, left: r.left } : { top: r.bottom + 4, left: r.left })
  }

  const onMenuKey = (e) => {
    if (e.key !== 'ArrowDown' && e.key !== 'ArrowUp') return
    e.preventDefault()
    const items = [...popRef.current.querySelectorAll('button')]
    const i = items.indexOf(document.activeElement)
    items[(i + (e.key === 'ArrowDown' ? 1 : -1) + items.length) % items.length]?.focus()
  }

  const s = TOUR_STATUS[tour.status] || { label: tour.status, tone: 'muted' }
  return (
    <>
      <button
        ref={btnRef}
        type="button"
        className={`tag tag-${s.tone} tag-btn`}
        aria-haspopup="menu"
        aria-expanded={open}
        aria-label={`Trạng thái: ${s.label}. Nhấn để đổi`}
        disabled={busy}
        onClick={toggle}
      >
        {s.label}
        <ChevronDown size={14} aria-hidden="true" />
      </button>
      {open && (
        <div ref={popRef} className="menu-pop" role="menu" aria-label="Đổi trạng thái tour" style={pos} onKeyDown={onMenuKey}>
          {Object.entries(TOUR_STATUS).map(([v, st]) => (
            <button
              key={v}
              type="button"
              role="menuitemradio"
              aria-checked={v === tour.status}
              onClick={() => {
                setPos(null)
                btnRef.current?.focus()
                if (v !== tour.status) onPick(v)
              }}
            >
              {st.label}
              {v === tour.status && <span aria-hidden="true">✓</span>}
            </button>
          ))}
        </div>
      )}
    </>
  )
}

/* ------------------------------ Trang ------------------------------ */

export default function AdminTours() {
  const toast = useToast()
  const list = useListPage((p) => adminApi.tours(p), { keyword: '', categoryId: '', status: '' })
  const cats = useAsync(() => adminApi.categoryOptions(), [])
  const [editing, setEditing] = useState(null) // null | { id? }
  const [deleting, setDeleting] = useState(null)
  const [busyId, setBusyId] = useState(null)

  const categories = cats.data ?? []

  const changeStatus = async (tour, status) => {
    setBusyId(tour.id)
    try {
      await adminApi.setTourStatus(tour.id, status)
      toast.success(`Đã chuyển “${tour.name}” sang ${TOUR_STATUS[status].label.toLowerCase()}.`)
      list.reload()
    } catch (err) {
      toast.error(getErrorMessage(err, 'Không đổi được trạng thái tour.'))
    } finally {
      setBusyId(null)
    }
  }

  const doDelete = async () => {
    const target = deleting
    setDeleting(null)
    try {
      await adminApi.deleteTour(target.id)
      toast.success(`Đã xóa tour “${target.name}”.`)
      list.reload()
    } catch (err) {
      // 409: tour đã có đơn đặt
      toast.error(getErrorMessage(err, 'Không thể xóa tour này.'))
    }
  }

  const saved = () => {
    setEditing(null)
    list.reload()
  }

  return (
    <>
      <div className="admin-head">
        <div>
          <span className="eyebrow">Sản phẩm</span>
          <h1>Quản lý tour</h1>
          <p>Thêm tour, cập nhật giá, số chỗ, lịch trình và đóng/mở bán nhanh ngay trên danh sách.</p>
        </div>
        <div className="admin-head__actions">
          <button type="button" className="btn btn-accent" onClick={() => setEditing({})}>
            <Plus size={18} aria-hidden="true" />
            Thêm tour
          </button>
        </div>
      </div>

      <div className="toolbar" role="search">
        <SearchBox
          label="Tìm tour"
          value={list.filters.keyword}
          onChange={(v) => list.setFilter({ keyword: v })}
          placeholder="Tên, điểm đến hoặc mã tour…"
        />
        <div className="form-field">
          <label htmlFor="t-cat">Danh mục</label>
          <select id="t-cat" className="input" value={list.filters.categoryId} onChange={(e) => list.setFilter({ categoryId: e.target.value })}>
            <option value="">Tất cả</option>
            {categories.map((c) => (
              <option key={c.id} value={c.id}>
                {c.name}
              </option>
            ))}
          </select>
        </div>
        <div className="form-field">
          <label htmlFor="t-status">Trạng thái</label>
          <select id="t-status" className="input" value={list.filters.status} onChange={(e) => list.setFilter({ status: e.target.value })}>
            <option value="">Tất cả</option>
            {Object.entries(TOUR_STATUS).map(([v, s]) => (
              <option key={v} value={v}>
                {s.label}
              </option>
            ))}
          </select>
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
        <EmptyState title={list.filtered ? 'Không có tour phù hợp' : 'Chưa có tour nào'}>
          <p>{list.filtered ? 'Thử đổi từ khóa hoặc bỏ bớt bộ lọc.' : 'Thêm tour đầu tiên để bắt đầu mở bán.'}</p>
          {list.filtered ? (
            <button type="button" className="btn btn-outline" onClick={list.reset}>
              Xóa bộ lọc
            </button>
          ) : (
            <button type="button" className="btn btn-primary" onClick={() => setEditing({})}>
              Thêm tour
            </button>
          )}
        </EmptyState>
      ) : (
        <>
          <div className="table-wrap" aria-busy={list.refreshing} tabIndex={0} role="region" aria-label="Bảng tour">
            <table className="table table--wide" style={{ minWidth: 980 }}>
              <thead>
                <tr>
                  <th scope="col">Ảnh</th>
                  <th scope="col">Mã</th>
                  <th scope="col">Tên tour</th>
                  <th scope="col">Danh mục</th>
                  <th scope="col">Khởi hành</th>
                  <th scope="col" className="r">
                    Giá người lớn
                  </th>
                  <th scope="col" className="r">
                    Chỗ còn/tổng
                  </th>
                  <th scope="col">Trạng thái</th>
                  <th scope="col">
                    <span className="visually-hidden">Thao tác</span>
                  </th>
                </tr>
              </thead>
              <tbody>
                {list.firstLoad ? (
                  <SkeletonRows cols={9} thumbCol={0} />
                ) : (
                  list.rows.map((t) => (
                    <tr key={t.id}>
                      <td>
                        {t.imageUrl ? <img className="thumb" src={t.imageUrl} alt="" loading="lazy" /> : <span className="thumb-ph" aria-hidden="true"><ImageIcon size={18} /></span>}
                      </td>
                      <td className="nowrap num">{t.tourCode}</td>
                      <td style={{ minWidth: 220 }}>
                        <span className="cell-main">{t.name}</span>
                        <span className="cell-sub">
                          {t.departureLocation} → {t.destination} · {t.duration}
                        </span>
                      </td>
                      <td>{t.categoryName}</td>
                      <td className="nowrap num">{fmtDateTime(t.departureDate)}</td>
                      <td className="r num nowrap">
                        {money(t.adultPrice)}
                        <span className="cell-sub">Trẻ em {money(t.childPrice)}</span>
                      </td>
                      <td className="r num nowrap">
                        <strong>{t.availableSeats}</strong> / {t.totalSeats}
                        {t.availableSeats === 0 && <span className="cell-sub">Hết chỗ</span>}
                      </td>
                      <td>
                        <StatusMenu tour={t} busy={busyId === t.id} onPick={(s) => changeStatus(t, s)} />
                      </td>
                      <td>
                        <div className="icon-actions">
                          <button type="button" className="btn btn-ghost btn-icon" onClick={() => setEditing({ id: t.id })} aria-label={`Sửa tour ${t.name}`} title="Sửa">
                            <Pencil size={18} aria-hidden="true" />
                          </button>
                          <button type="button" className="btn btn-ghost btn-icon" onClick={() => setDeleting(t)} aria-label={`Xóa tour ${t.name}`} title="Xóa">
                            <Trash2 size={18} aria-hidden="true" />
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

      {editing && <TourModal id={editing.id} categories={categories} onClose={() => setEditing(null)} onSaved={saved} />}

      <ConfirmDialog
        open={Boolean(deleting)}
        danger
        title="Xóa tour?"
        message={deleting ? `Tour “${deleting.name}” (${deleting.tourCode}) sẽ bị xóa vĩnh viễn. Tour đã có đơn đặt không thể xóa, hãy chuyển sang “Tạm đóng” thay vì xóa.` : ''}
        confirmLabel="Xóa tour"
        onConfirm={doDelete}
        onCancel={() => setDeleting(null)}
      />
    </>
  )
}
