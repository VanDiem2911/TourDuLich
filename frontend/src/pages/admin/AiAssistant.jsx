import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { RefreshCw, SendHorizontal } from 'lucide-react'
import { adminApi, aiApi } from '../../api'
import { getErrorMessage } from '../../api/client'
import { useAsync } from '../../hooks/useAsync'
import { useToast } from '../../components/Toast'
import ChatMarkdown from '../../components/ChatMarkdown'
import ConfirmDialog from '../../components/ConfirmDialog'
import Pagination from '../../components/Pagination'
import { ErrorState, Tile } from './AdminKit'
import { money } from '../../utils/format'

const ERR_LABEL = {
  QUOTA: 'Hết hạn mức (nghỉ ngắn)',
  QUOTA_DAILY: 'Hết hạn mức trong ngày',
  INVALID: 'Key không hợp lệ',
  UNAVAILABLE: 'Mô hình không còn khả dụng',
}

function coolingText(s) {
  if (s >= 3600) return `${Math.round(s / 3600)} giờ`
  if (s >= 60) return `${Math.round(s / 60)} phút`
  return `${s} giây`
}

/** Bảng trạng thái các tổ hợp key (và mô hình) của một nhóm: chat hoặc embedding. */
function KeyTable({ title, group }) {
  if (!group) return null
  return (
    <div style={{ marginBottom: 'var(--s5)' }}>
      <h3 style={{ fontSize: '1rem' }}>
        {title} <small className="muted">· đã tự chuyển key {group.failovers} lần</small>
      </h3>
      <div className="table-wrap" tabIndex={0} role="region" aria-label={`Trạng thái key: ${title}`}>
        <table className="table">
          <thead>
            <tr>
              <th scope="col">#</th>
              <th scope="col">Key · mô hình</th>
              <th scope="col">Trạng thái</th>
              <th scope="col" className="r">Số lần lỗi</th>
            </tr>
          </thead>
          <tbody>
            {group.keys.map((k) => (
              <tr key={k.index}>
                <td className="num">{k.index}</td>
                <td className="num">{k.key}</td>
                <td>
                  {k.cooling ? (
                    <span className="pill pill--warn">
                      Tạm nghỉ {coolingText(k.coolingSeconds)}
                      {k.lastError ? `: ${ERR_LABEL[k.lastError] || k.lastError}` : ''}
                    </span>
                  ) : k.active ? (
                    <span className="pill pill--ok">Đang dùng</span>
                  ) : (
                    <span className="pill">Dự phòng</span>
                  )}
                </td>
                <td className="r num">{k.failures}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}

/** Hộp thử hỏi trợ lý ngay trong trang quản trị (dùng đúng API của khách, nên phản ánh đúng những gì khách thấy). */
function Tester() {
  const [q, setQ] = useState('')
  const [busy, setBusy] = useState(false)
  const [result, setResult] = useState(null)

  const ask = async (e) => {
    e.preventDefault()
    const text = q.trim()
    if (!text || busy) return
    setBusy(true)
    setResult(null)
    const t = Date.now()
    try {
      const r = await aiApi.chat({ message: text, history: [] })
      setResult({ ok: true, answer: r.answer, sources: r.sources, ms: Date.now() - t })
    } catch (err) {
      setResult({ ok: false, error: getErrorMessage(err, 'Không gọi được trợ lý.') })
    } finally {
      setBusy(false)
    }
  }

  return (
    <section className="panel" aria-labelledby="h-test" style={{ marginTop: 'var(--s5)' }}>
      <h2 id="h-test">Thử hỏi trợ lý</h2>
      <p className="panel__sub">Gửi một câu hỏi như khách để kiểm tra câu trả lời. Mỗi lần hỏi tốn một lượt gọi Gemini.</p>
      <form onSubmit={ask} style={{ display: 'flex', gap: 'var(--s3)', flexWrap: 'wrap' }}>
        <label htmlFor="ai-test" className="visually-hidden">Câu hỏi thử</label>
        <input
          id="ai-test"
          className="input"
          style={{ flex: 1, minWidth: 240 }}
          placeholder="Ví dụ: Có tour biển nào dưới 8 triệu cho gia đình?"
          value={q}
          maxLength={500}
          onChange={(e) => setQ(e.target.value)}
        />
        <button type="submit" className="btn btn-primary" disabled={busy || !q.trim()}>
          {busy ? <span className="spinner" aria-hidden="true" /> : <SendHorizontal size={18} aria-hidden="true" />} Hỏi
        </button>
      </form>
      {result && (
        <div className="ai-answer" role="status" aria-live="polite">
          {result.ok ? (
            <>
              <div className="chat-msg chat-msg--bot" style={{ maxWidth: '100%' }}>
                <ChatMarkdown text={result.answer} />
              </div>
              <p className="muted" style={{ fontSize: '0.82rem', margin: 'var(--s2) 0 0' }}>
                Trả lời sau {(result.ms / 1000).toFixed(1)} giây
                {result.sources?.length ? ` · nhắc tới ${result.sources.length} tour: ` : ''}
                {result.sources?.map((s, i) => (
                  <span key={s.tourId}>
                    {i > 0 && ', '}
                    <Link to={`/tours/${s.tourId}`}>{s.name}</Link> ({money(s.price)})
                  </span>
                ))}
              </p>
            </>
          ) : (
            <div className="alert alert-error">{result.error}</div>
          )}
        </div>
      )}
    </section>
  )
}

/** Một cuộc trò chuyện: bấm để mở và xem từng lượt hỏi đáp (tải khi mở). */
function Conversation({ c, onDelete }) {
  const [turns, setTurns] = useState(null)
  const [err, setErr] = useState('')

  const load = async (open) => {
    if (!open || turns) return
    try {
      setTurns(await adminApi.aiChat(c.id))
    } catch (e) {
      setErr(getErrorMessage(e, 'Không tải được cuộc trò chuyện.'))
    }
  }

  return (
    <details className="chatlog" onToggle={(e) => load(e.currentTarget.open)}>
      <summary>
        <span className="chatlog__main">
          <span className="chatlog__q">{c.firstQuestion || '(không có nội dung)'}</span>
          <small className="muted">
            {c.lastAt} · {c.userName ? c.userName : 'Khách'} · {c.turns} lượt
          </small>
        </span>
        {Number(c.errors) > 0 && <span className="pill pill--danger">{c.errors} lỗi</span>}
      </summary>
      <div className="chatlog__body">
        {err && <div className="alert alert-error">{err}</div>}
        {!turns && !err && <div className="skeleton" style={{ height: 60 }} />}
        {turns?.map((t) => (
          <div key={t.id} className="chatlog__turn">
            <div className="chat-msg chat-msg--user">
              <p>{t.question}</p>
            </div>
            {Number(t.ok) === 1 ? (
              <div className="chat-msg chat-msg--bot" style={{ maxWidth: '100%' }}>
                <ChatMarkdown text={t.answer} />
              </div>
            ) : (
              <div className="chat-msg chat-msg--error" style={{ maxWidth: '100%' }}>
                <p>Lỗi: {t.error || 'không có phản hồi'}</p>
              </div>
            )}
            <p className="muted chatlog__meta">
              {t.at} · {t.latencyMs != null ? `${(t.latencyMs / 1000).toFixed(1)} giây` : ''}
              {t.model ? ` · ${t.model}` : ''}
              {t.onTourId ? (
                <>
                  {' · đang xem '}
                  <Link to={`/tours/${t.onTourId}`}>tour #{t.onTourId}</Link>
                </>
              ) : null}
            </p>
          </div>
        ))}
        <button type="button" className="btn btn-ghost btn-sm chatlog__del" onClick={() => onDelete(c)}>
          Xóa cuộc trò chuyện này
        </button>
      </div>
    </details>
  )
}

/** Lịch sử hội thoại giữa khách và trợ lý AI. */
function ChatHistory() {
  const toast = useToast()
  const [keyword, setKeyword] = useState('')
  const [applied, setApplied] = useState('')
  const [page, setPage] = useState(1)
  const [confirm, setConfirm] = useState(null)
  const list = useAsync(() => adminApi.aiChats({ keyword: applied, page, size: 10 }), [applied, page])
  const stats = useAsync(() => adminApi.aiChatStats(7), [])
  const st = stats.data
  const totalPages = Math.max(1, Math.ceil((list.data?.total || 0) / 10))

  const remove = async () => {
    const c = confirm
    setConfirm(null)
    try {
      await adminApi.aiChatDelete(c.id)
      toast.success('Đã xóa cuộc trò chuyện.')
      list.reload()
      stats.reload()
    } catch (e) {
      toast.error(getErrorMessage(e, 'Không xóa được.'))
    }
  }

  return (
    <section className="panel" aria-labelledby="h-chats" style={{ marginTop: 'var(--s5)' }}>
      <h2 id="h-chats">Lịch sử chat với khách</h2>
      <p className="panel__sub">
        Các câu hỏi khách gửi cho trợ lý và câu trả lời, nhóm theo cuộc trò chuyện. Email và số điện thoại được che trước khi lưu (đổi bằng AI_CHAT_REDACT=false trong .env); dữ liệu tự xóa sau 90 ngày.
        {st ? ` Trong 7 ngày: ${st.conversations} cuộc trò chuyện, ${st.questions} câu hỏi, ${st.errors} lỗi, trung bình ${(Number(st.avgLatencyMs) / 1000).toFixed(1)} giây mỗi câu.` : ''}
      </p>
      <form
        onSubmit={(e) => {
          e.preventDefault()
          setPage(1)
          setApplied(keyword.trim())
        }}
        style={{ display: 'flex', gap: 'var(--s3)', flexWrap: 'wrap', marginBottom: 'var(--s4)' }}
      >
        <label htmlFor="chat-kw" className="visually-hidden">Tìm trong lịch sử chat</label>
        <input id="chat-kw" className="input" style={{ flex: 1, minWidth: 220 }} type="search" placeholder="Tìm theo nội dung câu hỏi hoặc trả lời" value={keyword} maxLength={100} onChange={(e) => setKeyword(e.target.value)} />
        <button type="submit" className="btn btn-outline">Tìm</button>
      </form>

      {list.error ? (
        <ErrorState message={list.error} onRetry={list.reload} />
      ) : !list.data ? (
        <div className="skeleton" style={{ height: 120 }} />
      ) : list.data.items.length === 0 ? (
        <p className="muted">{applied ? 'Không có cuộc trò chuyện nào khớp.' : 'Chưa có khách nào chat với trợ lý.'}</p>
      ) : (
        <>
          <div className="chatlog-list">
            {list.data.items.map((c) => (
              <Conversation key={c.id} c={c} onDelete={setConfirm} />
            ))}
          </div>
          <Pagination page={page} totalPages={totalPages} onChange={setPage} />
        </>
      )}

      <ConfirmDialog
        open={Boolean(confirm)}
        title="Xóa cuộc trò chuyện"
        message="Toàn bộ các lượt hỏi đáp của cuộc trò chuyện này sẽ bị xóa vĩnh viễn."
        confirmLabel="Xóa"
        onConfirm={remove}
        onCancel={() => setConfirm(null)}
      />
    </section>
  )
}

export default function AdminAiAssistant() {
  const toast = useToast()
  const status = useAsync(() => adminApi.aiStatus(), [])
  const keys = useAsync(() => adminApi.aiKeys(), [])
  const [reindexing, setReindexing] = useState(false)
  const [preview, setPreview] = useState(null)
  const s = status.data

  // Đang lập chỉ mục thì tự cập nhật tiến độ mỗi 3 giây
  useEffect(() => {
    if (!s?.indexing && !reindexing) return undefined
    const t = setInterval(() => {
      status.reload()
      keys.reload()
    }, 3000)
    return () => clearInterval(t)
  }, [s?.indexing, reindexing]) // eslint-disable-line react-hooks/exhaustive-deps

  const refresh = () => {
    status.reload()
    keys.reload()
  }

  const reindex = async () => {
    setReindexing(true)
    try {
      await adminApi.aiReindex()
      toast.success('Đã lập lại chỉ mục cho trợ lý AI.')
    } catch (e) {
      toast.error(getErrorMessage(e, 'Không lập được chỉ mục AI.'))
    } finally {
      setReindexing(false)
      refresh()
    }
  }

  const loadPreview = async () => {
    try {
      setPreview(await adminApi.aiPreview())
    } catch (e) {
      toast.error(getErrorMessage(e, 'Không xem trước được tài liệu.'))
    }
  }

  const stateText = !s
    ? '…'
    : !s.enabled
      ? 'Chưa bật'
      : s.indexing
        ? `Đang lập chỉ mục ${s.doneChunks}/${s.totalChunks}`
        : s.ready
          ? 'Đang hoạt động'
          : 'Chưa có chỉ mục'

  return (
    <>
      <div className="admin-head">
        <div>
          <h1>Trợ lý AI</h1>
          <p>Trợ lý tư vấn tour dùng Gemini và dữ liệu của website (RAG). Theo dõi tình trạng chỉ mục, các API key dự phòng và thử hỏi ngay tại đây.</p>
        </div>
        <div className="admin-head__actions">
          <button type="button" className="btn btn-outline btn-sm" onClick={refresh} disabled={status.loading}>
            <RefreshCw size={16} aria-hidden="true" />
            Làm mới
          </button>
          <button type="button" className="btn btn-primary btn-sm" onClick={reindex} disabled={reindexing || s?.indexing || !s?.enabled}>
            {reindexing && <span className="spinner" aria-hidden="true" />} Lập lại chỉ mục
          </button>
        </div>
      </div>

      {status.error ? (
        <ErrorState message={status.error} onRetry={status.reload} />
      ) : !s ? (
        <div className="skeleton" style={{ height: 160 }} />
      ) : (
        <>
          {!s.enabled && (
            <div className="alert alert-warn" role="status" style={{ marginBottom: 'var(--s5)' }}>
              Trợ lý AI chưa bật. Điền <code>GEMINI_API_KEY</code> (và <code>GEMINI_API_KEY_2</code>... làm key dự phòng) trong <code>backend/.env</code> rồi khởi động lại backend.
            </div>
          )}
          {s.lastError && (
            <div className="alert alert-error" role="alert" style={{ marginBottom: 'var(--s5)' }}>
              Lần lập chỉ mục gần nhất báo lỗi: {s.lastError}
            </div>
          )}

          <div className="stat-grid stat-grid--dash">
            <Tile label="Trạng thái" value={stateText} note={s.lastIndexedAt ? `Cập nhật chỉ mục: ${new Date(s.lastIndexedAt).toLocaleString('vi-VN')}` : undefined} />
            <Tile label="Đoạn dữ liệu đã lập chỉ mục" value={s.chunks} note={`${s.tourChunks} đoạn tour/tổng quan · ${s.docChunks} đoạn tài liệu`} />
            <Tile label="Vector trong bộ nhớ đệm" value={s.cachedVectors} note="Lưu trong DB (bảng ai_embedding_cache)" />
            <Tile
              label="Lượt tiết kiệm từ đệm"
              value={s.cacheHits}
              note={`${s.cacheMisses} lần phải gọi API kể từ khi khởi động`}
            />
          </div>

          <section className="panel" aria-labelledby="h-keys" style={{ marginTop: 'var(--s5)' }}>
            <h2 id="h-keys">API key và mô hình</h2>
            <p className="panel__sub">
              Hệ thống dùng key đang hoạt động; khi hết hạn mức hoặc mô hình không còn dành cho key đó thì tự chuyển tổ hợp kế tiếp. Key luôn được che, chỉ hiện 4 ký tự cuối.
              Thêm key dự phòng bằng <code>GEMINI_API_KEY_2</code> trong <code>.env</code>.
            </p>
            {keys.error ? (
              <ErrorState message={keys.error} onRetry={keys.reload} />
            ) : !keys.data ? (
              <div className="skeleton" style={{ height: 80 }} />
            ) : Object.keys(keys.data).length === 0 ? (
              <p className="muted">Chưa có key nào được cấu hình.</p>
            ) : (
              <>
                <KeyTable title="Trả lời (chat)" group={keys.data.chat} />
                <KeyTable title="Embedding (tìm kiếm ngữ nghĩa)" group={keys.data.embedding} />
              </>
            )}
          </section>

          <Tester />

          <ChatHistory />

          <section className="panel" aria-labelledby="h-docs" style={{ marginTop: 'var(--s5)' }}>
            <h2 id="h-docs">Tài liệu tổng quan về tour mà AI đọc</h2>
            <p className="panel__sub">
              Tự sinh từ DB theo điểm đến, loại hành trình và phạm vi trong nước / nước ngoài. Tài liệu hướng dẫn (đặt tour, thanh toán, hủy đơn...) nằm trong{' '}
              <code>backend/src/main/resources/ai/knowledge/</code> hoặc thư mục <code>backend/ai-knowledge/</code>; sửa xong bấm “Lập lại chỉ mục”.
            </p>
            {!preview ? (
              <button type="button" className="btn btn-outline btn-sm" onClick={loadPreview}>
                Xem trước tài liệu
              </button>
            ) : (
              <div className="ai-docs">
                {preview.map((d) => (
                  <details key={d.id}>
                    <summary>{d.id}</summary>
                    <pre>{d.text}</pre>
                  </details>
                ))}
              </div>
            )}
          </section>
        </>
      )}
    </>
  )
}
