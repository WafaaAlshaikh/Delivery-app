// backend/src/controllers/ratingsController.js

const RatingsService = require('../services/ratingsService');
const NotificationService = require('../services/notificationService');

const getDriverRatings = async (req, res) => {
  try {
    const driverId = req.user.user_id;
    const { page = 1, limit = 20, sentiment = null } = req.query;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('⭐ [RATINGS] Getting driver ratings');
    console.log(`   ├─ Driver ID: ${driverId}`);
    console.log(`   └─ Sentiment: ${sentiment || 'All'}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const result = await RatingsService.getDriverRatings(driverId, {
      page: parseInt(page),
      limit: parseInt(limit),
      sentiment
    });

    console.log(`✅ Found ${result.ratings.length} ratings`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error('❌ Get driver ratings error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching ratings'
    });
  }
};

const getCityAnalytics = async (req, res) => {
  try {
    const driverId = req.user.user_id;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📍 [RATINGS] Getting city analytics');
    console.log(`   ├─ Driver ID: ${driverId}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const data = await RatingsService.getCityAnalytics(driverId);

    console.log('✅ City analytics fetched');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      data: data
    });
  } catch (error) {
    console.error('❌ Get city analytics error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching city analytics'
    });
  }
};

const getDriverRanking = async (req, res) => {
  try {
    const driverId = req.user.user_id;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('🏆 [RATINGS] Getting driver ranking');
    console.log(`   ├─ Driver ID: ${driverId}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const data = await RatingsService.getDriverRanking(driverId);

    console.log('✅ Driver ranking fetched');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      data: data
    });
  } catch (error) {
    console.error('❌ Get driver ranking error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching driver ranking'
    });
  }
};

const getRatingReport = async (req, res) => {
  try {
    const driverId = req.user.user_id;
    const { year, month } = req.query;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📄 [RATINGS] Getting rating report');
    console.log(`   ├─ Driver ID: ${driverId}`);
    console.log(`   └─ Month: ${month}/${year}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const data = await RatingsService.getRatingReport(driverId, parseInt(year), parseInt(month));

    console.log('✅ Rating report fetched');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      data: data
    });
  } catch (error) {
    console.error('❌ Get rating report error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching report'
    });
  }
};

const getRatingsSummary = async (req, res) => {
  try {
    const driverId = req.user.user_id;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📊 [RATINGS] Getting ratings summary');
    console.log(`   ├─ Driver ID: ${driverId}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const summary = await RatingsService.getRatingsSummary(driverId);

    console.log('✅ Ratings summary fetched');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      data: summary
    });
  } catch (error) {
    console.error('❌ Get ratings summary error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching ratings summary'
    });
  }
};

const getAIInsights = async (req, res) => {
  try {
    const driverId = req.user.user_id;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('🧠 [RATINGS] Getting AI insights');
    console.log(`   ├─ Driver ID: ${driverId}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const insights = await RatingsService.getAIInsights(driverId);

    console.log('✅ AI insights generated');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      data: insights
    });
  } catch (error) {
    console.error('❌ Get AI insights error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error generating AI insights'
    });
  }
};

const createRating = async (req, res) => {
  try {
    const { order_id, rating, comment, delivery_time } = req.body;
    const customerId = req.user.user_id;

    const { Order, User } = require('../models');
    const order = await Order.findByPk(order_id);
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    if (order.customer_id !== customerId) {
      return res.status(403).json({
        success: false,
        message: 'You are not the owner of this order'
      });
    }

    if (order.status_id !== 8) {
      return res.status(400).json({
        success: false,
        message: 'Order must be delivered before rating'
      });
    }

    const { Rating } = require('../models');
    const existing = await Rating.findOne({
      where: { order_id: order_id }
    });

    if (existing) {
      return res.status(400).json({
        success: false,
        message: 'This order has already been rated'
      });
    }

    const newRating = await RatingsService.createRating(
      order_id,
      customerId,
      order.driver_id,
      rating,
      comment,
      delivery_time
    );

    if (newRating && order.driver_id) {
      const driver = await User.findByPk(order.driver_id);
      
      if (driver && driver.fcm_token) {
        if (rating < 3) {
          await NotificationService.sendLowRatingNotification(
            driver.fcm_token,
            driver.full_name,
            rating,
            comment,
            order_id
          );
        } else if (rating >= 4.5) {
          await NotificationService.sendExcellentRatingNotification(
            driver.fcm_token,
            driver.full_name,
            rating,
            comment,
            order_id
          );
        }
      }
    }

    res.status(201).json({
      success: true,
      message: 'Rating created successfully',
      data: newRating
    });

  } catch (error) {
    console.error('❌ Create rating error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error creating rating'
    });
  }
};



module.exports = {
  getDriverRatings,
  getRatingsSummary,
  getAIInsights,
  createRating,
  getRatingReport,
  getCityAnalytics, 
  getDriverRanking, 
};