import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// Dev server proxy /api -> Spring Boot (8080): cùng origin nên cookie JSESSIONID (Session Cart) hoạt động
// mà không vướng CORS.
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: false,
      },
      // Ảnh do Admin tải lên được backend phục vụ tại /uploads
      '/uploads': {
        target: 'http://localhost:8080',
        changeOrigin: false,
      },
    },
  },
})
