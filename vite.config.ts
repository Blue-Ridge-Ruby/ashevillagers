import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import { svelte } from '@sveltejs/vite-plugin-svelte'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [
    RubyPlugin(),
    svelte(),
    tailwindcss(),
  ],
  server: {
    watch: {
      ignored: [
        '**/tmp/**',
        '**/log/**',
        '**/storage/**',
        '**/.git/**',
        '**/public/vite/**',
        '**/node_modules/.vite/**'
      ]
    }
  }
})
