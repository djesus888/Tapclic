import { initializeApp } from 'firebase/app';
import { getMessaging, getToken, onMessage } from 'firebase/messaging';

const firebaseConfig = {
  apiKey: "AIzaSyAXVjm18tqnaOi6Wfhgt-l8vDSxSNA49wY",
  authDomain: "tapclic-2672c.firebaseapp.com",
  projectId: "tapclic-2672c",
  storageBucket: "tapclic-2672c.firebasestorage.app",
  messagingSenderId: "765132899419",
  appId: "1:765132899419:web:f82e32e26861250f7fab7e"
};

const app = initializeApp(firebaseConfig);
const messaging = getMessaging(app);

export { messaging, getToken, onMessage };
