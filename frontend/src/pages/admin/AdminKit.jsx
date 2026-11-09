import { cloneElement, useEffect, useId, useRef, useState } from 'react'
import { AlertTriangle, RefreshCw, Search, X } from 'lucide-react'
import { useAsync, useDebounced } from '../../hooks/useAsync'
import { getErrorMessage, getFieldErrors } from '../../api/client'

/* =====================================================================
   Bộ phận dùng chung cho các trang quản trị
   ===================================================================== */

/** 12500000 -> "12,5 tr"; 850000 -> "850k"; 2300000000 -> "2,3 tỷ" */
export function fmtCompact(n) {
  const v = Number(n) || 0
  const trim = (x) => String(Math.round(x * 10) / 10).replace('.', ',')
  if (v >= 1e9) return `${trim(v / 1e9)} tỷ`
  if (v >= 1e6) return `${trim(v / 1e6)} tr`
  if (v >= 1e3) return `${Math.round(v / 1e3)}k`
  return String(Math.round(v))
}

/** ISO (có giờ) -> giá trị cho <input type="datetime-local"> */
export const toLocalInput = (iso) => (iso ? String(iso).slice(0, 16) : '')
/** Giá trị datetime-local -> ISO giây ("2026-12-01T07:30:00") */
export const fromLocalInput = (v) => (v ? (v.length === 16 ? `${v}:00` : v) : null)

/* ------------------------------ Danh sách phân trang ------------------------------ */

/**
 * Quản lý bộ lọc + trang hiện tại + tải dữ liệu. `keyword` (nếu có trong initial) được debounce.
 * Trả về rows/total/totalPages và các hàm setFilter / reset / setPage.
 */
export function useListPage(fetcher, initial, size = 10) {
  const [filters, setFilters] = useState(initial)
  const [page, setPage] = useState(1)
  const keyword = useDebounced(filters.keyword ?? '')
  const params = { ...filters, keyword, page, size }
  const state = useAsync(() => fetcher(params), [JSON.stringify(params)])

  const rows = state.data?.content ?? []
  const emptyPage = state.data && rows.length === 0 && page > 1
  useEffect(() => {
    if (emptyPage) setPage((p) => Math.max(1, p - 1))
  }, [emptyPage])

  return {
    ...state,
    rows,
    total: state.data?.totalElements ?? 0,
    totalPages: state.data?.totalPages ?? 0,
    page,
    setPage,
    size,
    filters,
    setFilter: (patch) => {
      setFilters((f) => ({ ...f, ...patch }))
      setPage(1)
    },
    reset: () => {
      setFilters(initial)
      setPage(1)
    },
    filtered: Object.keys(initial).some((k) => filters[k] !== initial[k]),
    firstLoad: state.loading && !state.data,
    refreshing: state.loading && Boolean(state.data),
  }
}

/* ------------------------------ Trạng thái rỗng / lỗi / tải ------------------------------ */

export function ErrorState({ message, onRetry }) {
  return (
    <div className="alert alert-error adm-error" role="alert">
      <p>
        <AlertTriangle size={18} aria-hidden="true" style={{ verticalAlign: '-3px', marginRight: 8 }} />
        {message || 'Không tải được dữ liệu.'}
      </p>
      {onRetry && (
        <button type="button" className="btn btn-outline btn-sm" onClick={onRetry}>
          <RefreshCw size={16} aria-hidden="true" />
          Thử lại
        </button>
      )}
    </div>
  )
}

export function EmptyState({ title, children }) {
  return (
    <div className="empty adm-empty">
      <h3>{title}</h3>
      {children}
    </div>
  )
}

/** Các dòng khung xương cho tbody. `cells` là mảng class tùy chọn cho từng cột. */
export function SkeletonRows({ cols, rows = 6, thumbCol = -1 }) {
  return Array.from({ length: rows }, (_, r) => (
    <tr key={r}>
      {Array.from({ length: cols }, (_, c) => (
        <td key={c}>
          {r === 0 && c === 0 && (
            <span className="visually-hidden" role="status">
              Đang tải dữ liệu
            </span>
          )}
          <span className={`sk skeleton ${c === thumbCol ? 'sk--thumb' : c % 3 === 1 ? 'sk--w60' : ''}`} />
        </td>
      ))}
    </tr>
  ))
}

/** Dòng "Hiển thị a–b / tổng" ở chân bảng. */
export function ResultCount({ page, size, total, count }) {
  if (!total) return <p />
  const from = (page - 1) * size + 1
  return (
    <p className="num" aria-live="polite">
      Hiển thị {from}–{from + count - 1} trong tổng số {total}
    </p>
  )
}

/* ------------------------------ Form ------------------------------ */

/** Nhãn + control + gợi ý/lỗi, tự nối id, aria-invalid, aria-describedby. */
export function Field({ label, error, hint, required, children, className = '', id }) {
  const auto = useId()
  const fid = id || auto
  const hintId = `${fid}-hint`
  const errId = `${fid}-err`
  const describedBy = [hint && !error ? hintId : null, error ? errId : null].filter(Boolean).join(' ') || undefined
  const control = cloneElement(children, {
    id: fid,
    'aria-invalid': error ? 'true' : undefined,
    'aria-describedby': describedBy,
    'aria-required': required ? 'true' : undefined,
  })
  return (
    <div className={`form-field ${className}`}>
      <label htmlFor={fid}>
        {label}
        {required && (
          <span className="required" aria-hidden="true">
            {' '}
            *
          </span>
        )}
      </label>
      {control}
      {hint && !error && (
        <span id={hintId} className="field-hint">
          {hint}
        </span>
      )}
      {error && (
        <span id={errId} className="field-error" role="alert">
          {error}
        </span>
      )}
    </div>
  )
}

/** Ô tìm kiếm có biểu tượng kính lúp. */
export function SearchBox({ label = 'Tìm kiếm', value, onChange, placeholder }) {
  const id = useId()
  return (
    <div className="form-field grow">
      <label htmlFor={id}>{label}</label>
      <div className="search">
        <Search size={18} aria-hidden="true" />
        <input
          id={id}
          type="search"
          className="input"
          value={value}
          placeholder={placeholder}
          onChange={(e) => onChange(e.target.value)}
        />
      </div>
    </div>
  )
}

/* ------------------------------ Hộp thoại / ngăn kéo ------------------------------ */

let scrollLocks = 0
const FOCUSABLE =
  'a[href],button:not([disabled]),input:not([disabled]):not([type="hidden"]),select:not([disabled]),textarea:not([disabled]),[tabindex]:not([tabindex="-1"])'

/**
 * Hộp thoại (hoặc ngăn kéo bên phải khi drawer). Esc đóng, Tab quay vòng trong hộp,
 * trả focus về phần tử đã mở. Nút gửi form đặt trong `footer` dùng thuộc tính form="id".
 */
export function Modal({ title, subtitle, onClose, footer, wide, drawer, busy, children }) {
  const titleId = useId()
  const panelRef = useRef(null)
  const closeRef = useRef(onClose)
  const busyRef = useRef(busy)
  closeRef.current = onClose
  busyRef.current = busy

  useEffect(() => {
    const prev = document.activeElement
    const panel = panelRef.current
    if (!panel.contains(document.activeElement)) panel.focus()
    scrollLocks += 1
    document.body.style.overflow = 'hidden'

    const onKey = (e) => {
      if (e.key !== 'Escape') return
      if (document.querySelector('[role="alertdialog"]')) return // hộp xác nhận đang nằm trên
      // chỉ hộp trên cùng xử lý Esc
      const all = document.querySelectorAll('[data-adm-dialog]')
      if (all[all.length - 1] !== panel) return
      if (!busyRef.current) closeRef.current()
    }
    document.addEventListener('keydown', onKey)
    return () => {
      document.removeEventListener('keydown', onKey)
      scrollLocks -= 1
      if (scrollLocks <= 0) document.body.style.overflow = ''
      if (prev && document.contains(prev)) prev.focus()
    }
  }, [])

  const trapTab = (e) => {
    if (e.key !== 'Tab') return
    const items = [...panelRef.current.querySelectorAll(FOCUSABLE)].filter((el) => el.offsetParent !== null)
    if (!items.length) return
    const first = items[0]
    const last = items[items.length - 1]
    if (e.shiftKey && (document.activeElement === first || document.activeElement === panelRef.current)) {
      e.preventDefault()
      last.focus()
    } else if (!e.shiftKey && document.activeElement === last) {
      e.preventDefault()
      first.focus()
    }
  }

  return (
    <div className={drawer ? 'drawer-backdrop' : 'modal-backdrop'}>
      <div
        ref={panelRef}
        data-adm-dialog=""
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        tabIndex={-1}
        className={`modal adm-modal ${wide ? 'modal--wide' : ''} ${drawer ? 'adm-drawer' : ''}`}
        onKeyDown={trapTab}
      >
        <div className="adm-modal__head">
          <div>
            <h2 id={titleId}>{title}</h2>
            {subtitle && <div className="adm-modal__sub">{subtitle}</div>}
          </div>
          <button type="button" className="btn btn-ghost btn-icon" aria-label="Đóng" onClick={onClose} disabled={busy}>
            <X size={22} aria-hidden="true" />
          </button>
        </div>
        <div className="adm-modal__body">{children}</div>
        {footer && <div className="adm-modal__foot">{footer}</div>}
      </div>
    </div>
  )
}

/** Nút có spinner khi đang gửi. */
export function SubmitButton({ busy, children, className = 'btn btn-primary', form, ...rest }) {
  return (
    <button type="submit" form={form} className={className} disabled={busy} {...rest}>
      {busy && <span className="spinner" aria-hidden="true" />}
      {children}
    </button>
  )
}

/**
 * Chuyển lỗi axios của backend thành { errors, message } cho form.
 * 409 (trùng tên / mã) được gắn vào trường `conflictField` nếu có.
 */
export function serverFormErrors(err, conflictField) {
  const fieldErrors = getFieldErrors(err)
  const message = getErrorMessage(err)
  const errors = { ...fieldErrors }
  if (err?.response?.status === 409 && conflictField) errors[conflictField] = message
  const hasFields = Object.keys(errors).length > 0
  return { errors, message: hasFields ? 'Vui lòng kiểm tra lại các trường được đánh dấu.' : message }
}
