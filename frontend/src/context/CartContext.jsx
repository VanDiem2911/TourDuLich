import { createContext, useCallback, useContext, useEffect, useMemo, useState } from 'react'
import { cartApi } from '../api'

const CartContext = createContext(null)
const EMPTY = { items: [], totalItems: 0, totalAmount: 0 }

/** Giỏ tour nằm trong HTTP Session ở backend; context giữ bản sao để hiển thị và đếm số trên header. */
export function CartProvider({ children }) {
  const [cart, setCart] = useState(EMPTY)
  const [loading, setLoading] = useState(true)

  const refresh = useCallback(async () => {
    try {
      setCart(await cartApi.get())
    } catch {
      setCart(EMPTY)
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    refresh()
  }, [refresh])

  const run = useCallback(async (fn) => {
    const next = await fn()
    setCart(next)
    return next
  }, [])

  const value = useMemo(
    () => ({
      cart,
      loading,
      count: cart.items.length,
      refresh,
      add: (body) => run(() => cartApi.add(body)),
      update: (tourId, body) => run(() => cartApi.update(tourId, body)),
      remove: (tourId) => run(() => cartApi.remove(tourId)),
      clear: () => run(() => cartApi.clear()),
    }),
    [cart, loading, refresh, run],
  )

  return <CartContext.Provider value={value}>{children}</CartContext.Provider>
}

// eslint-disable-next-line react-refresh/only-export-components
export function useCart() {
  const ctx = useContext(CartContext)
  if (!ctx) throw new Error('useCart phải được dùng bên trong <CartProvider>')
  return ctx
}
