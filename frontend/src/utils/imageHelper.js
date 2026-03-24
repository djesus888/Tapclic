export function getImageUrl(path, type = 'uploads') {
  if (!path) return '';
  if (path.startsWith('http')) return path;
  
  const baseUrl = import.meta.env.VITE_API_URL;
  
  if (path.startsWith('/')) {
    return `${baseUrl}${path}`;
  }
  
  const basePaths = {
    uploads: `${baseUrl}/uploads/`,
    avatar: `${baseUrl}/uploads/avatars/`,
    logo: `${baseUrl}/logos/`,
    service: `${baseUrl}/uploads/services/`
  };
  
  return (basePaths[type] || basePaths.uploads) + path;
}
