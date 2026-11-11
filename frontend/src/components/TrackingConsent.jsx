import { useEffect, useRef } from 'react'
import { consent, useConsent } from '../tracking/tracker'
import '../styles/chat.css'

/**
 * Hỏi khách có đồng ý cho website ghi nhận hành vi (trang đã xem, nút đã bấm) hay không.
 * Mặc định KHÔNG theo dõi cho tới khi khách bấm Đồng ý. Đo chiều cao banner để đẩy nút chat lên tránh đè nhau.
 */
export default function TrackingConsent() {
  const state = useConsent()
  const ref = useRef(null)
  const visible = state === null

  useEffect(() => {
    const root = document.documentElement
    // Chỉ cần đẩy nút chat lên khi banner chiếm hết chiều ngang (màn hình nhỏ); trên desktop banner nằm bên trái
    const mobile = window.matchMedia('(max-width: 640px)').matches
    root.style.setProperty('--consent-h', visible && mobile && ref.current ? `${ref.current.offsetHeight + 16}px` : '0px')
    return () => root.style.setProperty('--consent-h', '0px')
  }, [visible])

  if (!visible) return null
  return (
    <aside ref={ref} className="consent" role="region" aria-label="Quyền riêng tư">
      <h2>Chúng tôi tôn trọng quyền riêng tư của bạn</h2>
      <p>
        Website ghi nhận ẩn danh các trang bạn xem và nút bạn bấm (không gồm nội dung bạn nhập) để cải thiện trải nghiệm và gợi ý tour phù hợp hơn.
        Bạn có thể từ chối, website vẫn dùng bình thường.
      </p>
      <div className="consent__actions">
        <button type="button" className="btn btn-primary btn-sm" onClick={() => consent.set('granted')}>
          Đồng ý
        </button>
        <button type="button" className="btn btn-outline btn-sm" onClick={() => consent.set('denied')}>
          Từ chối
        </button>
      </div>
    </aside>
  )
}
