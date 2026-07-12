// src/routes/orderRoutes.js
const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const {
  createOrder,
  getMyOrders,
  getAvailableOrders,
  updateOrderStatus
} = require('../controllers/orderController');

router.post('/', auth, authorize('Customer'), createOrder);
router.get('/my', auth, getMyOrders);
router.get('/available', auth, authorize('Driver'), getAvailableOrders);
router.put('/:id/status', auth, updateOrderStatus);

module.exports = router;
