import api from './client'

const get = (url, params) => api.get(url, { params }).then((r) => r.data)
const post = (url, body) => api.post(url, body).then((r) => r.data)
const put = (url, body) => api.put(url, body).then((r) => r.data)
const del = (url) => api.delete(url).then((r) => r.data)

/** Bỏ các tham số rỗng để URL gọn. */
const clean = (o = {}) => Object.fromEntries(Object.entries(o).filter(([, v]) => v !== '' && v != null))

export const publicApi = {
  categories: (params) => get('/categories', clean(params)),
  tours: (params) => get('/tours', clean(params)),
  featured: (limit = 6) => get('/tours/featured', { limit }),
  destinations: () => get('/tours/destinations'),
  tour: (id) => get(`/tours/${id}`),
  sendContact: (body) => post('/contacts', body),
}

/** Trợ lý AI. Gemini có thể trả lời chậm hơn các API khác nên đặt timeout riêng 60 giây. */
export const aiApi = {
  status: () => get('/ai/status'),
  chat: (body) => api.post('/ai/chat', body, { timeout: 60000 }).then((r) => r.data),
}

export const cartApi = {
  get: () => get('/cart'),
  add: (body) => post('/cart/items', body),
  update: (tourId, body) => put(`/cart/items/${tourId}`, body),
  remove: (tourId) => del(`/cart/items/${tourId}`),
  clear: () => del('/cart'),
}

export const bookingApi = {
  create: (body) => post('/bookings', body),
  mine: (params) => get('/bookings/my-bookings', clean(params)),
  detail: (id) => get(`/bookings/my-bookings/${id}`),
  cancel: (id, reason) => put(`/bookings/${id}/cancel`, { reason }),
  paymentInfo: (id) => get(`/bookings/${id}/payment-info`),
  simulatePay: (bookingId) => post('/payments/simulate', { bookingId }),
}

export const accountApi = {
  update: (body) => put('/auth/me', body),
  changePassword: (body) => put('/auth/password', body),
}

export const adminApi = {
  trackingSummary: (days = 7) => get('/admin/tracking/summary', { days }),
  aiStatus: () => get('/admin/ai/status'),
  aiKeys: () => get('/admin/ai/keys'),
  aiPreview: () => get('/admin/ai/preview'),
  aiChats: (params) => get('/admin/ai/chats', clean(params)),
  aiChatStats: (days = 7) => get('/admin/ai/chats/stats', { days }),
  aiChat: (id) => get(`/admin/ai/chats/${encodeURIComponent(id)}`),
  aiChatDelete: (id) => del(`/admin/ai/chats/${encodeURIComponent(id)}`),
  aiReindex: () => api.post('/admin/ai/reindex', null, { timeout: 120000 }).then((r) => r.data),
  stats: (period) => get('/admin/dashboard/stats', clean({ period })),

  categories: (params) => get('/admin/categories', clean(params)),
  categoryOptions: () => get('/admin/categories/options'),
  createCategory: (body) => post('/admin/categories', body),
  updateCategory: (id, body) => put(`/admin/categories/${id}`, body),
  deleteCategory: (id) => del(`/admin/categories/${id}`),

  tours: (params) => get('/admin/tours', clean(params)),
  tour: (id) => get(`/admin/tours/${id}`),
  createTour: (body) => post('/admin/tours', body),
  updateTour: (id, body) => put(`/admin/tours/${id}`, body),
  setTourStatus: (id, status) => put(`/admin/tours/${id}/status`, { status }),
  deleteTour: (id) => del(`/admin/tours/${id}`),
  upload: (file) => {
    const fd = new FormData()
    fd.append('file', file)
    return api.post('/admin/uploads', fd).then((r) => r.data)
  },

  bookings: (params) => get('/admin/bookings', clean(params)),
  booking: (id) => get(`/admin/bookings/${id}`),
  setBookingStatus: (id, status, reason) => put(`/admin/bookings/${id}/status`, { status, reason }),
  setBookingPayment: (id, paymentStatus) => put(`/admin/bookings/${id}/payment`, { paymentStatus }),

  users: (params) => get('/admin/users', clean(params)),
  setUserStatus: (id, status) => put(`/admin/users/${id}/status`, { status }),

  contacts: (params) => get('/admin/contacts', clean(params)),
  contact: (id) => get(`/admin/contacts/${id}`),
  replyContact: (id, replyContent) => put(`/admin/contacts/${id}/reply`, { replyContent }),
  setContactStatus: (id, status, adminNote) => put(`/admin/contacts/${id}/status`, { status, adminNote }),
  deleteContact: (id) => del(`/admin/contacts/${id}`),
}
