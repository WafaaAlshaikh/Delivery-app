// src/routes/authRoutes.js
const express = require('express');
const router = express.Router();
const {
  signupInitial,
  verifySignup,
  resendOTP,
  login,
  forgotPassword,
  resetPassword,
  verifyOTPOnly,
  logout,
  getProfile,
  updateProfile,
  getAllUsers,
  completeDriverOnboarding,
  getDriverStatus,
  canGoOnline,
  resubmitDriverApplication
} = require('../controllers/authController');
const { auth, authorize } = require('../middleware/auth');

// ============================================
// 📌 PUBLIC ROUTES (No authentication required)
// ============================================
router.post('/signup', signupInitial);
router.post('/verify-signup', verifySignup);
router.post('/resend-otp', resendOTP);
router.post('/login', login);
router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetPassword);
router.post('/verify-otp', verifyOTPOnly);

// ============================================
// 📌 PROTECTED ROUTES (Authentication required)
// ============================================
router.post('/logout', auth, logout);
router.get('/profile', auth, getProfile);
router.put('/profile', auth, updateProfile);

// ============================================
// 📌 ADMIN ROUTES
// ============================================
router.get('/admin/users', auth, authorize('Admin'), getAllUsers);
router.put('/driver/onboarding', auth, authorize('Driver'), completeDriverOnboarding);
router.get('/driver/status', auth, authorize('Driver'), getDriverStatus);
router.get('/driver/can-go-online', auth, authorize('Driver'), canGoOnline);
router.put('/driver/resubmit', auth, authorize('Driver'), resubmitDriverApplication);

module.exports = router;