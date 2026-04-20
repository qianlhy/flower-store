/**
 * 将图片完整URL转为相对路径，确保开发环境走Vite代理、生产环境走Nginx反代
 * 例如: "https://ru.ruasiagarden.com/api/uploads/2026/04/16/a.png" → "/api/uploads/2026/04/16/a.png"
 */
export function getImageUrl(url) {
  if (!url) return ''
  const idx = url.indexOf('/api/uploads/')
  if (idx !== -1) {
    return url.substring(idx)
  }
  return url
}
