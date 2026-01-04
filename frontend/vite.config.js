import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import { fileURLToPath, URL } from 'url';

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
server: {
  host: true,
  port: 5173,
  strictPort: true,
  hmr: {
    overlay: true
  }
},
  build: {
    outDir: 'dist',
    sourcemap: true,
    rollupOptions: {
      output: { format: 'es' }
    }
  },
  optimizeDeps: {
    exclude: ['@rollup/rollup-android-arm64']
  }
});
