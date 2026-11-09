const vnd = new Intl.NumberFormat('vi-VN')

/** 8990000 -> "8.990.000 đ" */
export const money = (n) => `${vnd.format(Math.round(Number(n) || 0))} đ`

export const fmtDate = (iso) => {
  if (!iso) return '—'
  return new Date(iso).toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit', year: 'numeric' })
}

export const fmtDateTime = (iso) => {
  if (!iso) return '—'
  const d = new Date(iso)
  return `${d.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' })} ${fmtDate(iso)}`
}

export const fmtDateLong = (iso) => {
  if (!iso) return '—'
  return new Date(iso).toLocaleDateString('vi-VN', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })
}

/** Ngày tháng ngắn: "12 thg 12" */
export const fmtDayMonth = (iso) => {
  if (!iso) return ''
  return new Date(iso).toLocaleDateString('vi-VN', { day: 'numeric', month: 'short' })
}

/** Tách chuỗi lịch trình "Ngày N: Tiêu đề" + mô tả thành các khối. */
export function parseItinerary(text) {
  if (!text) return []
  return text
    .replace(/\r/g, '')
    .split(/\n\s*\n/)
    .map((block) => block.trim())
    .filter(Boolean)
    .map((block, i) => {
      const lines = block.split('\n')
      const m = lines[0].match(/^(?:Ngày|Day)\s*(\d+)\s*[:\-–.]?\s*(.*)$/i)
      if (m) return { day: Number(m[1]), title: m[2] || `Ngày ${m[1]}`, body: lines.slice(1).join(' ').trim() }
      return { day: i + 1, title: lines[0], body: lines.slice(1).join(' ').trim() }
    })
}

export const BOOKING_STATUS = {
  PENDING: { label: 'Chờ xác nhận', tone: 'warn' },
  CONFIRMED: { label: 'Đã xác nhận', tone: 'info' },
  COMPLETED: { label: 'Hoàn tất', tone: 'ok' },
  CANCELLED: { label: 'Đã hủy', tone: 'danger' },
}
export const PAYMENT_STATUS = {
  UNPAID: { label: 'Chưa thanh toán', tone: 'warn' },
  PAID: { label: 'Đã thanh toán', tone: 'ok' },
  REFUNDED: { label: 'Đã hoàn tiền', tone: 'muted' },
}
export const TOUR_STATUS = {
  ACTIVE: { label: 'Đang mở bán', tone: 'ok' },
  CLOSED: { label: 'Tạm đóng', tone: 'warn' },
  COMPLETED: { label: 'Đã kết thúc', tone: 'muted' },
}
export const ACTIVE_STATUS = {
  ACTIVE: { label: 'Hoạt động', tone: 'ok' },
  INACTIVE: { label: 'Đã khóa / ẩn', tone: 'danger' },
}
export const CONTACT_STATUS = {
  NEW: { label: 'Mới', tone: 'warn' },
  IN_PROGRESS: { label: 'Đang xử lý', tone: 'info' },
  RESOLVED: { label: 'Đã phản hồi', tone: 'ok' },
}
