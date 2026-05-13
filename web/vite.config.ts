import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { fileURLToPath, URL } from 'url'

// Vite 配置：开发端口 5173，API 与 WebSocket 代理到 Go 后端 :7070
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://127.0.0.1:7070',
        changeOrigin: true
      },
      '/ws': {
        target: 'ws://127.0.0.1:7070',
        ws: true
      }
    }
  }
})
