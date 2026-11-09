import { createContext, useCallback, useContext, useEffect, useMemo, useState } from 'react'
import { authApi } from '../api/auth'
import { SESSION_EXPIRED_EVENT, tokenStore } from '../api/client'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  // Nếu đang có token thì phải chờ /auth/me xác nhận trước khi quyết định route guard
  const [loading, setLoading] = useState(() => Boolean(tokenStore.getAccess()))

  useEffect(() => {
    if (!tokenStore.getAccess()) return
    let cancelled = false
    authApi
      .me()
      .then((u) => !cancelled && setUser(u))
      .catch(() => {
        if (!cancelled) {
          tokenStore.clear()
          setUser(null)
        }
      })
      .finally(() => !cancelled && setLoading(false))
    return () => {
      cancelled = true
    }
  }, [])

  useEffect(() => {
    const onExpired = () => setUser(null)
    window.addEventListener(SESSION_EXPIRED_EVENT, onExpired)
    return () => window.removeEventListener(SESSION_EXPIRED_EVENT, onExpired)
  }, [])

  const login = useCallback(async (email, password) => {
    const data = await authApi.login({ email, password })
    tokenStore.set(data.accessToken, data.refreshToken)
    setUser(data.user)
    return data.user
  }, [])

  const refreshUser = useCallback(async () => {
    const u = await authApi.me()
    setUser(u)
    return u
  }, [])

  const logout = useCallback(async () => {
    await authApi.logout()
    tokenStore.clear()
    setUser(null)
  }, [])

  const value = useMemo(
    () => ({
      user,
      loading,
      isAuthenticated: Boolean(user),
      isAdmin: user?.role === 'ROLE_ADMIN',
      login,
      logout,
      refreshUser,
    }),
    [user, loading, login, logout, refreshUser],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

// eslint-disable-next-line react-refresh/only-export-components
export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth phải được dùng bên trong <AuthProvider>')
  return ctx
}
