// backend/src/routes/driverRoutes.js
const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const {
  getDriverProfile,
  updateDriverProfile,
  toggleDriverOnline,
  updateDriverLocation,
  getDriverStats
} = require('../controllers/authController');
const {
  getAvailableOrders,
  getOrderDetailsForDriver
} = require('../controllers/driverController');

// ✅ All routes require auth + driver role
router.use(auth);
router.use(authorize('Driver'));

// ✅ Driver Profile Routes
router.get('/profile', getDriverProfile);
router.put('/profile', updateDriverProfile);
router.put('/online', toggleDriverOnline);
router.put('/location', updateDriverLocation);
router.get('/stats', getDriverStats);

// ✅ Order Routes (NEW)
router.get('/orders/available', getAvailableOrders);
router.get('/orders/:orderId', getOrderDetailsForDriver);

module.exports = router;