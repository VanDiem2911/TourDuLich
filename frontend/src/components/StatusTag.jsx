/** Nhãn trạng thái dùng chung: <StatusTag map={BOOKING_STATUS} value="PENDING" /> */
export default function StatusTag({ map, value }) {
  const s = map[value] || { label: value || '—', tone: 'muted' }
  return <span className={`tag tag-${s.tone}`}>{s.label}</span>
}
