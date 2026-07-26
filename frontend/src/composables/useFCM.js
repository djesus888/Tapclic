import { messaging, getToken, onMessage } from '@/firebase/config';
import { useAuthStore } from '@/stores/authStore';
import api from '@/axios';

export function useFCM() {
  const authStore = useAuthStore();

  async function requestPermission() {
    try {
      const permission = await Notification.requestPermission();
      if (permission === 'granted') {
        const token = await getToken(messaging, {
          vapidKey: 'BKDkQvAznWBUXT4X0usL3wpkeCcq-kuA4EjQMf84Si-wu6KC0XHJf1ce0HRf0rhJQJosdnO8AwmoxyS0HiI1YCk'
        });
        if (token && authStore.user?.id) {
          await api.post('/fcm/register', {
            token,
            user_id: authStore.user.id
          });
        }
        return token;
      }
    } catch (error) {
      console.error('Error FCM:', error);
    }
    return null;
  }

  function onNotification(callback) {
    onMessage(messaging, (payload) => {
      callback(payload);
    });
  }

  return { requestPermission, onNotification };
}
