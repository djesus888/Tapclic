import { useAuthStore } from '@/stores/authStore';
import api from '@/axios';

export function useFCM() {
  const authStore = useAuthStore();

  async function requestPermission() {
    if (!('Notification' in window) || !('serviceWorker' in navigator)) {
      return null;
    }
    try {
      const { messaging, getToken } = await import('@/firebase/config');
      const permission = await Notification.requestPermission();
      if (permission === 'granted') {
        const token = await getToken(messaging, {
          vapidKey: 'BKDkQvAznWBUXT4X0usL3wpkeCcq-kuA4EjQMf84Si-wu6KC0XHJf1ce0HRf0rhJQJosdnO8AwmoxyS0HiI1YCk'
        });
        if (token && authStore.user?.id) {
          await api.post('/fcm/register', { token });
        }
        return token;
      }
    } catch (e) {
      console.log('🔕 FCM no disponible en este navegador');
    }
    return null;
  }

  function onNotification(callback) {
    try {
      import('@/firebase/config').then(({ messaging, onMessage }) => {
        onMessage(messaging, callback);
      }).catch(() => {});
    } catch (e) {}
  }

  return { requestPermission, onNotification };
}
