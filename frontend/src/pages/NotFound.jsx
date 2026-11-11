import { Link } from 'react-router-dom'

export default function NotFound() {
  return (
    <div className="container page">
      <div className="empty" style={{ maxWidth: 640, margin: '0 auto' }}>
        <h1 style={{ fontSize: 'clamp(2rem, 5vw, 3.2rem)' }}>Con đường này không dẫn đến đâu cả</h1>
        <p>Đường dẫn bạn truy cập không tồn tại hoặc đã được chuyển đi nơi khác.</p>
        <Link to="/" className="btn btn-primary">
          Về trang chủ
        </Link>
      </div>
    </div>
  )
}
