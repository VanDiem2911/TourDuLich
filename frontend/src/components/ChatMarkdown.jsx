import { Link } from 'react-router-dom'

/**
 * Hiển thị câu trả lời của AI (markdown rút gọn): đoạn văn, gạch đầu dòng, danh sách số, **đậm**, [liên kết](url).
 * Dựng bằng phần tử React (không dùng dangerouslySetInnerHTML) nên nội dung do mô hình sinh ra không thể chèn HTML/script.
 * Liên kết chỉ nhận đường dẫn nội bộ (/...) hoặc https://.
 */
const TOKEN = /(\*\*[^*]+\*\*|\[[^\]]+\]\([^)\s]+\))/g

function renderInline(text, keyPrefix) {
  return text.split(TOKEN).map((part, i) => {
    const key = `${keyPrefix}-${i}`
    if (part.startsWith('**') && part.endsWith('**') && part.length > 4) {
      // đệ quy để hỗ trợ **[Tên tour](/tours/1)** (đậm bao quanh liên kết)
      return <strong key={key}>{renderInline(part.slice(2, -2), key)}</strong>
    }
    const m = part.match(/^\[([^\]]+)\]\(([^)\s]+)\)$/)
    if (m) {
      const [, label, url] = m
      if (url.startsWith('/') && !url.startsWith('//')) {
        return (
          <Link key={key} to={url} data-track="chat-link">
            {label}
          </Link>
        )
      }
      if (/^https:\/\//i.test(url)) {
        return (
          <a key={key} href={url} target="_blank" rel="noopener noreferrer">
            {label}
          </a>
        )
      }
      return label
    }
    return part
  })
}

const BULLET = /^\s*[-*•]\s+(.*)$/
const NUMBERED = /^\s*\d+[.)]\s+(.*)$/

export default function ChatMarkdown({ text }) {
  const blocks = []
  let para = []
  let list = null

  const flushPara = () => {
    if (para.length) blocks.push({ type: 'p', lines: para })
    para = []
  }
  const flushList = () => {
    if (list) blocks.push(list)
    list = null
  }

  for (const raw of String(text ?? '').replace(/\r/g, '').split('\n')) {
    const line = raw.trimEnd()
    const b = line.match(BULLET)
    const n = line.match(NUMBERED)
    if (b || n) {
      flushPara()
      const type = b ? 'ul' : 'ol'
      if (!list || list.type !== type) {
        flushList()
        list = { type, items: [] }
      }
      list.items.push((b || n)[1])
    } else if (!line.trim()) {
      flushPara()
      flushList()
    } else {
      flushList()
      para.push(line.replace(/^#+\s*/, ''))
    }
  }
  flushPara()
  flushList()

  return (
    <>
      {blocks.map((blk, i) => {
        if (blk.type === 'ul' || blk.type === 'ol') {
          const Tag = blk.type
          return (
            <Tag key={i}>
              {blk.items.map((it, k) => (
                <li key={k}>{renderInline(it, `${i}-${k}`)}</li>
              ))}
            </Tag>
          )
        }
        return (
          <p key={i}>
            {blk.lines.map((l, k) => (
              <span key={k}>
                {k > 0 && <br />}
                {renderInline(l, `${i}-${k}`)}
              </span>
            ))}
          </p>
        )
      })}
    </>
  )
}
