import { useState } from 'react'
import { Pencil, Plus, Trash2 } from 'lucide-react'
import { adminApi } from '../../api'
import { getErrorMessage } from '../../api/client'
import { ACTIVE_STATUS, fmtDate } from '../../utils/format'
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
  serverFormErrors,
  useListPage,
} from './AdminKit'

const CAT_STATUS_OPTIONS = [
  { value: 'ACTIVE', label: 'Hoạt động' },
  { value: 'INACTIVE', label: 'Ẩn' },
]

function CategoryModal({ item, onClose, onSaved }) {
  const toast = useToast()
  const [form, setForm] = useState({
    name: item?.name ?? '',
    description: item?.description ?? '',
    status: item?.status ?? 'ACTIVE',
  })
  const [errors, setErrors] = useState({})
  const [formError, setFormError] = useState('')
  const [saving, setSaving] = useState(false)
  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))

  const submit = async (e) => {
    e.preventDefault()
    const next = {}
    const name = form.name.trim()
    if (!name) next.name = 'Vui lòng nhập tên danh mục.'
    else if (name.length > 100) next.name = 'Tên danh mục tối đa 100 ký tự.'
    setErrors(next)
    setFormError('')
    if (Object.keys(next).length) return

    setSaving(true)
    const body = { name, description: form.description.trim(), status: form.status }
    try {
      if (item) await adminApi.updateCategory(item.id, body)
      else await adminApi.createCategory(body)
      toast.success(item ? 'Đã cập nhật danh mục.' : 'Đã thêm danh mục mới.')
      onSaved()
    } catch (err) {
      const r = serverFormErrors(err, 'name')
      setErrors(r.errors)
      setFormError(r.message)
    } finally {
      setSaving(false)
    }
  }

  return (
    <Modal
      title={item ? 'Sửa danh mục' : 'Thêm danh mục'}
      onClose={onClose}
      busy={saving}
      footer={
        <>
          <button type="button" className="btn btn-outline" onClick={onClose} disabled={saving}>
            Hủy bỏ
          </button>
          <SubmitButton form="category-form" busy={saving}>
            {item ? 'Lưu thay đổi' : 'Thêm danh mục'}
          </SubmitButton>
        </>
      }
    >
      <form id="category-form" className="form" onSubmit={submit} noValidate>
        {formError && (
          <div className="alert alert-error" role="alert">
            {formError}
          </div>
        )}
        <Field label="Tên danh mục" required error={errors.name}>
          <input className="input" value={form.name} onChange={set('name')} maxLength={100} autoFocus autoComplete="off" />
        </Field>
        <Field label="Mô tả" error={errors.description} hint="Hiển thị cho khách ở trang danh mục.">
          <textarea className="input" value={form.description} onChange={set('description')} maxLength={500} />
        </Field>
        <Field label="Trạng thái" error={errors.status} hint="Danh mục ẩn sẽ không xuất hiện ở trang khách.">
          <select className="input" value={form.status} onChange={set('status')}>
            {CAT_STATUS_OPTIONS.map((o) => (
              <option key={o.value} value={o.value}>
                {o.label}
              </option>
            ))}
          </select>
        </Field>
      </form>
    </Modal>
  )
}

export default function AdminCategories() {
  const toast = useToast()
  const list = useListPage((p) => adminApi.categories(p), { keyword: '', status: '' })
  const [editing, setEditing] = useState(null) // null | {} (thêm) | item
  const [deleting, setDeleting] = useState(null)

  const doDelete = async () => {
    const target = deleting
    setDeleting(null)
    try {
      await adminApi.deleteCategory(target.id)
      toast.success(`Đã xóa danh mục “${target.name}”.`)
      list.reload()
    } catch (err) {
      // 409: danh mục còn tour
      toast.error(getErrorMessage(err, 'Không thể xóa danh mục này.'))
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
          <span className="eyebrow">Danh mục</span>
          <h1>Danh mục tour</h1>
          <p>Nhóm tour theo vùng miền hoặc loại hình. Danh mục còn tour thì không thể xóa.</p>
        </div>
        <div className="admin-head__actions">
          <button type="button" className="btn btn-accent" onClick={() => setEditing({})}>
            <Plus size={18} aria-hidden="true" />
            Thêm danh mục
          </button>
        </div>
      </div>

      <div className="toolbar" role="search">
        <SearchBox
          label="Tìm theo tên"
          value={list.filters.keyword}
          onChange={(v) => list.setFilter({ keyword: v })}
          placeholder="Nhập tên danh mục…"
        />
        <div className="form-field">
          <label htmlFor="cat-status">Trạng thái</label>
          <select id="cat-status" className="input" value={list.filters.status} onChange={(e) => list.setFilter({ status: e.target.value })}>
            <option value="">Tất cả</option>
            {CAT_STATUS_OPTIONS.map((o) => (
              <option key={o.value} value={o.value}>
                {o.label}
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
        <EmptyState title={list.filtered ? 'Không có danh mục phù hợp' : 'Chưa có danh mục nào'}>
          <p>{list.filtered ? 'Thử đổi từ khóa hoặc bỏ bớt bộ lọc.' : 'Thêm danh mục đầu tiên để bắt đầu gắn tour.'}</p>
          {list.filtered ? (
            <button type="button" className="btn btn-outline" onClick={list.reset}>
              Xóa bộ lọc
            </button>
          ) : (
            <button type="button" className="btn btn-primary" onClick={() => setEditing({})}>
              Thêm danh mục
            </button>
          )}
        </EmptyState>
      ) : (
        <>
          <div className="table-wrap" aria-busy={list.refreshing} tabIndex={0} role="region" aria-label="Bảng danh mục tour">
            <table className="table table--wide">
              <thead>
                <tr>
                  <th scope="col">Tên danh mục</th>
                  <th scope="col">Mô tả</th>
                  <th scope="col" className="r">
                    Số tour
                  </th>
                  <th scope="col">Trạng thái</th>
                  <th scope="col">Ngày tạo</th>
                  <th scope="col">
                    <span className="visually-hidden">Thao tác</span>
                  </th>
                </tr>
              </thead>
              <tbody>
                {list.firstLoad ? (
                  <SkeletonRows cols={6} />
                ) : (
                  list.rows.map((c) => (
                    <tr key={c.id}>
                      <td>
                        <span className="cell-main">{c.name}</span>
                      </td>
                      <td>
                        <span className="clamp-2">{c.description || '—'}</span>
                      </td>
                      <td className="r num">{c.tourCount ?? 0}</td>
                      <td>
                        <StatusTag map={ACTIVE_STATUS} value={c.status} />
                      </td>
                      <td className="nowrap num">{fmtDate(c.createdAt)}</td>
                      <td>
                        <div className="icon-actions">
                          <button
                            type="button"
                            className="btn btn-ghost btn-icon"
                            onClick={() => setEditing(c)}
                            aria-label={`Sửa danh mục ${c.name}`}
                            title="Sửa"
                          >
                            <Pencil size={18} aria-hidden="true" />
                          </button>
                          <button
                            type="button"
                            className="btn btn-ghost btn-icon"
                            onClick={() => setDeleting(c)}
                            aria-label={`Xóa danh mục ${c.name}`}
                            title="Xóa"
                          >
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

      {editing && <CategoryModal item={editing.id ? editing : null} onClose={() => setEditing(null)} onSaved={saved} />}

      <ConfirmDialog
        open={Boolean(deleting)}
        danger
        title="Xóa danh mục?"
        message={deleting ? `Danh mục “${deleting.name}” sẽ bị xóa vĩnh viễn. Nếu danh mục còn tour, hệ thống sẽ từ chối.` : ''}
        confirmLabel="Xóa danh mục"
        onConfirm={doDelete}
        onCancel={() => setDeleting(null)}
      />
    </>
  )
}
