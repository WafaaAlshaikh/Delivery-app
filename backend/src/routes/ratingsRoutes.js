// backend/src/routes/ratingsRoutes.js

const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const {
  getDriverRatings,
  getRatingsSummary,
  getAIInsights,
  createRating,
  getRatingReport,
  getCityAnalytics,    
  getDriverRanking
} = require('../controllers/ratingsController');

router.use(auth);

router.post('/', authorize('Customer'), createRating);

router.get('/driver', authorize('Driver'), getDriverRatings);
router.get('/driver/summary', authorize('Driver'), getRatingsSummary);
router.get('/driver/insights', authorize('Driver'), getAIInsights);
router.get('/driver/report', authorize('Driver'), getRatingReport);
router.get('/driver/analytics/cities', authorize('Driver'), getCityAnalytics);
router.get('/driver/analytics/ranking', authorize('Driver'), getDriverRanking);

module.exports = router;