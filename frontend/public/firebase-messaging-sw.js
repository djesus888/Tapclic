importScripts('https://www.gstatic.com/firebasejs/10.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.0.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyAXVjm18tqnaOi6Wfhgt-l8vDSxSNA49wY",
  authDomain: "tapclic-2672c.firebaseapp.com",
  projectId: "tapclic-2672c",
  storageBucket: "tapclic-2672c.firebasestorage.app",
  messagingSenderId: "765132899419",
  appId: "1:765132899419:web:f82e32e26861250f7fab7e"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/img/logo.png'
  };
  self.registration.showNotification(notificationTitle, notificationOptions);
});
