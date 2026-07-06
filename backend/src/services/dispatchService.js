// D:\Delivery\backend\src\services\dispatchService.js
const { Op, Sequelize } = require('sequelize');
const { 
  Order, 
  User, 
  DriverProfile, 
  DeliveryOffer,
  Business,
  UserAddress,
  OrderItem,
  Product,
  sequelize 
} = require('../models');
class DispatchService {
  
  
  static async selectDrivers(orderId, options = {}) {
    const {
      type = 'smart',
      driverId = null,
      maxDrivers = 5,
      radius = 10,
      preferredDrivers = [],
      contractDrivers = []
    } = options;

    const order = await Order.findByPk(orderId, {
      include: [
        { model: Business, attributes: ['business_id', 'name', 'latitude', 'longitude'] },
        { model: UserAddress, attributes: ['latitude', 'longitude'] }
      ]
    });

    if (!order) throw new Error('Order not found');

    let driverQuery = {
      where: {
        status: 'Active',
        is_online: true,
        [Op.not]: sequelize.literal(`
          EXISTS (
            SELECT 1 FROM orders o 
            WHERE o.driver_id = DriverProfile.user_id 
            AND o.status_id BETWEEN 2 AND 7
          )
        `)
      },
      include: [
        { 
          model: User, 
          attributes: ['user_id', 'full_name', 'email', 'phone', 'profile_image'],
          where: { is_active: true }
        }
      ],
      limit: maxDrivers
    };

    if (type === 'direct' && driverId) {
      driverQuery.where['$User.user_id$'] = driverId;
      driverQuery.limit = 1;
    }
    
    else if (type === 'contract' && contractDrivers.length > 0) {
      driverQuery.where['$User.user_id$'] = { [Op.in]: contractDrivers };
      driverQuery.limit = contractDrivers.length;
    }
    
    else if (type === 'preferred' && preferredDrivers.length > 0) {
      driverQuery.where['$User.user_id$'] = { [Op.in]: preferredDrivers };
      driverQuery.limit = preferredDrivers.length;
    }

    let drivers = await DriverProfile.findAll(driverQuery);

    const orderLat = order.UserAddress?.latitude || order.Business?.latitude;
    const orderLng = order.UserAddress?.longitude || order.Business?.longitude;

    if (orderLat && orderLng) {
      drivers = drivers.map(driver => {
        const distance = this.calculateDistance(
          orderLat,
          orderLng,
          driver.current_latitude,
          driver.current_longitude
        );
        return {
          ...driver.toJSON(),
          distance: distance
        };
      });

      drivers.sort((a, b) => a.distance - b.distance);
    }

    if (radius) {
      drivers = drivers.filter(d => d.distance <= radius);
    }

    return drivers;
  }

 
  static async sendOffers(orderId, drivers, expiresIn = 15) {
    const offers = [];
    const expiresAt = new Date(Date.now() + expiresIn * 1000);

    for (const driver of drivers) {
      const existingOffer = await DeliveryOffer.findOne({
        where: {
          order_id: orderId,
          driver_id: driver.user_id,
          status: 'pending'
        }
      });

      if (existingOffer) {
        await existingOffer.update({
          expires_at: expiresAt,
          updated_at: new Date()
        });
        offers.push(existingOffer);
        continue;
      }

      const offer = await DeliveryOffer.create({
        order_id: orderId,
        driver_id: driver.user_id,
        status: 'pending',
        expires_at: expiresAt,
        offer_type: 'smart',
        priority: driver.distance ? Math.round(10 / (driver.distance + 1)) : 0
      });

      offers.push(offer);
    }

    return offers;
  }

  static async acceptOffer(offerId, driverId) {
  const transaction = await sequelize.transaction();

  try {
    const offer = await DeliveryOffer.findByPk(offerId, {
      lock: transaction.LOCK.UPDATE,
      transaction
    });

    if (!offer) {
      throw new Error('Offer not found');
    }

    if (offer.driver_id !== driverId) {
      throw new Error('This offer is not for you');
    }

    if (offer.status !== 'pending') {
      throw new Error('This offer has already been processed');
    }

    if (new Date() > offer.expires_at) {
      offer.status = 'expired';
      await offer.save({ transaction });
      throw new Error('This offer has expired');
    }

    const order = await Order.findByPk(offer.order_id, {
      lock: transaction.LOCK.UPDATE,
      transaction
    });

    if (!order) {
      throw new Error('Order not found');
    }

    if (order.driver_id !== null || order.status_id !== 1) {
      offer.status = 'taken';
      await offer.save({ transaction });
      throw new Error('This order has already been taken');
    }

    await order.update({
      driver_id: driverId,
      status_id: 2, 
      updated_at: new Date()
    }, { transaction });

    offer.status = 'accepted';
    offer.accepted_at = new Date();
    await offer.save({ transaction });

    await DeliveryOffer.update(
      { status: 'taken', updated_at: new Date() },
      {
        where: {
          order_id: offer.order_id,
          offer_id: { [Op.ne]: offerId },
          status: 'pending'
        },
        transaction
      }
    );

    await DriverProfile.increment('total_deliveries', {
      where: { user_id: driverId },
      transaction
    });

    await transaction.commit();

    return {
      success: true,
      message: 'Order accepted successfully',
      order: order,
      offer: offer
    };

  } catch (error) {
    await transaction.rollback();
    throw error;
  }
}

 
  static async rejectOffer(offerId, driverId, reason = null) {
    const transaction = await sequelize.transaction();

    try {
      const offer = await DeliveryOffer.findByPk(offerId, {
        transaction
      });

      if (!offer) {
        throw new Error('Offer not found');
      }

      if (offer.driver_id !== driverId) {
        throw new Error('This offer is not for you');
      }

      if (offer.status !== 'pending') {
        throw new Error('This offer has already been processed');
      }

      offer.status = 'rejected';
      offer.rejection_reason = reason;
      await offer.save({ transaction });

      await transaction.commit();

      return {
        success: true,
        message: 'Offer rejected'
      };

    } catch (error) {
      await transaction.rollback();
      throw error;
    }
  }


  static calculateDistance(lat1, lon1, lat2, lon2) {
    if (!lat1 || !lon1 || !lat2 || !lon2) return null;
    
    const R = 6371;
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a = 
      Math.sin(dLat/2) * Math.sin(dLat/2) +
      Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
      Math.sin(dLon/2) * Math.sin(dLon/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return R * c;
  }

 
  static async getActiveOffers(driverId) {
    const offers = await DeliveryOffer.findAll({
      where: {
        driver_id: driverId,
        status: 'pending',
        expires_at: { [Op.gt]: new Date() }
      },
      include: [
        {
          model: Order,
          include: [
            { model: Business, attributes: ['name', 'logo', 'rating', 'phone'] },
            { model: UserAddress, attributes: ['street', 'city', 'building'] },
            { model: User, as: 'Customer', attributes: ['full_name', 'phone'] },
            { 
              model: OrderItem,
              include: [{ model: Product, attributes: ['name', 'image_url', 'price'] }]
            }
          ]
        }
      ],
      order: [['priority', 'DESC'], ['created_at', 'ASC']]
    });

    return offers;
  }

 
  static async cleanupExpiredOffers() {
    const expired = await DeliveryOffer.update(
      { status: 'expired' },
      {
        where: {
          status: 'pending',
          expires_at: { [Op.lt]: new Date() }
        }
      }
    );
    return expired;
  }
}

module.exports = DispatchService;