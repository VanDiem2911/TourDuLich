import { ChevronLeft, ChevronRight } from 'lucide-react'

/** Phân trang 1-based, rút gọn bằng dấu … khi nhiều trang. */
export default function Pagination({ page, totalPages, onChange }) {
  if (!totalPages || totalPages <= 1) return null
  const pages = []
  for (let p = 1; p <= totalPages; p++) {
    if (p === 1 || p === totalPages || Math.abs(p - page) <= 1) pages.push(p)
    else if (pages[pages.length - 1] !== '…') pages.push('…')
  }
  return (
    <nav className="pagination" aria-label="Phân trang">
      <button type="button" disabled={page <= 1} onClick={() => onChange(page - 1)} aria-label="Trang trước">
        <ChevronLeft size={18} aria-hidden="true" />
      </button>
      {pages.map((p, i) =>
        p === '…' ? (
          <span key={`gap${i}`} aria-hidden="true">
            …
          </span>
        ) : (
          <button
            key={p}
            type="button"
            className={p === page ? 'is-on' : ''}
            aria-current={p === page ? 'page' : undefined}
            onClick={() => onChange(p)}
          >
            {p}
          </button>
        ),
      )}
      <button type="button" disabled={page >= totalPages} onClick={() => onChange(page + 1)} aria-label="Trang sau">
        <ChevronRight size={18} aria-hidden="true" />
      </button>
    </nav>
  )
}
