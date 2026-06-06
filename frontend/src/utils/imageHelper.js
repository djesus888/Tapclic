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
    avatars: `${baseUrl}/uploads/avatars/`,
    services: `${baseUrl}/uploads/services/`,
    payments: `${baseUrl}/uploads/payments/`,
    billing: `${baseUrl}/uploads/billing/`,
    reviews: `${baseUrl}/uploads/reviews/`,
    messages: `${baseUrl}/uploads/messages/`,
    tickets: `${baseUrl}/uploads/tickets/`,
    system: `${baseUrl}/uploads/system/`,
    logos: `${baseUrl}/uploads/system/logos/`,
    updates: `${baseUrl}/uploads/updates/`
  };

  return (basePaths[type] || basePaths.uploads) + path;
}
