// web/firebase-messaging-sw.js

// ✅ استيراد Firebase SDK في Service Worker
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js');

// ✅ تكوين Firebase (نفس القيم)
const firebaseConfig = {
  apiKey: "AIzaSyC84uzCJlzhsdCY16UTtYgtW4uiC-QT7MY",
  authDomain: "delivery-d2e88.firebaseapp.com",
  projectId: "delivery-d2e88",
  storageBucket: "delivery-d2e88.firebasestorage.app",
  messagingSenderId: "37666647494",
  appId: "1:37666647494:web:19000ef6c4688d3c4c16c7",
  measurementId: "G-336PFW8FN4"
};

// ✅ تهيئة Firebase في Service Worker
firebase.initializeApp(firebaseConfig);

// ✅ تهيئة Messaging
const messaging = firebase.messaging();

// ✅ معالجة الإشعارات في الخلفية
messaging.onBackgroundMessage(function(payload) {
  console.log('📨 [Service Worker] Received background message: ', payload);
  
  const notificationTitle = payload.notification?.title || 'New Notification';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png',
    badge: '/icons/badge-72x72.png',
    data: payload.data || {},
    vibrate: [200, 100, 200],
  };

  // عرض الإشعار
  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// ✅ معالجة النقر على الإشعار
self.addEventListener('notificationclick', function(event) {
  console.log('📨 [Service Worker] Notification clicked:', event.notification);
  
  event.notification.close();
  
  // تحديد الرابط المطلوب
  const clickAction = event.notification.data?.click_action || '/';
  
  event.waitUntil(
    clients.openWindow(clickAction)
  );
});

console.log('✅ Firebase Messaging Service Worker initialized');