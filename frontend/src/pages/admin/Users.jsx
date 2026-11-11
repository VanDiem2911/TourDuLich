import { useState } from 'react'
import { Lock, LockOpen } from 'lucide-react'
import { adminApi } from '../../api'
import { getErrorMessage } from '../../api/client'
import { useAuth } from '../../context/AuthContext'
import { fmtDate } from '../../utils/format'
import StatusTag from '../../components/StatusTag'
import ConfirmDialog from '../../components/ConfirmDialog'
import Pagination from '../../components/Pagination'
import { useToast } from '../../components/Toast'
import { EmptyState, ErrorState, ResultCount, SearchBox, SkeletonRows, useListPage } from './AdminKit'

const USER_STATUS = {
  ACTIVE: { label: 'Đang hoạt động', tone: 'ok' },
  INACTIVE: { label: 'Đã khóa', tone: 'danger' },
}
const ROLES = {
  ROLE_CUSTOMER: 'Khách hàng',
  ROLE_ADMIN: 'Quản trị viên',
}

export default function AdminUsers() {
  const toast = useToast()
  const { user: me } = useAuth()
  const list = useListPage((p) => adminApi.users(p), { keyword: '', role: '', status: '' })
  const [target, setTarget] = useState(null) // { user, next }
  const [busyId, setBusyId] = useState(null)

  const protectedReason = (u) => {
    if (u.id === me?.id) return 'Bạn không thể khóa chính mình'
    if (u.role === 'ROLE_ADMIN') return 'Không thể khóa tài khoản quản trị viên'
    return ''
  }

  const apply = async () => {
    const { user, next } = target
    setTarget(null)
    setBusyId(user.id)
    try {
      await adminApi.setUserStatus(user.id, next)
      toast.success(next === 'INACTIVE' ? `Đã khóa tài khoản ${user.fullName}.` : `Đã mở khóa tài khoản ${user.fullName}.`)
      list.reload()
    } catch (err) {
      toast.error(getErrorMessage(err, 'Không thể đổi trạng thái tài khoản.'))
    } finally {
      setBusyId(null)
    }
  }

  const locking = target?.next === 'INACTIVE'

  return (
    <>
      <div className="admin-head">
        <div>
          <h1>Người dùng</h1>
          <p>Khóa tài khoản vi phạm hoặc mở lại khi cần. Tài khoản quản trị viên và tài khoản của bạn được bảo vệ.</p>
        </div>
      </div>

      <div className="toolbar" role="search">
        <SearchBox
          label="Tìm người dùng"
          value={list.filters.keyword}
          onChange={(v) => list.setFilter({ keyword: v })}
          placeholder="Tên, email hoặc số điện thoại…"
        />
        <div className="form-field">
          <label htmlFor="u-role">Vai trò</label>
          <select id="u-role" className="input" value={list.filters.role} onChange={(e) => list.setFilter({ role: e.target.value })}>
            <option value="">Tất cả</option>
            {Object.entries(ROLES).map(([v, l]) => (
              <option key={v} value={v}>
                {l}
              </option>
            ))}
          </select>
        </div>
        <div className="form-field">
          <label htmlFor="u-status">Trạng thái</label>
          <select id="u-status" className="input" value={list.filters.status} onChange={(e) => list.setFilter({ status: e.target.value })}>
            <option value="">Tất cả</option>
            {Object.entries(USER_STATUS).map(([v, s]) => (
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
        <EmptyState title="Không tìm thấy người dùng">
          <p>Thử đổi từ khóa hoặc bỏ bớt bộ lọc.</p>
          {list.filtered && (
            <button type="button" className="btn btn-outline" onClick={list.reset}>
              Xóa bộ lọc
            </button>
          )}
        </EmptyState>
      ) : (
        <>
          <div className="table-wrap" aria-busy={list.refreshing} tabIndex={0} role="region" aria-label="Bảng người dùng">
            <table className="table table--wide">
              <thead>
                <tr>
                  <th scope="col">Người dùng</th>
                  <th scope="col">Điện thoại</th>
                  <th scope="col">Vai trò</th>
                  <th scope="col" className="r">
                    Số đơn
                  </th>
                  <th scope="col">Ngày tạo</th>
                  <th scope="col">Trạng thái</th>
                  <th scope="col">
                    <span className="visually-hidden">Thao tác</span>
                  </th>
                </tr>
              </thead>
              <tbody>
                {list.firstLoad ? (
                  <SkeletonRows cols={7} />
                ) : (
                  list.rows.map((u) => {
                    const reason = protectedReason(u)
                    const isLocked = u.status === 'INACTIVE'
                    return (
                      <tr key={u.id}>
                        <td>
                          <span className="cell-main">
                            {u.fullName}
                            {u.id === me?.id && <span className="muted"> (bạn)</span>}
                          </span>
                          <span className="cell-sub">{u.email}</span>
                        </td>
                        <td className="nowrap">{u.phone || '—'}</td>
                        <td>{ROLES[u.role] || u.role}</td>
                        <td className="r num">{u.bookingCount ?? 0}</td>
                        <td className="nowrap num">{fmtDate(u.createdAt)}</td>
                        <td>
                          <StatusTag map={USER_STATUS} value={u.status} />
                        </td>
                        <td>
                          <div className="icon-actions">
                            <button
                              type="button"
                              className="btn btn-outline btn-sm"
                              disabled={Boolean(reason) || busyId === u.id}
                              title={reason || undefined}
                              aria-label={`${isLocked ? 'Mở khóa' : 'Khóa'} tài khoản ${u.fullName}${reason ? ` (không khả dụng: ${reason})` : ''}`}
                              onClick={() => setTarget({ user: u, next: isLocked ? 'ACTIVE' : 'INACTIVE' })}
                            >
                              {busyId === u.id ? (
                                <span className="spinner" aria-hidden="true" />
                              ) : isLocked ? (
                                <LockOpen size={16} aria-hidden="true" />
                              ) : (
                                <Lock size={16} aria-hidden="true" />
                              )}
                              {isLocked ? 'Mở khóa' : 'Khóa'}
                            </button>
                          </div>
                        </td>
                      </tr>
                    )
                  })
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

      <ConfirmDialog
        open={Boolean(target)}
        danger={locking}
        title={locking ? 'Khóa tài khoản?' : 'Mở khóa tài khoản?'}
        message={
          target
            ? locking
              ? `${target.user.fullName} (${target.user.email}) sẽ không thể đăng nhập cho đến khi được mở khóa.`
              : `${target.user.fullName} (${target.user.email}) sẽ có thể đăng nhập và đặt tour trở lại.`
            : ''
        }
        confirmLabel={locking ? 'Khóa tài khoản' : 'Mở khóa'}
        onConfirm={apply}
        onCancel={() => setTarget(null)}
      />
    </>
  )
}
