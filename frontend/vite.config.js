import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

const API = process.env.API_PROXY || 'http://localhost:8080'

// Dev server proxy /api -> Spring Boot (mặc định 8080, đổi bằng biến môi trường API_PROXY): cùng origin nên cookie JSESSIONID (Session Cart) hoạt động
// mà không vướng CORS.
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: API,
        changeOrigin: false,
      },
      // Ảnh do Admin tải lên được backend phục vụ tại /uploads
      '/uploads': {
        target: API,
        changeOrigin: false,
      },
    },
  },
})
