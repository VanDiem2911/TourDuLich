import axios from 'axios'

const ACCESS_KEY = 'tdl_access_token'
const REFRESH_KEY = 'tdl_refresh_token'

export const tokenStore = {
  getAccess: () => localStorage.getItem(ACCESS_KEY),
  getRefresh: () => localStorage.getItem(REFRESH_KEY),
  set(access, refresh) {
    localStorage.setItem(ACCESS_KEY, access)
    if (refresh) localStorage.setItem(REFRESH_KEY, refresh)
  },
  clear() {
    localStorage.removeItem(ACCESS_KEY)
    localStorage.removeItem(REFRESH_KEY)
  },
}

/** Phát khi phiên đăng nhập hết hạn hẳn (refresh thất bại) để AuthContext dọn state. */
export const SESSION_EXPIRED_EVENT = 'auth:session-expired'

const api = axios.create({
  baseURL: '/api',
  withCredentials: true, // gửi cookie JSESSIONID cho Session Cart
  timeout: 15000,
})

api.interceptors.request.use((config) => {
  const token = tokenStore.getAccess()
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

// Chỉ một request refresh chạy tại một thời điểm; các request 401 khác chờ chung kết quả.
let refreshing = null

async function refreshAccessToken() {
  const refreshToken = tokenStore.getRefresh()
  if (!refreshToken) throw new Error('no refresh token')
  // Dùng axios gốc để không đi qua interceptor này (tránh vòng lặp vô hạn)
  const { data } = await axios.post('/api/auth/refresh', { refreshToken }, { withCredentials: true })
  tokenStore.set(data.accessToken, data.refreshToken)
  return data.accessToken
}

api.interceptors.response.use(
  (res) => res,
  async (error) => {
    const original = error.config
    const status = error.response?.status
    const isAuthCall = original?.url?.startsWith('/auth/')

    if (status === 401 && original && !original._retried && !isAuthCall && tokenStore.getRefresh()) {
      original._retried = true
      try {
        refreshing ??= refreshAccessToken().finally(() => {
          refreshing = null
        })
        const newToken = await refreshing
        original.headers.Authorization = `Bearer ${newToken}`
        return api(original)
      } catch {
        tokenStore.clear()
        window.dispatchEvent(new Event(SESSION_EXPIRED_EVENT))
      }
    }
    return Promise.reject(error)
  },
)

/** Lấy thông điệp lỗi thân thiện từ response của backend (ErrorResponse). */
export function getErrorMessage(error, fallback = 'Có lỗi xảy ra, vui lòng thử lại sau!') {
  if (error?.response) return error.response.data?.message || fallback
  if (error?.code === 'ECONNABORTED' || error?.request) {
    return 'Không thể kết nối đến máy chủ, vui lòng kiểm tra mạng và thử lại.'
  }
  return fallback
}

/** Lỗi theo từng trường ({ email: '...' }) nếu backend trả về. */
export function getFieldErrors(error) {
  return error?.response?.data?.fieldErrors || {}
}

export default api
