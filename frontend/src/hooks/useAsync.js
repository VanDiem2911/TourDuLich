import { useCallback, useEffect, useRef, useState } from 'react'
import { getErrorMessage } from '../api/client'

/** Tải dữ liệu bất đồng bộ: { data, loading, error, reload }. Bỏ kết quả cũ khi deps đổi. */
export function useAsync(fn, deps = []) {
  const [state, setState] = useState({ data: null, loading: true, error: '', status: 0 })
  const tick = useRef(0)

  const run = useCallback(() => {
    const id = ++tick.current
    setState((s) => ({ ...s, loading: true, error: '' }))
    fn()
      .then((data) => id === tick.current && setState({ data, loading: false, error: '', status: 0 }))
      .catch((e) => id === tick.current && setState({ data: null, loading: false, error: getErrorMessage(e), status: e?.response?.status || 0 }))
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps)

  useEffect(() => {
    run()
  }, [run])

  return { ...state, reload: run }
}

export function useDebounced(value, delay = 350) {
  const [v, setV] = useState(value)
  useEffect(() => {
    const t = setTimeout(() => setV(value), delay)
    return () => clearTimeout(t)
  }, [value, delay])
  return v
}
