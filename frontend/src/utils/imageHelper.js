export function getImageUrl(path, type = 'uploads') {
  if (!path) return '';
  if (path.startsWith('http')) return path;

  // Obtener la URL base y quitarle el /api del final
  const apiUrl = import.meta.env.VITE_API_URL || 'http://192.168.110.33:8000/api';
  const baseUrl = apiUrl.replace(/\/api\/?$/, '');

  if (path.startsWith('/')) {
    return `${baseUrl}${path}`;
  }

  const basePaths = {
    uploads: `${baseUrl}/uploads/`,
    avatar: `${baseUrl}/uploads/avatars/`,
    logo: `${baseUrl}/logos/`,
    service: `${baseUrl}/uploads/services/`,
    payments: `${baseUrl}/uploads/payments/`,
    reviews: `${baseUrl}/uploads/reviews/`,
    'user-reviews': `${baseUrl}/uploads/user-reviews/`
  };

  return (basePaths[type] || basePaths.uploads) + path;
}
