// backend/src/routes/earningsRoutes.js

const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const {
  getEarningsSummary,
  getEarningsChart,
  getEarningsHistory,
  getEarningsPrediction,
  exportReport,
  updatePaymentStatus
} = require('../controllers/earningsController');

router.use(auth);
router.use(authorize('Driver'));

router.get('/summary', getEarningsSummary);

router.get('/chart', getEarningsChart);

router.get('/history', getEarningsHistory);

router.get('/prediction', getEarningsPrediction);

router.post('/export', exportReport);

router.put('/:earningId/status', updatePaymentStatus);

module.exports = router;