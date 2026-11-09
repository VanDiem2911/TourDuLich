import { createContext, useCallback, useContext, useMemo, useRef, useState } from 'react'

const ToastContext = createContext(null)

/** Thông báo ngắn góc dưới phải: toast.success('...'), toast.error('...'). */
export function ToastProvider({ children }) {
  const [items, setItems] = useState([])
  const seq = useRef(0)

  const push = useCallback((type, message) => {
    const id = ++seq.current
    setItems((list) => [...list, { id, type, message }])
    setTimeout(() => setItems((list) => list.filter((t) => t.id !== id)), type === 'error' ? 6000 : 3800)
  }, [])

  const api = useMemo(
    () => ({
      info: (m) => push('info', m),
      success: (m) => push('success', m),
      error: (m) => push('error', m),
    }),
    [push],
  )

  return (
    <ToastContext.Provider value={api}>
      {children}
      <div className="toasts" role="status" aria-live="polite">
        {items.map((t) => (
          <div key={t.id} className={`toast toast--${t.type}`}>
            {t.message}
          </div>
        ))}
      </div>
    </ToastContext.Provider>
  )
}

// eslint-disable-next-line react-refresh/only-export-components
export function useToast() {
  const ctx = useContext(ToastContext)
  if (!ctx) throw new Error('useToast phải được dùng bên trong <ToastProvider>')
  return ctx
}
