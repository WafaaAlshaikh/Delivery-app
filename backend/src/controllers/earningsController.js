// backend/src/controllers/earningsController.js

const EarningsService = require('../services/earningsService');

const getEarningsSummary = async (req, res) => {
  try {
    const driverId = req.user.user_id;
    
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('💰 [EARNINGS] Getting earnings summary');
    console.log(`   ├─ Driver ID: ${driverId}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const summary = await EarningsService.getEarningsSummary(driverId);

    console.log('✅ Earnings summary fetched successfully');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      data: summary
    });
  } catch (error) {
    console.error('❌ Get earnings summary error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching earnings summary'
    });
  }
};

const getEarningsChart = async (req, res) => {
  try {
    const driverId = req.user.user_id;
    const { period = 'daily' } = req.query;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📊 [EARNINGS] Getting earnings chart');
    console.log(`   ├─ Driver ID: ${driverId}`);
    console.log(`   └─ Period: ${period}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const chartData = await EarningsService.getEarningsChart(driverId, period);

    console.log('✅ Earnings chart fetched successfully');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      data: chartData
    });
  } catch (error) {
    console.error('❌ Get earnings chart error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching chart data'
    });
  }
};

const getEarningsHistory = async (req, res) => {
  try {
    const driverId = req.user.user_id;
    const {
      page = 1,
      limit = 20,
      status,
      from,
      to
    } = req.query;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📋 [EARNINGS] Getting earnings history');
    console.log(`   ├─ Driver ID: ${driverId}`);
    console.log(`   ├─ Page: ${page}`);
    console.log(`   └─ Status: ${status || 'All'}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const result = await EarningsService.getEarningsHistory(driverId, {
      page: parseInt(page),
      limit: parseInt(limit),
      status,
      from: from ? new Date(from) : null,
      to: to ? new Date(to) : null
    });

    const responseData = {
      earnings: result.earnings || [],
      total: result.total || 0,
      pages: result.pages || 1
    };

    console.log(`✅ Found ${responseData.earnings.length} earnings records`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      data: responseData
    });
  } catch (error) {
    console.error('❌ Get earnings history error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching earnings history',
      error: error.message 
    });
  }
};

const getEarningsPrediction = async (req, res) => {
  try {
    const driverId = req.user.user_id;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('🤖 [EARNINGS] Getting AI prediction');
    console.log(`   ├─ Driver ID: ${driverId}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const prediction = await EarningsService.predictEarnings(driverId);

    console.log('✅ AI prediction generated successfully');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      data: prediction  
    });
  } catch (error) {
    console.error('❌ Get earnings prediction error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error generating prediction'
    });
  }
};


const exportReport = async (req, res) => {
  try {
    const driverId = req.user.user_id;
    const { format = 'pdf', period = 'daily' } = req.body;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📄 [EARNINGS] Exporting report');
    console.log(`   ├─ Driver ID: ${driverId}`);
    console.log(`   ├─ Format: ${format}`);
    console.log(`   └─ Period: ${period}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const result = await EarningsService.exportReport(driverId, format, period);

    console.log('✅ Report exported successfully');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error('❌ Export report error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error exporting report'
    });
  }
};

const updatePaymentStatus = async (req, res) => {
  try {
    const { earningId } = req.params;
    const { status } = req.body;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('🔄 [EARNINGS] Updating payment status');
    console.log(`   ├─ Earning ID: ${earningId}`);
    console.log(`   └─ Status: ${status}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const { Earning } = require('../models');
    
    const earning = await Earning.findByPk(earningId);
    if (!earning) {
      return res.status(404).json({
        success: false,
        message: 'Earning record not found'
      });
    }

    await earning.update({
      status: status,
      paid_at: status === 'completed' ? new Date() : null
    });

    console.log('✅ Payment status updated successfully');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      message: 'Payment status updated successfully',
      data: earning
    });
  } catch (error) {
    console.error('❌ Update payment status error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error updating payment status'
    });
  }
};

module.exports = {
  getEarningsSummary,
  getEarningsChart,
  getEarningsHistory,
  getEarningsPrediction,
  exportReport,
  updatePaymentStatus
};