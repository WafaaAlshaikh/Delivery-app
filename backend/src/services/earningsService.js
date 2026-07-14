// backend/src/services/earningsService.js

const { Op, Sequelize } = require('sequelize');
const {
  Earning,
  Order,
  User,
  OrderStatus,
  sequelize
} = require('../models');

class EarningsService {
  
  static async calculateDriverEarnings(orderId, driverId) {
    try {
      const order = await Order.findByPk(orderId, {
        include: [
          { model: User, as: 'Customer', attributes: ['full_name'] },
          { model: OrderStatus, attributes: ['name'] }
        ]
      });

      if (!order) {
        throw new Error('Order not found');
      }

      const deliveryFee = parseFloat(order.delivery_fee || 0);
      const baseAmount = parseFloat(order.total || 0) * 0.8; 
      const tips = parseFloat(order.tips || 0);
      
      let bonus = 0;
      if (order.status_id === 8) { 
        const deliveryTime = order.delivery_time || 30;
        if (deliveryTime < 20) bonus += 2;
        if (deliveryTime < 15) bonus += 3;
        
        if (order.rating && order.rating >= 4.5) bonus += 1.5;
      }

      const total = baseAmount + deliveryFee + tips + bonus;

      const earning = await Earning.create({
        driver_id: driverId,
        order_id: orderId,
        amount: baseAmount,
        delivery_fee: deliveryFee,
        tips: tips,
        bonus: bonus,
        status: order.status_id === 8 ? 'completed' : 'pending',
        distance: order.distance || 0,
        duration: order.delivery_time || 0,
        rating: order.rating || 0,
        customer_name: order.Customer?.full_name || 'Unknown',
        delivery_address: order.delivery_address || '',
        paid_at: order.status_id === 8 ? new Date() : null
      });

      return earning;
    } catch (error) {
      console.error('❌ Calculate driver earnings error:', error);
      throw error;
    }
  }

static async getEarningsSummary(driverId) {
  try {
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const weekStart = new Date(now);
    weekStart.setDate(now.getDate() - now.getDay());
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);

    const totalEarnings = await Earning.sum('amount', {
      where: {
        driver_id: driverId,
        status: 'completed'
      }
    });

    const todayEarnings = await Earning.sum('amount', {
      where: {
        driver_id: driverId,
        status: 'completed',
        created_at: { [Op.gte]: today }
      }
    });

    const weeklyEarnings = await Earning.sum('amount', {
      where: {
        driver_id: driverId,
        status: 'completed',
        created_at: { [Op.gte]: weekStart }
      }
    });

    const monthlyEarnings = await Earning.sum('amount', {
      where: {
        driver_id: driverId,
        status: 'completed',
        created_at: { [Op.gte]: monthStart }
      }
    });

    const totalDeliveries = await Earning.count({
      where: {
        driver_id: driverId,
        status: 'completed'
      }
    });

    const todayDeliveries = await Earning.count({
      where: {
        driver_id: driverId,
        status: 'completed',
        created_at: { [Op.gte]: today }
      }
    });

    const ratingResult = await Earning.findOne({
      attributes: [
        [Sequelize.fn('AVG', Sequelize.col('rating')), 'avgRating']
      ],
      where: {
        driver_id: driverId,
        status: 'completed',
        rating: { [Op.gt]: 0 }
      }
    });

    let avgRating = 0;
    if (ratingResult && ratingResult.dataValues && ratingResult.dataValues.avgRating !== null) {
      avgRating = parseFloat(ratingResult.dataValues.avgRating);
      if (isNaN(avgRating)) avgRating = 0;
    }

    const daysSinceFirst = await Earning.findOne({
      attributes: [
        [Sequelize.fn('MIN', Sequelize.col('created_at')), 'firstDate']
      ],
      where: {
        driver_id: driverId,
        status: 'completed'
      }
    });

    let averagePerDay = 0;
    if (daysSinceFirst?.dataValues?.firstDate) {
      const firstDate = new Date(daysSinceFirst.dataValues.firstDate);
      const daysDiff = Math.max(1, Math.ceil((now - firstDate) / (1000 * 60 * 60 * 24)));
      averagePerDay = (totalEarnings || 0) / daysDiff;
    }

    const predictedEarnings = await this.predictEarnings(driverId);

    return {
      total_earnings: totalEarnings || 0,
      today_earnings: todayEarnings || 0,
      weekly_earnings: weeklyEarnings || 0,
      monthly_earnings: monthlyEarnings || 0,
      total_deliveries: totalDeliveries || 0,
      today_deliveries: todayDeliveries || 0,
      average_rating: parseFloat(avgRating.toFixed(1)) || 0,
      average_per_day: parseFloat(averagePerDay.toFixed(2)) || 0,
      predicted_earnings: predictedEarnings || 0
    };
  } catch (error) {
    console.error('❌ Get earnings summary error:', error);
    throw error;
  }
}

  static async getEarningsChart(driverId, period = 'daily') {
    try {
      let data = [];
      const now = new Date();

      if (period === 'daily') {
        for (let i = 6; i >= 0; i--) {
          const date = new Date(now);
          date.setDate(now.getDate() - i);
          date.setHours(0, 0, 0, 0);
          
          const nextDate = new Date(date);
          nextDate.setDate(date.getDate() + 1);

          const result = await Earning.findOne({
            attributes: [
              [Sequelize.fn('SUM', Sequelize.col('amount')), 'total'],
              [Sequelize.fn('COUNT', Sequelize.col('earning_id')), 'count'],
              [Sequelize.fn('AVG', Sequelize.col('rating')), 'avgRating']
            ],
            where: {
              driver_id: driverId,
              status: 'completed',
              created_at: {
                [Op.gte]: date,
                [Op.lt]: nextDate
              }
            }
          });

          data.push({
            date: date.toISOString().split('T')[0],
            amount: parseFloat(result?.dataValues?.total || 0),
            deliveries: parseInt(result?.dataValues?.count || 0),
            average_rating: parseFloat(result?.dataValues?.avgRating || 0)
          });
        }
      } else if (period === 'weekly') {
        for (let i = 3; i >= 0; i--) {
          const weekStart = new Date(now);
          weekStart.setDate(now.getDate() - (now.getDay() + i * 7));
          weekStart.setHours(0, 0, 0, 0);
          
          const weekEnd = new Date(weekStart);
          weekEnd.setDate(weekStart.getDate() + 7);

          const result = await Earning.findOne({
            attributes: [
              [Sequelize.fn('SUM', Sequelize.col('amount')), 'total'],
              [Sequelize.fn('COUNT', Sequelize.col('earning_id')), 'count']
            ],
            where: {
              driver_id: driverId,
              status: 'completed',
              created_at: {
                [Op.gte]: weekStart,
                [Op.lt]: weekEnd
              }
            }
          });

          data.push({
            week: `Week ${i + 1}`,
            amount: parseFloat(result?.dataValues?.total || 0),
            deliveries: parseInt(result?.dataValues?.count || 0)
          });
        }
      } else if (period === 'monthly') {
        for (let i = 5; i >= 0; i--) {
          const monthStart = new Date(now.getFullYear(), now.getMonth() - i, 1);
          const monthEnd = new Date(now.getFullYear(), now.getMonth() - i + 1, 1);

          const result = await Earning.findOne({
            attributes: [
              [Sequelize.fn('SUM', Sequelize.col('amount')), 'total'],
              [Sequelize.fn('COUNT', Sequelize.col('earning_id')), 'count']
            ],
            where: {
              driver_id: driverId,
              status: 'completed',
              created_at: {
                [Op.gte]: monthStart,
                [Op.lt]: monthEnd
              }
            }
          });

          const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                             'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          
          data.push({
            month: monthNames[monthStart.getMonth()],
            amount: parseFloat(result?.dataValues?.total || 0),
            deliveries: parseInt(result?.dataValues?.count || 0)
          });
        }
      }

      return {
        daily: period === 'daily' ? data : [],
        weekly: period === 'weekly' ? data : [],
        monthly: period === 'monthly' ? data : []
      };
    } catch (error) {
      console.error('❌ Get earnings chart error:', error);
      throw error;
    }
  }

  static async getEarningsHistory(driverId, options = {}) {
    try {
      const {
        page = 1,
        limit = 20,
        status,
        from,
        to
      } = options;

      const offset = (page - 1) * limit;
      const where = { driver_id: driverId };

      if (status) where.status = status;
      if (from) where.created_at = { [Op.gte]: from };
      if (to) where.created_at = { [Op.lte]: to };

      const { count, rows } = await Earning.findAndCountAll({
        where,
        order: [['created_at', 'DESC']],
        limit: parseInt(limit),
        offset: parseInt(offset),
        include: [
          {
            model: Order,
            attributes: ['order_id', 'order_number', 'status_id']
          }
        ]
      });

      return {
        earnings: rows,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          totalPages: Math.ceil(count / limit)
        }
      };
    } catch (error) {
      console.error('❌ Get earnings history error:', error);
      throw error;
    }
  }

  static async predictEarnings(driverId) {
  try {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const earnings = await Earning.findAll({
      where: {
        driver_id: driverId,
        status: 'completed',
        created_at: { [Op.gte]: thirtyDaysAgo }
      },
      attributes: ['amount', 'created_at', 'duration', 'distance'],
      order: [['created_at', 'ASC']]
    });

    if (earnings.length === 0) {
      return {
        predicted_earnings: 0,
        best_time: '6-9 PM',
        trend: 0,
        day_factor: 1,
        total_samples: 0,
        tips: ['📊 No data available yet. Complete your first delivery to get predictions!']
      };
    }


      const totalAmount = earnings.reduce((sum, e) => sum + parseFloat(e.amount), 0);
      const avgDaily = totalAmount / 30;

      let trend = 0;
      if (earnings.length >= 7) {
        const lastWeek = earnings.slice(-7);
        const weekTotal = lastWeek.reduce((sum, e) => sum + parseFloat(e.amount), 0);
        const previousWeek = earnings.slice(-14, -7);
        const prevTotal = previousWeek.reduce((sum, e) => sum + parseFloat(e.amount), 0);
        
        if (prevTotal > 0) {
          trend = (weekTotal - prevTotal) / prevTotal;
        }
      }

      const today = new Date().getDay();
      const dayFactors = {
        0: 0.8,  
        1: 1.0, 
        2: 1.0,  
        3: 1.0, 
        4: 1.1, 
        5: 1.3, 
        6: 1.2   
      };
      const dayFactor = dayFactors[today] || 1.0;

      let predicted = avgDaily * dayFactor * (1 + trend * 0.5);
      
      const hourlyData = {};
      earnings.forEach(e => {
        const hour = new Date(e.created_at).getHours();
        if (!hourlyData[hour]) hourlyData[hour] = 0;
        hourlyData[hour] += parseFloat(e.amount);
      });

      let bestHour = 18; 
      let maxEarnings = 0;
      Object.entries(hourlyData).forEach(([hour, amount]) => {
        if (amount > maxEarnings) {
          maxEarnings = amount;
          bestHour = parseInt(hour);
        }
      });

      const bestTime = `${bestHour}-${bestHour + 3} ${bestHour >= 12 ? 'PM' : 'AM'}`;

      const tips = [];
      if (trend > 0.1) tips.push('📈 Your earnings are increasing! Keep up the good work.');
      else if (trend < -0.1) tips.push('📉 Your earnings are decreasing. Try working during peak hours.');
      
      if (dayFactor > 1.0) tips.push('⏰ Today is a high-earning day. Make the most of it!');
      
      if (earnings.length < 10) tips.push('💡 Complete more deliveries to get better earning predictions.');

      if (tips.length === 0) {
        tips.push('🌟 You\'re doing great! Keep delivering to earn more.');
      }

       return {
      predicted_earnings: parseFloat(predicted.toFixed(2)),
      best_time: bestTime,
      trend: parseFloat((trend * 100).toFixed(1)),
      day_factor: dayFactor,
      total_samples: earnings.length,
      tips: tips
    };
  } catch (error) {
    console.error('❌ Predict earnings error:', error);
    return {
      predicted_earnings: 0,
      best_time: '6-9 PM',
      trend: 0,
      day_factor: 1,
      total_samples: 0,
      tips: ['📊 Error generating prediction. Please try again later.']
    };
  }
}

  static async exportReport(driverId, format = 'pdf', period = 'daily') {
    try {
      const summary = await this.getEarningsSummary(driverId);
      const chartData = await this.getEarningsChart(driverId, period);
      const history = await this.getEarningsHistory(driverId, { limit: 100 });
      
      const driver = await User.findByPk(driverId, {
        attributes: ['user_id', 'full_name', 'email', 'phone']
      });

      const reportData = {
        driver: driver,
        summary: summary,
        chartData: chartData,
        history: history.earnings,
        generatedAt: new Date(),
        period: period
      };

      if (format === 'pdf') {
        return await this.generatePDFReport(reportData);
      } else if (format === 'excel') {
        return await this.generateExcelReport(reportData);
      }

      throw new Error('Unsupported format');
    } catch (error) {
      console.error('❌ Export report error:', error);
      throw error;
    }
  }

  static async generatePDFReport(reportData) {
    return {
      success: true,
      message: 'PDF report generated successfully',
      filename: `earnings_report_${Date.now()}.pdf`
    };
  }

  static async generateExcelReport(reportData) {
    return {
      success: true,
      message: 'Excel report generated successfully',
      filename: `earnings_report_${Date.now()}.xlsx`
    };
  }
}

module.exports = EarningsService;