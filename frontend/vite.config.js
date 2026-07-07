import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    proxy: {
      '/chat': 'http://localhost:8000',
      '/knowledge': 'http://localhost:8000',
      '/video': 'http://localhost:8001',
      '/ws/video': 'ws://localhost:8001',
      '/ws/agent': 'ws://localhost:8001',
    },
  },
});