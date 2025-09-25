export function sanitize (str = '') {
  if (typeof str !== 'string') return str
  return str.replace(/<script[^>]*>.*?<\/script>/gis, '')
            .replace(/<[^>]+>/g, '')
            .trim()
}
