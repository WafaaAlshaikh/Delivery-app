// D:\Delivery\backend\src\routes\driverRoutes.js
const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const {
  getDriverProfile,
  updateDriverProfile,
  toggleDriverOnline,
  updateDriverLocation,
  getDriverStats,
  completeDriverOnboarding,
  getDriverStatus,
  canGoOnline,
  resubmitDriverApplication
} = require('../controllers/authController');

const {
  getAvailableOrders,
  getAvailableOffers,
  getOrderDetailsForDriver,
  acceptOffer,
  rejectOffer,
  acceptOrder,
  updateOrderStatus,        
  getCurrentDelivery,       
} = require('../controllers/driverController');

router.use(auth);
router.use(authorize('Driver'));

router.get('/profile', getDriverProfile);
router.put('/profile', updateDriverProfile);
router.put('/online', toggleDriverOnline);
router.put('/location', updateDriverLocation); 
router.get('/stats', getDriverStats);

router.get('/offers', getAvailableOffers);
router.put('/offers/:offerId/accept', acceptOffer);
router.put('/offers/:offerId/reject', rejectOffer);

router.get('/orders/available', getAvailableOrders);
router.get('/orders/:orderId', getOrderDetailsForDriver);
router.put('/orders/:orderId/accept', acceptOrder);

router.put('/orders/:orderId/status', auth, authorize('Driver'), updateOrderStatus);
router.put('/orders/:orderId/location', auth, authorize('Driver'), updateDriverLocation);
router.get('/delivery/current', auth, authorize('Driver'), getCurrentDelivery);

module.exports = router;