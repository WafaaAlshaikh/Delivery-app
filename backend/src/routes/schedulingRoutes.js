// backend/src/routes/schedulingRoutes.js

const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const {
  getScheduledOrders,
  optimizeRoute,
  suggestOptimalTime,
  confirmSchedule,
  cancelSchedule,
  createSchedule
} = require('../controllers/schedulingController');

router.use(auth);
router.use(authorize('Driver'));

router.get('/orders', getScheduledOrders);

router.get('/optimize-route', optimizeRoute);

router.post('/suggest-time', suggestOptimalTime);

router.put('/confirm/:scheduled_id', confirmSchedule);

router.put('/cancel/:scheduled_id', cancelSchedule);

router.post('/create', createSchedule);

module.exports = router;