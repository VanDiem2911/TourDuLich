/**
 * Tải ảnh thẳng từ trình duyệt lên Cloudinary bằng unsigned upload preset (không cần API secret ở frontend).
 * Đổi tài khoản/preset bằng biến môi trường Vite (xem .env.example).
 */
const CLOUD_NAME = import.meta.env.VITE_CLOUDINARY_CLOUD_NAME || 'dbwahdjzg'
const UPLOAD_PRESET = import.meta.env.VITE_CLOUDINARY_UPLOAD_PRESET || 'TourDuLich'

export const CLOUDINARY_MAX_BYTES = 5 * 1024 * 1024

/** Trả về { url } là đường dẫn https đã bật tự chọn định dạng/chất lượng (f_auto,q_auto) để tải nhanh. */
export async function uploadImage(file) {
  const body = new FormData()
  body.append('file', file)
  body.append('upload_preset', UPLOAD_PRESET)

  let res
  try {
    res = await fetch(`https://api.cloudinary.com/v1_1/${CLOUD_NAME}/image/upload`, { method: 'POST', body })
  } catch {
    throw new Error('Không kết nối được Cloudinary, vui lòng kiểm tra mạng.')
  }
  const data = await res.json().catch(() => ({}))
  if (!res.ok || !data.secure_url) {
    throw new Error(data?.error?.message || 'Cloudinary từ chối ảnh này.')
  }
  return { url: data.secure_url.replace('/upload/', '/upload/f_auto,q_auto/') }
}
