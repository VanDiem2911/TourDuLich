import { useEffect, useRef, useState } from 'react'
import { useSearchParams } from 'react-router-dom'
import { SlidersHorizontal, X } from 'lucide-react'
import { publicApi } from '../api'
import { useAsync } from '../hooks/useAsync'
import TourCard from '../components/TourCard'
import Pagination from '../components/Pagination'
import { track } from '../tracking/tracker'

const SORTS = [
  { v: 'newest', t: 'Mới nhất' },
  { v: 'departureAsc', t: 'Khởi hành sớm nhất' },
  { v: 'priceAsc', t: 'Giá thấp đến cao' },
  { v: 'priceDesc', t: 'Giá cao đến thấp' },
]
const REGIONS = [
  { v: '', t: 'Tất cả' },
  { v: 'DOMESTIC', t: 'Trong nước' },
  { v: 'INTERNATIONAL', t: 'Nước ngoài' },
]
const REGION_HEAD = {
  '': { title: 'Tìm hành trình của bạn', desc: 'Lọc theo điểm đến, ngân sách và ngày khởi hành. Giá hiển thị là giá cho mỗi người lớn.' },
  DOMESTIC: { title: 'Khám phá Việt Nam', desc: 'Biển đảo, núi rừng, di sản và ẩm thực khắp ba miền. Giá hiển thị là giá cho mỗi người lớn.' },
  INTERNATIONAL: { title: 'Hành trình ra thế giới', desc: 'Châu Á, Châu Âu, Châu Úc, Châu Mỹ với hướng dẫn viên tiếng Việt. Giá hiển thị là giá cho mỗi người lớn.' },
}
const BUDGETS = [
  { v: '', t: 'Mọi mức giá' },
  { v: '-5000000', t: 'Dưới 5 triệu' },
  { v: '5000000-10000000', t: '5 – 10 triệu' },
  { v: '10000000-20000000', t: '10 – 20 triệu' },
  { v: '20000000-', t: 'Trên 20 triệu' },
]

export default function Tours() {
  const [sp, setSp] = useSearchParams()
  const page = Number(sp.get('page')) || 1
  const keyword = sp.get('keyword') || ''
  const categoryId = sp.get('categoryId') || ''
  const destination = sp.get('destination') || ''
  const region = ['DOMESTIC', 'INTERNATIONAL'].includes(sp.get('region')) ? sp.get('region') : ''
  const minPrice = sp.get('minPrice') || ''
  const maxPrice = sp.get('maxPrice') || ''
  const departureFrom = sp.get('departureFrom') || ''
  const departureTo = sp.get('departureTo') || ''
  const sort = sp.get('sort') || 'newest'

  const [kw, setKw] = useState(keyword)
  const [filtersOpen, setFiltersOpen] = useState(false)
  useEffect(() => setKw(keyword), [keyword])

  const { data: cats } = useAsync(() => publicApi.categories({ region }), [region])
  const { data, loading, error, reload } = useAsync(
    () =>
      publicApi.tours({ page, size: 9, keyword, categoryId, destination, region, minPrice, maxPrice, departureFrom, departureTo, sort }),
    [page, keyword, categoryId, destination, region, minPrice, maxPrice, departureFrom, departureTo, sort],
  )

  // Ghi nhận từ khóa tìm kiếm (một lần cho mỗi từ khóa, kèm số kết quả)
  const lastSearch = useRef('')
  useEffect(() => {
    if (data && keyword && lastSearch.current !== keyword) {
      lastSearch.current = keyword
      track('search', { props: { keyword: keyword.slice(0, 60), region: region || undefined, results: data.totalElements } })
    }
  }, [data, keyword, region])

  const patch = (changes) => {
    const next = new URLSearchParams(sp)
    Object.entries(changes).forEach(([k, v]) => (v === '' || v == null ? next.delete(k) : next.set(k, v)))
    if (!('page' in changes)) next.delete('page')
    setSp(next)
  }

  const budgetValue = minPrice || maxPrice ? `${minPrice}-${maxPrice}` : ''
  const onBudget = (v) => {
    const [min, max] = v.split('-')
    patch({ minPrice: min || '', maxPrice: max || '' })
  }
  const clearAll = () => setSp(new URLSearchParams())

  const activeChips = [
    region && { k: 'region', t: REGIONS.find((r) => r.v === region)?.t || 'Phạm vi' },
    keyword && { k: 'keyword', t: `“${keyword}”` },
    categoryId && { k: 'categoryId', t: (cats || []).find((c) => String(c.id) === categoryId)?.name || 'Danh mục' },
    destination && { k: 'destination', t: destination },
    budgetValue && { k: 'budget', t: BUDGETS.find((b) => b.v === budgetValue)?.t || 'Khoảng giá' },
    (departureFrom || departureTo) && { k: 'date', t: `Ngày đi ${departureFrom || '…'} → ${departureTo || '…'}` },
  ].filter(Boolean)

  const removeChip = (k) => {
    if (k === 'budget') patch({ minPrice: '', maxPrice: '' })
    else if (k === 'date') patch({ departureFrom: '', departureTo: '' })
    else patch({ [k]: '' })
  }

  const tours = data?.content || []

  return (
    <div className="container">
      <header className="page-head">
        <h1>{REGION_HEAD[region].title}</h1>
        <p>{REGION_HEAD[region].desc}</p>
      </header>

      <div className="tours-layout">
        <aside className={`filters ${filtersOpen ? 'is-open' : ''}`} aria-label="Bộ lọc">
          <form
            className="filter-group"
            role="search"
            onSubmit={(e) => {
              e.preventDefault()
              patch({ keyword: kw.trim() })
            }}
          >
            <h3>Tìm kiếm</h3>
            <div className="form-field">
              <label htmlFor="kw" className="visually-hidden">
                Tên tour, điểm đến hoặc mã tour
              </label>
              <input
                id="kw"
                className="input"
                type="search"
                placeholder="Tên, điểm đến, mã tour"
                value={kw}
                onChange={(e) => setKw(e.target.value)}
                maxLength={100}
              />
            </div>
          </form>

          <div className="filter-group">
            <h3>Phạm vi</h3>
            <div className="radio-list" role="radiogroup" aria-label="Trong nước hoặc nước ngoài">
              {REGIONS.map((r) => (
                <label key={r.v} className={region === r.v ? 'is-on' : ''}>
                  <span>
                    <input type="radio" name="region" checked={region === r.v} onChange={() => patch({ region: r.v, categoryId: '' })} />
                    {r.t}
                  </span>
                </label>
              ))}
            </div>
          </div>

          <div className="filter-group">
            <h3>Loại hành trình</h3>
            <div className="radio-list" role="radiogroup" aria-label="Danh mục">
              <label className={!categoryId ? 'is-on' : ''}>
                <span>
                  <input type="radio" name="cat" checked={!categoryId} onChange={() => patch({ categoryId: '' })} />
                  Tất cả
                </span>
              </label>
              {(cats || []).filter((c) => !region || c.tourCount > 0 || String(c.id) === categoryId).map((c) => (
                <label key={c.id} className={String(c.id) === categoryId ? 'is-on' : ''}>
                  <span>
                    <input
                      type="radio"
                      name="cat"
                      checked={String(c.id) === categoryId}
                      onChange={() => patch({ categoryId: String(c.id) })}
                    />
                    {c.name}
                  </span>
                  <span className="count">{c.tourCount}</span>
                </label>
              ))}
            </div>
          </div>

          <div className="filter-group">
            <h3>Ngân sách mỗi người</h3>
            <div className="radio-list" role="radiogroup" aria-label="Khoảng giá">
              {BUDGETS.map((b) => (
                <label key={b.v} className={budgetValue === b.v ? 'is-on' : ''}>
                  <span>
                    <input type="radio" name="budget" checked={budgetValue === b.v} onChange={() => onBudget(b.v)} />
                    {b.t}
                  </span>
                </label>
              ))}
            </div>
          </div>

          <div className="filter-group">
            <h3>Ngày khởi hành</h3>
            <div className="form" style={{ gap: 'var(--s3)' }}>
              <div className="form-field">
                <label htmlFor="df">Từ ngày</label>
                <input id="df" type="date" className="input" value={departureFrom} onChange={(e) => patch({ departureFrom: e.target.value })} />
              </div>
              <div className="form-field">
                <label htmlFor="dt">Đến ngày</label>
                <input id="dt" type="date" className="input" value={departureTo} min={departureFrom || undefined} onChange={(e) => patch({ departureTo: e.target.value })} />
              </div>
            </div>
          </div>
        </aside>

        <section aria-live="polite">
          <div className="results-bar">
            <button type="button" className="btn btn-outline btn-sm filter-toggle" onClick={() => setFiltersOpen((v) => !v)} aria-expanded={filtersOpen}>
              <SlidersHorizontal size={16} aria-hidden="true" /> Bộ lọc
            </button>
            <span className="muted">
              {loading ? 'Đang tải…' : `${data?.totalElements ?? 0} hành trình`}
            </span>
            <div className="form-field" style={{ marginLeft: 'auto', gridAutoFlow: 'column', alignItems: 'center', gap: 'var(--s2)' }}>
              <label htmlFor="sort">Sắp xếp</label>
              <select id="sort" className="input" style={{ minHeight: 40, width: 'auto' }} value={sort} onChange={(e) => patch({ sort: e.target.value === 'newest' ? '' : e.target.value })}>
                {SORTS.map((s) => (
                  <option key={s.v} value={s.v}>
                    {s.t}
                  </option>
                ))}
              </select>
            </div>
          </div>

          {activeChips.length > 0 && (
            <div className="chip-row" style={{ marginBottom: 'var(--s5)' }}>
              {activeChips.map((c) => (
                <button key={c.k} type="button" className="chip" onClick={() => removeChip(c.k)} aria-label={`Bỏ lọc ${c.t}`}>
                  {c.t} <X size={14} aria-hidden="true" />
                </button>
              ))}
              <button type="button" className="chip" style={{ borderStyle: 'dashed' }} onClick={clearAll}>
                Xóa tất cả
              </button>
            </div>
          )}

          {error ? (
            <div className="empty">
              <h3>Không thể tải danh sách tour</h3>
              <p>{error}</p>
              <button type="button" className="btn btn-primary" onClick={reload}>
                Tải lại trang
              </button>
            </div>
          ) : loading ? (
            <div className="tour-grid" style={{ gridTemplateColumns: 'repeat(auto-fill, minmax(250px, 1fr))' }}>
              {Array.from({ length: 6 }).map((_, n) => (
                <div key={n} className="skeleton" style={{ aspectRatio: '4/5' }} />
              ))}
            </div>
          ) : tours.length === 0 ? (
            <div className="empty">
              <h3>{activeChips.length ? 'Không có tour khớp bộ lọc' : 'Hiện chưa có tour nào đang mở bán'}</h3>
              <p>{activeChips.length ? 'Thử nới khoảng giá hoặc bỏ bớt điều kiện lọc.' : 'Quý khách vui lòng quay lại sau!'}</p>
              {activeChips.length > 0 && (
                <button type="button" className="btn btn-outline" onClick={clearAll}>
                  Xóa bộ lọc
                </button>
              )}
            </div>
          ) : (
            <div className="tour-grid" style={{ gridTemplateColumns: 'repeat(auto-fill, minmax(250px, 1fr))' }}>
              {tours.map((t) => (
                <TourCard key={t.id} tour={t} />
              ))}
            </div>
          )}

          <Pagination page={data?.page || page} totalPages={data?.totalPages} onChange={(p) => { patch({ page: String(p) }); window.scrollTo({ top: 0, behavior: 'smooth' }) }} />
        </section>
      </div>
    </div>
  )
}
