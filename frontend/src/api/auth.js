import api from './client'

export const authApi = {
  register: (payload) => api.post('/auth/register', payload).then((r) => r.data),
  login: (payload) => api.post('/auth/login', payload).then((r) => r.data),
  logout: () => api.post('/auth/logout').catch(() => undefined), // lỗi mạng khi logout không được chặn đăng xuất
  me: () => api.get('/auth/me').then((r) => r.data),
}
