import react from '@vitejs/plugin-react'
import { defineConfig, type ProxyOptions } from 'vite'

const NHL_ORIGIN = 'https://api-web.nhle.com'

// /v1/schedule/now answers with a redirect to a dated path. Keep that redirect
// on this origin so the browser does not call the NHL API directly (no CORS).
function nhlProxy(): ProxyOptions {
  return {
    target: NHL_ORIGIN,
    changeOrigin: true,
    rewrite: (requestPath) => requestPath.replace(/^\/nhl/, ''),
    configure: (proxy) => {
      proxy.on('proxyRes', (proxyRes) => {
        const location = proxyRes.headers.location
        if (typeof location !== 'string' || !location.startsWith(NHL_ORIGIN)) {
          return
        }
        proxyRes.headers.location = `/nhl${location.slice(NHL_ORIGIN.length)}`
      })
    },
  }
}

export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/nhl': nhlProxy(),
    },
  },
  preview: {
    proxy: {
      '/nhl': nhlProxy(),
    },
  },
})
