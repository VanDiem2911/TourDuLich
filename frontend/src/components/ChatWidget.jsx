import { useCallback, useEffect, useRef, useState } from 'react'
import { Link, useLocation } from 'react-router-dom'
import { MessageCircle, RotateCcw, SendHorizontal, Sparkles, X } from 'lucide-react'
import { aiApi } from '../api'
import { getErrorMessage } from '../api/client'
import { money } from '../utils/format'
import { recentTours, track } from '../tracking/tracker'
import ChatMarkdown from './ChatMarkdown'
import '../styles/chat.css'

const STORE_KEY = 'td_chat'
const CID_KEY = 'td_chat_cid'

/** Mã cuộc trò chuyện (theo phiên trình duyệt) để admin xem các lượt hỏi đáp được nhóm lại. */
function conversationId() {
  try {
    let id = sessionStorage.getItem(CID_KEY)
    if (!id) {
      id = (globalThis.crypto?.randomUUID?.() ?? `${Date.now().toString(36)}${Math.random().toString(36).slice(2, 12)}`).replace(/[^A-Za-z0-9_-]/g, '')
      sessionStorage.setItem(CID_KEY, id)
    }
    return id
  } catch {
    return undefined
  }
}
const GREETING =
  'Xin chào! Mình là trợ lý AI của TourDuLich. Mình có thể gợi ý tour, giải đáp lịch trình, giá, cách đặt và thanh toán. Bạn đang muốn đi đâu?'
const BASE_SUGGESTIONS = ['Gợi ý tour biển cho gia đình', 'Có tour nước ngoài nào dưới 15 triệu?', 'Cách thanh toán và hủy đơn thế nào?']
const TOUR_SUGGESTIONS = ['Tour này gồm những gì?', 'Tour này còn chỗ không?', 'Có tour nào tương tự không?']

const loadSaved = () => {
  try {
    const v = JSON.parse(sessionStorage.getItem(STORE_KEY) || '[]')
    return Array.isArray(v) ? v : []
  } catch {
    return []
  }
}

let seq = 0
const newId = () => `m${Date.now()}-${++seq}`

function SourceCards({ sources }) {
  if (!sources?.length) return null
  return (
    <ul className="chat-sources" aria-label="Tour được nhắc đến">
      {sources.map((s) => (
        <li key={s.tourId}>
          <Link to={s.url} className="chat-source" data-track="chat-source" data-tour-id={s.tourId}>
            {s.imageUrl && <img src={s.imageUrl} alt="" loading="lazy" width="64" height="48" />}
            <span className="chat-source__body">
              <span className="chat-source__name">{s.name}</span>
              <span className="chat-source__meta">
                {s.duration}
                {s.destination ? ` · ${s.destination}` : ''}
              </span>
              <span className="chat-source__price">
                {s.originalPrice > 0 && <s>{money(s.originalPrice)}</s>} {money(s.price)}
              </span>
            </span>
          </Link>
        </li>
      ))}
    </ul>
  )
}

export default function ChatWidget() {
  const { pathname } = useLocation()
  const currentTourId = Number(pathname.match(/^\/tours\/(\d+)/)?.[1]) || null

  const [open, setOpen] = useState(false)
  const [status, setStatus] = useState(null) // null: chưa biết | { enabled, ready }
  const [messages, setMessages] = useState(loadSaved)
  const [input, setInput] = useState('')
  const [loading, setLoading] = useState(false)

  const fabRef = useRef(null)
  const inputRef = useRef(null)
  const listRef = useRef(null)
  const messagesRef = useRef(messages)
  messagesRef.current = messages

  // Lưu hội thoại theo phiên trình duyệt (bỏ tin lỗi)
  useEffect(() => {
    try {
      sessionStorage.setItem(STORE_KEY, JSON.stringify(messages.filter((m) => !m.error).slice(-30)))
    } catch {
      /* bỏ qua */
    }
  }, [messages])

  // Mở khung chat: kiểm tra AI đã bật chưa, đưa con trỏ vào ô nhập
  useEffect(() => {
    if (!open) return
    if (!status?.ready) {
      aiApi
        .status()
        .then(setStatus)
        .catch(() => setStatus({ enabled: false, ready: false, unreachable: true }))
    }
    inputRef.current?.focus()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open])

  // Cuộn xuống tin mới nhất
  useEffect(() => {
    const el = listRef.current
    if (el) el.scrollTop = el.scrollHeight
  }, [messages, loading, open, status])

  const close = useCallback(() => {
    setOpen(false)
    fabRef.current?.focus()
  }, [])

  const toggle = () => {
    if (!open) track('chat_open', { props: { onTourPage: Boolean(currentTourId) } })
    setOpen((v) => !v)
  }

  const send = async (text) => {
    const q = text.trim()
    if (!q || loading) return
    const history = messagesRef.current
      .filter((m) => !m.error)
      .slice(-8)
      .map(({ role, content }) => ({ role, content }))
    setMessages((m) => [...m.filter((x) => !x.error), { id: newId(), role: 'user', content: q }])
    setInput('')
    setLoading(true)
    track('chat_message', { props: { length: q.length, onTourPage: Boolean(currentTourId) } })
    try {
      const res = await aiApi.chat({ message: q, history, currentTourId, viewedTourIds: recentTours(), conversationId: conversationId() })
      setMessages((m) => [...m, { id: newId(), role: 'assistant', content: res.answer, sources: res.sources }])
    } catch (e) {
      track('chat_error', { props: { status: e?.response?.status || 0 } })
      setMessages((m) => [
        ...m,
        {
          id: newId(),
          role: 'assistant',
          error: true,
          retry: q,
          content: getErrorMessage(e, 'Không gửi được câu hỏi, vui lòng thử lại.'),
        },
      ])
    } finally {
      setLoading(false)
    }
  }

  const reset = () => {
    try {
      sessionStorage.removeItem(CID_KEY) // cuộc trò chuyện mới có mã mới
    } catch {
      /* bỏ qua */
    }
    setMessages([])
    setInput('')
    inputRef.current?.focus()
  }

  const onPanelKeyDown = (e) => {
    if (e.key === 'Escape') close()
  }

  const onInputKeyDown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey && !e.nativeEvent.isComposing) {
      e.preventDefault()
      send(input)
    }
  }

  const unavailable = status && !status.ready
  const suggestions = currentTourId ? TOUR_SUGGESTIONS : BASE_SUGGESTIONS

  return (
    <>
      <button
        ref={fabRef}
        type="button"
        className={`chat-fab ${open ? 'is-hidden-mobile' : ''}`}
        aria-label={open ? 'Đóng trợ lý AI' : 'Mở trợ lý AI tư vấn tour'}
        aria-expanded={open}
        aria-controls="chat-panel"
        onClick={toggle}
        data-track="chat-fab"
      >
        {open ? <X size={24} aria-hidden="true" /> : <MessageCircle size={26} aria-hidden="true" />}
      </button>

      {open && (
        <section id="chat-panel" className="chat-panel" role="dialog" aria-label="Trợ lý TourDuLich" onKeyDown={onPanelKeyDown}>
          <header className="chat-head">
            <span className="chat-head__icon" aria-hidden="true">
              <Sparkles size={18} />
            </span>
            <div className="chat-head__title">
              <strong>Trợ lý TourDuLich</strong>
              <small>Tư vấn tour bằng AI</small>
            </div>
            <button type="button" className="chat-iconbtn" onClick={reset} aria-label="Bắt đầu cuộc trò chuyện mới" disabled={!messages.length}>
              <RotateCcw size={18} aria-hidden="true" />
            </button>
            <button type="button" className="chat-iconbtn" onClick={close} aria-label="Đóng khung chat">
              <X size={20} aria-hidden="true" />
            </button>
          </header>

          <div className="chat-list" ref={listRef} role="log" aria-live="polite" aria-relevant="additions">
            <div className="chat-msg chat-msg--bot">
              <p>{GREETING}</p>
            </div>

            {!messages.length && !unavailable && (
              <div className="chat-suggest" role="group" aria-label="Câu hỏi gợi ý">
                {suggestions.map((s) => (
                  <button key={s} type="button" className="chat-chip" onClick={() => send(s)} disabled={loading}>
                    {s}
                  </button>
                ))}
              </div>
            )}

            {messages.map((m) => (
              <div key={m.id} className={`chat-msg ${m.role === 'user' ? 'chat-msg--user' : 'chat-msg--bot'} ${m.error ? 'chat-msg--error' : ''}`}>
                {m.role === 'user' ? <p>{m.content}</p> : m.error ? <p>{m.content}</p> : <ChatMarkdown text={m.content} />}
                {m.error && m.retry && (
                  <button type="button" className="chat-retry" onClick={() => send(m.retry)} disabled={loading}>
                    Thử lại
                  </button>
                )}
                {m.sources && <SourceCards sources={m.sources} />}
              </div>
            ))}

            {loading && (
              <div className="chat-msg chat-msg--bot" aria-label="Trợ lý đang soạn câu trả lời">
                <span className="chat-typing" aria-hidden="true">
                  <i />
                  <i />
                  <i />
                </span>
              </div>
            )}

            {unavailable && (
              <div className="chat-notice" role="status">
                <p>
                  {status.enabled
                    ? 'Trợ lý đang chuẩn bị dữ liệu, bạn vui lòng thử lại sau ít phút.'
                    : 'Trợ lý AI hiện chưa hoạt động. Bạn có thể gọi hotline 1900 1234 hoặc gửi yêu cầu ở trang Liên hệ để được tư vấn.'}
                </p>
                <Link to="/contact" onClick={close}>
                  Đến trang Liên hệ
                </Link>
              </div>
            )}
          </div>

          <form
            className="chat-form"
            onSubmit={(e) => {
              e.preventDefault()
              send(input)
            }}
          >
            <label htmlFor="chat-input" className="visually-hidden">
              Câu hỏi của bạn
            </label>
            <textarea
              id="chat-input"
              ref={inputRef}
              rows={1}
              maxLength={1000}
              placeholder={unavailable ? 'Trợ lý chưa sẵn sàng' : 'Nhập câu hỏi về tour…'}
              value={input}
              disabled={Boolean(unavailable)}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={onInputKeyDown}
            />
            <button type="submit" className="chat-send" aria-label="Gửi câu hỏi" disabled={loading || !input.trim() || Boolean(unavailable)}>
              <SendHorizontal size={20} aria-hidden="true" />
            </button>
          </form>
          <p className="chat-foot">AI có thể sai sót, hãy kiểm tra lại giá và điều kiện ở trang tour. Nội dung chat được lưu để cải thiện chất lượng, vui lòng không nhập thông tin cá nhân.</p>
        </section>
      )}
    </>
  )
}
