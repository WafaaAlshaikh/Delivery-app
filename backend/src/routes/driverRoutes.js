// src/routes/driverRoutes.js
const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const {
  getDriverProfile,
  updateDriverProfile,
  toggleDriverOnline,
  updateDriverLocation,
  getDriverStats
} = require('../controllers/authController');

// ============================================
// 📌 ALL ROUTES REQUIRE AUTH
// ============================================
router.use(auth);

// ============================================
// 📌 DRIVER ROUTES
// ============================================
router.get('/profile', getDriverProfile);
router.put('/profile', updateDriverProfile);
router.put('/online', toggleDriverOnline);
router.put('/location', updateDriverLocation);
router.get('/stats', getDriverStats);

module.exports = router;