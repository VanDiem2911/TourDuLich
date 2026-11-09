import { useEffect, useRef } from 'react'

/** Hộp thoại xác nhận (đăng xuất, xóa, hủy đơn...). Esc để đóng, focus vào nút Hủy khi mở. */
export default function ConfirmDialog({
  open,
  title,
  message,
  confirmLabel = 'Đồng ý',
  cancelLabel = 'Hủy bỏ',
  danger = false,
  onConfirm,
  onCancel,
}) {
  const cancelRef = useRef(null)

  useEffect(() => {
    if (!open) return
    cancelRef.current?.focus()
    const onKey = (e) => e.key === 'Escape' && onCancel()
    document.addEventListener('keydown', onKey)
    return () => document.removeEventListener('keydown', onKey)
  }, [open, onCancel])

  if (!open) return null

  return (
    <div className="modal-backdrop" onClick={onCancel}>
      <div
        className="modal"
        role="alertdialog"
        aria-modal="true"
        aria-labelledby="confirm-title"
        aria-describedby="confirm-message"
        onClick={(e) => e.stopPropagation()}
      >
        <h2 id="confirm-title" style={{ fontSize: '1.25rem' }}>
          {title}
        </h2>
        <p id="confirm-message">{message}</p>
        <div className="modal__actions">
          <button ref={cancelRef} type="button" className="btn btn-outline" onClick={onCancel}>
            {cancelLabel}
          </button>
          <button type="button" className={`btn ${danger ? 'btn-danger' : 'btn-primary'}`} onClick={onConfirm}>
            {confirmLabel}
          </button>
        </div>
      </div>
    </div>
  )
}
