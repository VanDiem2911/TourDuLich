/**
 * Ghi nhận hành vi người dùng trên giao diện (user tracking).
 *
 * Cơ chế:
 *  1. Định danh ẩn danh: anonymousId (localStorage, sống lâu) + sessionId (đổi sau 30 phút không hoạt động).
 *     Khi khách đăng nhập, backend gắn user_id nhờ JWT gửi kèm (không đưa userId vào sự kiện từ phía client).
 *  2. Sự kiện: page_view / page_leave (thời gian + độ cuộn), click (ủy quyền ở document), và các sự kiện nghiệp vụ
 *     gọi tường minh: view_tour, search, add_to_cart, begin_checkout, booking_created, chat_*...
 *  3. Gom lô: đưa vào hàng đợi, gửi mỗi 5 giây hoặc khi đủ 20 sự kiện; khi đóng/ẩn tab dùng sendBeacon.
 *  4. Quyền riêng tư: chỉ chạy khi khách đồng ý (td_consent=granted); tôn trọng Do Not Track / Global Privacy Control;
 *     không bao giờ ghi giá trị ô nhập liệu; nhãn nút giống email/số điện thoại bị che.
 */
import { useEffect, useSyncExternalStore } from 'react'
import { useLocation } from 'react-router-dom'
import { tokenStore } from '../api/client'

const ENDPOINT = '/api/tracking/events'
const K = { aid: 'td_aid', sid: 'td_sid', last: 'td_last', consent: 'td_consent', viewed: 'td_viewed' }
const SESSION_IDLE_MS = 30 * 60 * 1000
const FLUSH_MS = 5000
const BATCH = 20
const MAX_QUEUE = 200

const safeGet = (s, k) => {
  try {
    return s.getItem(k)
  } catch {
    return null
  }
}
const safeSet = (s, k, v) => {
  try {
    s.setItem(k, v)
  } catch {
    /* trình duyệt chặn lưu trữ: bỏ qua */
  }
}

const newId = () =>
  (globalThis.crypto?.randomUUID?.() ?? `${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 12)}`).replace(/[^A-Za-z0-9_-]/g, '')

/* ------------------------------ Đồng ý theo dõi ------------------------------ */

const listeners = new Set()
const emit = () => listeners.forEach((l) => l())

/** Khách bật Do Not Track / Global Privacy Control thì coi như từ chối, không hỏi lại. */
const browserOptOut = () => navigator.doNotTrack === '1' || navigator.globalPrivacyControl === true

export const consent = {
  /** 'granted' | 'denied' | null (chưa chọn) */
  get() {
    if (browserOptOut()) return 'denied'
    const v = safeGet(localStorage, K.consent)
    return v === 'granted' || v === 'denied' ? v : null
  },
  set(value) {
    safeSet(localStorage, K.consent, value)
    if (value !== 'granted') {
      queue = []
      try {
        localStorage.removeItem(K.viewed)
      } catch {
        /* bỏ qua */
      }
    }
    emit()
  },
  subscribe(cb) {
    listeners.add(cb)
    return () => listeners.delete(cb)
  },
}

export function useConsent() {
  return useSyncExternalStore(consent.subscribe, consent.get, () => null)
}

const enabled = () => consent.get() === 'granted'

/* ------------------------------ Định danh ------------------------------ */

function anonymousId() {
  let id = safeGet(localStorage, K.aid)
  if (!id || id.length < 8) {
    id = newId()
    safeSet(localStorage, K.aid, id)
  }
  return id
}

function sessionId() {
  const now = Date.now()
  let id = safeGet(localStorage, K.sid)
  const last = Number(safeGet(localStorage, K.last) || 0)
  if (!id || id.length < 8 || now - last > SESSION_IDLE_MS) {
    id = newId()
    safeSet(localStorage, K.sid, id)
  }
  safeSet(localStorage, K.last, String(now))
  return id
}

/* ------------------------------ Hàng đợi và gửi ------------------------------ */

let queue = []
let timer = null

const redact = (s) =>
  String(s ?? '')
    .replace(/[\w.+-]+@[\w-]+\.[\w.-]+/g, '[email]')
    .replace(/\b\d[\d\s.-]{8,}\d\b/g, '[số]')
    .trim()
    .slice(0, 60)

/** Ghi một sự kiện. data: { target, tourId, props }. Không làm gì nếu khách chưa đồng ý. */
export function track(type, data = {}) {
  if (!enabled()) return
  queue.push({
    type,
    page: data.page ?? location.pathname,
    target: data.target ? redact(data.target) : undefined,
    tourId: data.tourId,
    props: data.props,
    ts: Date.now(),
  })
  if (queue.length > MAX_QUEUE) queue.splice(0, queue.length - MAX_QUEUE)
  if (queue.length >= BATCH) flush()
  else if (!timer) timer = setTimeout(flush, FLUSH_MS)
}

/** Gửi hàng đợi. beacon=true khi trang sắp đóng (fetch thường có thể bị hủy giữa chừng). */
export function flush(beacon = false) {
  clearTimeout(timer)
  timer = null
  if (!queue.length || !enabled()) return
  const events = queue.splice(0, 50)
  const body = JSON.stringify({ anonymousId: anonymousId(), sessionId: sessionId(), events })
  if (beacon && navigator.sendBeacon) {
    if (navigator.sendBeacon(ENDPOINT, new Blob([body], { type: 'application/json' }))) return
  }
  const headers = { 'Content-Type': 'application/json' }
  const token = tokenStore.getAccess()
  if (token) headers.Authorization = `Bearer ${token}` // để backend gắn user_id nếu đã đăng nhập
  fetch(ENDPOINT, { method: 'POST', headers, body, keepalive: true }).catch(() => {
    queue = [...events, ...queue].slice(0, MAX_QUEUE) // mất mạng: giữ lại gửi sau
  })
  if (queue.length) timer = setTimeout(flush, FLUSH_MS)
}

/* ------------------------------ Tour đã xem gần đây ------------------------------ */

/** Nhớ tối đa 5 tour khách vừa xem (cục bộ), dùng làm ngữ cảnh cho trợ lý AI. Chỉ khi khách đồng ý. */
export function rememberTour(id) {
  if (!enabled() || !id) return
  const list = recentTours().filter((x) => x !== id)
  list.unshift(id)
  safeSet(localStorage, K.viewed, JSON.stringify(list.slice(0, 5)))
}

export function recentTours() {
  if (!enabled()) return []
  try {
    const v = JSON.parse(safeGet(localStorage, K.viewed) || '[]')
    return Array.isArray(v) ? v.filter((x) => Number.isInteger(x)) : []
  } catch {
    return []
  }
}

/* ------------------------------ Tự động: click, cuộn, rời trang ------------------------------ */

let started = false
let pageEnteredAt = Date.now()
let maxScroll = 0
let currentPath = ''

function onClick(e) {
  const el = e.target instanceof Element ? e.target.closest('[data-track], a, button, [role="button"]') : null
  if (!el || el.closest('[data-track-ignore]')) return
  const label = el.getAttribute('data-track') || el.getAttribute('aria-label') || el.textContent || el.getAttribute('href')
  if (!label) return
  const props = { tag: el.tagName.toLowerCase() }
  const tourId = Number(el.getAttribute('data-tour-id')) || undefined // thẻ tour / thẻ nguồn của trợ lý
  if (el.tagName === 'A') {
    try {
      const u = new URL(el.href, location.origin)
      props.href = u.origin === location.origin ? u.pathname : u.hostname // không ghi query của link ngoài
    } catch {
      /* bỏ qua */
    }
  }
  track('click', { target: label, tourId, props })
}

function onScroll() {
  const h = document.documentElement
  const total = h.scrollHeight - h.clientHeight
  if (total > 0) maxScroll = Math.max(maxScroll, Math.min(100, Math.round((h.scrollTop / total) * 100)))
}

function leavePage() {
  const seconds = Math.round((Date.now() - pageEnteredAt) / 1000)
  if (seconds >= 1 && currentPath) {
    track('page_leave', { page: currentPath, props: { seconds: Math.min(seconds, 3600), scroll: maxScroll } })
  }
  pageEnteredAt = Date.now()
  maxScroll = 0
}

function start() {
  if (started) return
  started = true
  document.addEventListener('click', onClick, { capture: true, passive: true })
  window.addEventListener('scroll', onScroll, { passive: true })
  document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'hidden') {
      leavePage()
      flush(true)
    }
  })
  window.addEventListener('pagehide', () => flush(true))
}

/** Gắn một lần ở layout khách: theo dõi chuyển trang (SPA không tải lại trang nên phải tự bắt). */
export function usePageTracking() {
  const { pathname } = useLocation()
  const state = useConsent()
  useEffect(() => {
    if (state !== 'granted') return undefined
    start()
    pageEnteredAt = Date.now()
    maxScroll = 0
    currentPath = pathname
    let referrer
    try {
      referrer = document.referrer ? new URL(document.referrer).hostname : undefined
    } catch {
      referrer = undefined
    }
    track('page_view', { page: pathname, props: { referrer } })
    return () => leavePage()
  }, [pathname, state])
}
