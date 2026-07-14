// backend/src/controllers/schedulingController.js

const SchedulingService = require('../services/schedulingService');

const getScheduledOrders = async (req, res) => {
  try {
    const driverId = req.user.user_id;
    const { date } = req.query;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📅 [SCHEDULING] Getting scheduled orders');
    console.log(`   ├─ Driver ID: ${driverId}`);
    console.log(`   └─ Date: ${date || 'Today'}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const scheduled = await SchedulingService.getScheduledOrders(driverId, date);

    res.status(200).json({
      success: true,
      data: scheduled
    });
  } catch (error) {
    console.error('❌ Get scheduled orders error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching scheduled orders'
    });
  }
};

const optimizeRoute = async (req, res) => {
  try {
    const driverId = req.user.user_id;
    const { date } = req.query;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('🗺️ [SCHEDULING] Optimizing route');
    console.log(`   ├─ Driver ID: ${driverId}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const optimized = await SchedulingService.optimizeRouteForDriver(driverId, date);

    res.status(200).json({
      success: true,
      data: optimized
    });
  } catch (error) {
    console.error('❌ Optimize route error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error optimizing route'
    });
  }
};

const suggestOptimalTime = async (req, res) => {
  try {
    const driverId = req.user.user_id;
    const { order_id } = req.body;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('🤖 [SCHEDULING] Suggesting optimal time');
    console.log(`   ├─ Driver ID: ${driverId}`);
    console.log(`   └─ Order ID: ${order_id}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const suggestion = await SchedulingService.suggestOptimalTime(driverId, order_id);

    res.status(200).json({
      success: true,
      data: suggestion
    });
  } catch (error) {
    console.error('❌ Suggest optimal time error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error suggesting time'
    });
  }
};

const confirmSchedule = async (req, res) => {
  try {
    const driverId = req.user.user_id;
    const { scheduled_id } = req.params;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('✅ [SCHEDULING] Confirming schedule');
    console.log(`   ├─ Driver ID: ${driverId}`);
    console.log(`   └─ Schedule ID: ${scheduled_id}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const scheduled = await SchedulingService.confirmSchedule(scheduled_id, driverId);

    res.status(200).json({
      success: true,
      data: scheduled
    });
  } catch (error) {
    console.error('❌ Confirm schedule error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error confirming schedule'
    });
  }
};

const cancelSchedule = async (req, res) => {
  try {
    const driverId = req.user.user_id;
    const { scheduled_id } = req.params;
    const { reason } = req.body;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('❌ [SCHEDULING] Cancelling schedule');
    console.log(`   ├─ Driver ID: ${driverId}`);
    console.log(`   └─ Schedule ID: ${scheduled_id}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const scheduled = await SchedulingService.cancelSchedule(scheduled_id, driverId, reason);

    res.status(200).json({
      success: true,
      data: scheduled
    });
  } catch (error) {
    console.error('❌ Cancel schedule error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error cancelling schedule'
    });
  }
};

const createSchedule = async (req, res) => {
  try {
    const driverId = req.user.user_id;
    const { order_id, scheduled_time, priority } = req.body;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📅 [SCHEDULING] Creating schedule');
    console.log(`   ├─ Driver ID: ${driverId}`);
    console.log(`   └─ Order ID: ${order_id}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const orderIdInt = parseInt(order_id);
    if (isNaN(orderIdInt)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid order ID'
      });
    }

    const scheduled = await SchedulingService.createSchedule({
      orderId: orderIdInt, 
      driverId: driverId,
      scheduledTime: new Date(scheduled_time),
      priority: priority || 0
    });

    res.status(201).json({
      success: true,
      data: scheduled
    });
  } catch (error) {
    console.error('❌ Create schedule error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Server error creating schedule'
    });
  }
};

module.exports = {
  getScheduledOrders,
  optimizeRoute,
  suggestOptimalTime,
  confirmSchedule,
  cancelSchedule,
  createSchedule
};