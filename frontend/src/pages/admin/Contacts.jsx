import { useEffect, useState } from 'react'
import { useSearchParams } from 'react-router-dom'
import { Eye, Send, Trash2 } from 'lucide-react'
import { adminApi } from '../../api'
import { getErrorMessage } from '../../api/client'
import { CONTACT_STATUS, fmtDateTime } from '../../utils/format'
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

const TABS = [
  { value: '', label: 'Tất cả' },
  { value: 'NEW', label: 'Mới' },
  { value: 'IN_PROGRESS', label: 'Đang xử lý' },
  { value: 'RESOLVED', label: 'Đã phản hồi' },
]

/* ------------------------------ Chi tiết + phản hồi ------------------------------ */

function ContactModal({ initial, onClose, onChanged, onDeleteRequest }) {
  const toast = useToast()
  const [c, setC] = useState(initial)
  const [reply, setReply] = useState('')
  const [replyError, setReplyError] = useState('')
  const [status, setStatus] = useState(initial.status)
  const [note, setNote] = useState(initial.adminNote ?? '')
  const [sending, setSending] = useState(false)
  const [saving, setSaving] = useState(false)

  const refresh = async () => {
    try {
      const fresh = await adminApi.contact(c.id)
      setC(fresh)
      setStatus(fresh.status)
      setNote(fresh.adminNote ?? '')
    } catch {
      /* danh sách phía sau sẽ được tải lại, bỏ qua */
    }
  }

  const sendReply = async (e) => {
    e.preventDefault()
    const text = reply.trim()
    if (!text) return setReplyError('Vui lòng nhập nội dung phản hồi.')
    if (text.length < 5) return setReplyError('Nội dung phản hồi quá ngắn.')
    setReplyError('')
    setSending(true)
    try {
      await adminApi.replyContact(c.id, text)
      toast.success('Đã gửi phản hồi, liên hệ chuyển sang “Đã phản hồi”.')
      setReply('')
      await refresh()
      onChanged()
    } catch (err) {
      setReplyError(getErrorMessage(err, 'Không gửi được phản hồi.'))
    } finally {
      setSending(false)
    }
  }

  const saveStatus = async (e) => {
    e.preventDefault()
    setSaving(true)
    try {
      await adminApi.setContactStatus(c.id, status, note.trim() || undefined)
      toast.success('Đã lưu trạng thái và ghi chú.')
      await refresh()
      onChanged()
    } catch (err) {
      toast.error(getErrorMessage(err, 'Không lưu được trạng thái.'))
    } finally {
      setSaving(false)
    }
  }

  const dirty = status !== c.status || note.trim() !== (c.adminNote ?? '').trim()

  return (
    <Modal
      wide
      title={c.subject}
      onClose={onClose}
      busy={sending || saving}
      subtitle={
        <>
          <StatusTag map={CONTACT_STATUS} value={c.status} />
          <span>Gửi lúc {fmtDateTime(c.createdAt)}</span>
        </>
      }
      footer={
        <>
          <button type="button" className="btn btn-outline spacer" onClick={() => onDeleteRequest(c)}>
            <Trash2 size={16} aria-hidden="true" />
            Xóa liên hệ
          </button>
          <button type="button" className="btn btn-primary" onClick={onClose}>
            Đóng
          </button>
        </>
      }
    >
      <div className="det-block">
        <h3>Người gửi</h3>
        <dl className="kv">
          <dt>Họ tên</dt>
          <dd>{c.fullName}</dd>
          <dt>Email</dt>
          <dd>
            <a href={`mailto:${c.email}`}>{c.email}</a>
          </dd>
          <dt>Điện thoại</dt>
          <dd>{c.phone ? <a href={`tel:${c.phone}`}>{c.phone}</a> : '—'}</dd>
        </dl>
      </div>

      <div className="det-block">
        <h3>Nội dung khách gửi</h3>
        <blockquote className="quote">{c.message}</blockquote>
      </div>

      {c.replyContent && (
        <div className="det-block">
          <h3>Phản hồi đã gửi{c.repliedAt ? ` lúc ${fmtDateTime(c.repliedAt)}` : ''}</h3>
          <blockquote className="quote quote--reply">{c.replyContent}</blockquote>
        </div>
      )}

      <form className="det-block form" onSubmit={sendReply} noValidate>
        <h3>{c.replyContent ? 'Gửi phản hồi mới' : 'Phản hồi khách hàng'}</h3>
        <Field label="Nội dung phản hồi" error={replyError} hint={`Gửi tới ${c.email}. Sau khi gửi, liên hệ chuyển sang “Đã phản hồi”.`}>
          <textarea className="input" value={reply} onChange={(e) => setReply(e.target.value)} maxLength={3000} rows={5} />
        </Field>
        <div>
          <SubmitButton busy={sending} className="btn btn-accent">
            <Send size={16} aria-hidden="true" />
            Gửi phản hồi
          </SubmitButton>
        </div>
      </form>

      <form className="det-block form" onSubmit={saveStatus}>
        <h3>Xử lý nội bộ</h3>
        <div className="form-row">
          <Field label="Trạng thái">
            <select className="input" value={status} onChange={(e) => setStatus(e.target.value)}>
              {Object.entries(CONTACT_STATUS).map(([v, s]) => (
                <option key={v} value={v}>
                  {s.label}
                </option>
              ))}
            </select>
          </Field>
        </div>
        <Field label="Ghi chú của quản trị viên" hint="Chỉ nhân viên nhìn thấy, không gửi cho khách.">
          <textarea className="input input--sm" value={note} onChange={(e) => setNote(e.target.value)} maxLength={1000} />
        </Field>
        <div>
          <SubmitButton busy={saving} className="btn btn-outline" disabled={saving || !dirty}>
            Lưu trạng thái
          </SubmitButton>
        </div>
      </form>
    </Modal>
  )
}

/* ------------------------------ Trang ------------------------------ */

export default function AdminContacts() {
  const toast = useToast()
  const [params, setParams] = useSearchParams()
  const initialStatus = TABS.some((t) => t.value === params.get('status')) ? params.get('status') : ''
  const list = useListPage((p) => adminApi.contacts(p), { keyword: '', status: initialStatus })
  const newCount = useAsync(() => adminApi.contacts({ status: 'NEW', size: 1 }), [])
  const [open, setOpen] = useState(null)
  const [deleting, setDeleting] = useState(null)

  // Đồng bộ ?status= lên URL để có thể chia sẻ/quay lại
  const status = list.filters.status
  useEffect(() => {
    const cur = params.get('status') || ''
    if (cur !== status) {
      const next = new URLSearchParams(params)
      if (status) next.set('status', status)
      else next.delete('status')
      setParams(next, { replace: true })
    }
  }, [status, params, setParams])

  const changed = () => {
    list.reload()
    newCount.reload()
  }

  const doDelete = async () => {
    const target = deleting
    setDeleting(null)
    try {
      await adminApi.deleteContact(target.id)
      toast.success('Đã xóa liên hệ.')
      setOpen(null)
      changed()
    } catch (err) {
      toast.error(getErrorMessage(err, 'Không xóa được liên hệ.'))
    }
  }

  const nNew = newCount.data?.totalElements ?? 0

  return (
    <>
      <div className="admin-head">
        <div>
          <h1>Liên hệ từ khách</h1>
          <p>Đọc, phản hồi và theo dõi các tin nhắn gửi từ trang liên hệ.</p>
        </div>
      </div>

      {nNew > 0 && (
        <div className="new-banner" role="status">
          <span>
            <strong>{nNew} liên hệ mới</strong> đang chờ bạn đọc và phản hồi.
          </span>
          {status !== 'NEW' && (
            <button type="button" className="btn btn-outline btn-sm" onClick={() => list.setFilter({ status: 'NEW' })} style={{ marginLeft: 'auto' }}>
              Chỉ xem tin mới
            </button>
          )}
        </div>
      )}

      <div className="tabs" role="group" aria-label="Lọc theo trạng thái">
        {TABS.map((t) => (
          <button
            key={t.value || 'all'}
            type="button"
            aria-pressed={status === t.value}
            className={status === t.value ? 'is-on' : ''}
            onClick={() => list.setFilter({ status: t.value })}
          >
            {t.label}
            {t.value === 'NEW' && (
              <span className={`count-flag ${nNew ? '' : 'count-flag--zero'}`} aria-label={`${nNew} liên hệ mới`}>
                {nNew}
              </span>
            )}
          </button>
        ))}
      </div>

      <div className="toolbar" role="search">
        <SearchBox
          label="Tìm liên hệ"
          value={list.filters.keyword}
          onChange={(v) => list.setFilter({ keyword: v })}
          placeholder="Tên, email, chủ đề hoặc nội dung…"
        />
        {list.filters.keyword && (
          <button type="button" className="btn btn-ghost" onClick={() => list.setFilter({ keyword: '' })}>
            Xóa từ khóa
          </button>
        )}
      </div>

      {list.error ? (
        <ErrorState message={list.error} onRetry={list.reload} />
      ) : !list.firstLoad && list.rows.length === 0 ? (
        <EmptyState title={list.filtered ? 'Không có liên hệ phù hợp' : 'Hộp thư trống'}>
          <p>{list.filtered ? 'Thử đổi trạng thái hoặc từ khóa tìm kiếm.' : 'Khi khách gửi liên hệ, tin nhắn sẽ hiện ở đây.'}</p>
        </EmptyState>
      ) : (
        <>
          <div className="table-wrap" aria-busy={list.refreshing} tabIndex={0} role="region" aria-label="Bảng liên hệ">
            <table className="table table--wide">
              <thead>
                <tr>
                  <th scope="col">Người gửi</th>
                  <th scope="col">Chủ đề</th>
                  <th scope="col">Gửi lúc</th>
                  <th scope="col">Trạng thái</th>
                  <th scope="col">
                    <span className="visually-hidden">Thao tác</span>
                  </th>
                </tr>
              </thead>
              <tbody>
                {list.firstLoad ? (
                  <SkeletonRows cols={5} />
                ) : (
                  list.rows.map((c) => (
                    <tr key={c.id} className={c.status === 'NEW' ? 'row-new' : ''}>
                      <td>
                        <span className="cell-main">{c.fullName}</span>
                        <span className="cell-sub">{c.email}</span>
                      </td>
                      <td>
                        <button type="button" className="link-cell" onClick={() => setOpen(c)}>
                          {c.subject}
                        </button>
                        <span className="clamp-2">{c.message}</span>
                      </td>
                      <td className="nowrap num">{fmtDateTime(c.createdAt)}</td>
                      <td>
                        <StatusTag map={CONTACT_STATUS} value={c.status} />
                      </td>
                      <td>
                        <div className="icon-actions">
                          <button
                            type="button"
                            className="btn btn-ghost btn-icon"
                            onClick={() => setOpen(c)}
                            aria-label={`Xem và phản hồi: ${c.subject}`}
                            title="Xem và phản hồi"
                          >
                            <Eye size={18} aria-hidden="true" />
                          </button>
                          <button
                            type="button"
                            className="btn btn-ghost btn-icon"
                            onClick={() => setDeleting(c)}
                            aria-label={`Xóa liên hệ: ${c.subject}`}
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

      {open && <ContactModal key={open.id} initial={open} onClose={() => setOpen(null)} onChanged={changed} onDeleteRequest={setDeleting} />}

      <ConfirmDialog
        open={Boolean(deleting)}
        danger
        title="Xóa liên hệ?"
        message={deleting ? `Liên hệ “${deleting.subject}” của ${deleting.fullName} sẽ bị xóa vĩnh viễn.` : ''}
        confirmLabel="Xóa liên hệ"
        onConfirm={doDelete}
        onCancel={() => setDeleting(null)}
      />
    </>
  )
}
