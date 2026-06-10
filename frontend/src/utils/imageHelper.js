import { useSystemStore } from '@/stores/systemStore'

export function getImageUrl(path, type = 'uploads') {
  if (!path) return '';
  if (path.startsWith('http')) return path;

  // Para imágenes, usar la URL del backend (API), no la del frontend
  let baseUrl = '';
  
  // 1. Usar VITE_API_URL (backend) para construir URLs de imágenes
  const apiUrl = import.meta.env.VITE_API_URL || '';
  baseUrl = apiUrl ? apiUrl.replace(/\/api\/?$/, '') : '';
  
  // 2. Si no hay VITE_API_URL, intentar system_host (producción mismo dominio)
  if (!baseUrl) {
    try {
      const systemStore = useSystemStore();
      if (systemStore.config?.system_host) {
        baseUrl = systemStore.config.system_host.replace(/\/+$/, '');
      }
    } catch (e) {
      // Store no disponible
    }
  }
  
  // 3. Fallback final: window.location
  if (!baseUrl) {
    baseUrl = `${window.location.protocol}//${window.location.host}`;
  }

  // Si ya es una ruta absoluta, devolverla con la base
  if (path.startsWith('/')) {
    return `${baseUrl}${path}`;
  }

  // Rutas base por tipo de archivo
  const basePaths = {
    uploads: `${baseUrl}/uploads/`,
    avatar: `${baseUrl}/uploads/avatars/`,
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

  const basePath = basePaths[type] || basePaths.uploads;

  // Si el path ya incluye la carpeta del tipo, no duplicar
  if (type !== 'uploads' && path.startsWith(type + '/')) {
    return `${baseUrl}/uploads/${path}`;
  }

  // Si el path ya empieza con "uploads/", no duplicar
  if (path.startsWith('uploads/')) {
    return `${baseUrl}/${path}`;
  }

  return basePath + path;
}
