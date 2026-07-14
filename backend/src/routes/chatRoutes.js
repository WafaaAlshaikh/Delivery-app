// backend/src/routes/chatRoutes.js

const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const {
  sendMessage,
  getChatHistory,
  getUnreadCount,
  markAsRead,
  notifyOnTheWay,
  notifyArrived,
  getSmartSuggestions,
} = require('../controllers/chatController');

router.use(auth);
router.use(authorize('Driver'));

router.get('/history', getChatHistory);

router.post('/send', sendMessage);

router.get('/unread', getUnreadCount);

router.post('/suggestions', getSmartSuggestions);

router.put('/read/:messageId', markAsRead);

router.post('/on-the-way', notifyOnTheWay);

router.post('/arrived', notifyArrived);

module.exports = router;