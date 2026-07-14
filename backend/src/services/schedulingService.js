// backend/src/services/schedulingService.js

const { Op } = require('sequelize');
const { ScheduledOrder, Order, User, UserAddress } = require('../models');
const RouteOptimizer = require('./routeOptimizer');

class SchedulingService {
  
  static async getScheduledOrders(driverId, date = null) {
    try {
      const where = {
        driver_id: driverId,
        status: {
          [Op.in]: ['pending', 'confirmed', 'in_progress']
        }
      };

      if (date) {
        const start = new Date(date);
        start.setHours(0, 0, 0, 0);
        const end = new Date(date);
        end.setHours(23, 59, 59, 999);
        where.scheduled_time = { [Op.between]: [start, end] };
      }

      const scheduled = await ScheduledOrder.findAll({
        where,
        include: [
          {
            model: Order,
            include: [
              { model: UserAddress },
              { model: User, as: 'Customer', attributes: ['user_id', 'full_name', 'phone'] }
            ]
          }
        ],
        order: [['scheduled_time', 'ASC']]
      });

      return scheduled;
    } catch (error) {
      console.error('❌ Get scheduled orders error:', error);
      throw error;
    }
  }

  static async getTodaySchedule(driverId) {
    const today = new Date();
    return this.getScheduledOrders(driverId, today);
  }

static async createSchedule({
  orderId,
  driverId,
  scheduledTime,
  priority = 0
}) {
  try {
    const orderIdInt = parseInt(orderId);
    if (isNaN(orderIdInt)) {
      throw new Error('Invalid order ID');
    }

    const order = await Order.findByPk(orderIdInt);
    if (!order) {
      throw new Error('Order not found');
    }

    const conflict = await ScheduledOrder.findOne({
      where: {
        driver_id: driverId,
        scheduled_time: {
          [Op.between]: [
            new Date(scheduledTime.getTime() - 30 * 60000),
            new Date(scheduledTime.getTime() + 30 * 60000)
          ]
        },
        status: { [Op.in]: ['pending', 'confirmed', 'in_progress'] }
      }
    });

    if (conflict) {
      throw new Error('Time slot conflict with another scheduled order');
    }

    const scheduled = await ScheduledOrder.create({
      order_id: orderIdInt, 
      driver_id: driverId,
      scheduled_time: scheduledTime,
      priority: priority,
      status: 'pending'
    });

    return scheduled;
  } catch (error) {
    console.error('❌ Create schedule error:', error);
    throw error;
  }
}

  static async confirmSchedule(scheduledId, driverId) {
    try {
      const scheduled = await ScheduledOrder.findOne({
        where: { scheduled_id: scheduledId, driver_id: driverId }
      });

      if (!scheduled) {
        throw new Error('Scheduled order not found');
      }

      await scheduled.update({
        status: 'confirmed',
        confirmed_at: new Date()
      });

      return scheduled;
    } catch (error) {
      console.error('❌ Confirm schedule error:', error);
      throw error;
    }
  }

  static async cancelSchedule(scheduledId, driverId, reason = null) {
    try {
      const scheduled = await ScheduledOrder.findOne({
        where: { scheduled_id: scheduledId, driver_id: driverId }
      });

      if (!scheduled) {
        throw new Error('Scheduled order not found');
      }

      await scheduled.update({
        status: 'cancelled',
        cancelled_at: new Date(),
        cancellation_reason: reason
      });

      return scheduled;
    } catch (error) {
      console.error('❌ Cancel schedule error:', error);
      throw error;
    }
  }

  static async optimizeRouteForDriver(driverId, date = null) {
    try {
      const orders = await this.getScheduledOrders(driverId, date);
      
      if (orders.length === 0) {
        return { route: [], totalDistance: 0, totalTime: 0 };
      }

      const driver = await User.findByPk(driverId);
      
      const startLocation = {
        lat: parseFloat(driver.current_latitude) || 31.9539,
        lng: parseFloat(driver.current_longitude) || 35.9106
      };

      const optimized = RouteOptimizer.optimizeRoute(
        orders.map(s => s.Order),
        startLocation
      );

      for (let i = 0; i < optimized.route.length; i++) {
        const orderId = optimized.route[i].order_id;
        const scheduled = orders.find(s => s.order_id === orderId);
        if (scheduled) {
          await scheduled.update({ route_order: i + 1 });
        }
      }

      await ScheduledOrder.update(
        { route_optimized: optimized },
        { where: { driver_id: driverId } }
      );

      return optimized;
    } catch (error) {
      console.error('❌ Optimize route error:', error);
      throw error;
    }
  }

  static async suggestOptimalTime(driverId, orderId) {
    try {
      const todayOrders = await this.getTodaySchedule(driverId);
      
      const order = await Order.findByPk(orderId);
      if (!order) {
        throw new Error('Order not found');
      }

      const now = new Date();
      const baseTime = new Date(now);
      baseTime.setHours(9, 0, 0, 0); 

      const bufferMinutes = todayOrders.length * 30;
      baseTime.setMinutes(baseTime.getMinutes() + bufferMinutes);

      let suggestedTime = baseTime;
      let attempts = 0;
      let conflict = true;

      while (conflict && attempts < 10) {
        const conflictExists = await ScheduledOrder.findOne({
          where: {
            driver_id: driverId,
            scheduled_time: {
              [Op.between]: [
                new Date(suggestedTime.getTime() - 30 * 60000),
                new Date(suggestedTime.getTime() + 30 * 60000)
              ]
            },
            status: { [Op.in]: ['pending', 'confirmed', 'in_progress'] }
          }
        });

        if (!conflictExists) {
          conflict = false;
        } else {
          suggestedTime.setMinutes(suggestedTime.getMinutes() + 30);
          attempts++;
        }
      }

      return {
        suggested_time: suggestedTime,
        confidence: Math.max(50, 100 - (attempts * 5)),
        reasoning: `بناءً على جدولك اليوم (${todayOrders.length} طلبات مجدولة)`
      };
    } catch (error) {
      console.error('❌ Suggest optimal time error:', error);
      throw error;
    }
  }
}

module.exports = SchedulingService;