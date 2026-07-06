// backend/src/controllers/driverController.js
const { Op, Sequelize } = require('sequelize');
const { 
  Order, 
  OrderItem, 
  OrderStatus, 
  Business, 
  User,
  UserAddress,
  Product,
  DriverProfile,
  OrderStatusHistory,
  sequelize 
} = require('../models');
const DispatchService = require('../services/dispatchService');


const getAvailableOrders = async (req, res) => {
  try {
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('🚗 [DRIVER] Fetching available orders');
    console.log(`   ├─ Driver ID: ${req.user.user_id}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const { 
      latitude, 
      longitude, 
      radius = 20,
      sortBy = 'distance',
      filterBy = 'all',
      limit = 50 
    } = req.query;

    console.log(`   ├─ Latitude: ${latitude || 'Not provided'}`);
    console.log(`   ├─ Longitude: ${longitude || 'Not provided'}`);
    console.log(`   ├─ Radius: ${radius} km`);
    console.log(`   ├─ Sort By: ${sortBy}`);
    console.log(`   └─ Filter By: ${filterBy}`);

    const driverProfile = await DriverProfile.findOne({
      where: { user_id: req.user.user_id }
    });

    const driverVehicleType = driverProfile?.vehicle_type || 'Motorcycle';
    console.log(`   ├─ Driver Vehicle: ${driverVehicleType}`);

    const whereClause = {
      status_id: 1,
      driver_id: null 
    };

    const orders = await Order.findAll({
      where: whereClause,
      order: [['created_at', 'ASC']],
      include: [
        { 
          model: Business, 
          attributes: ['business_id', 'name', 'logo', 'phone', 'rating']
        },
        { 
          model: User, 
          as: 'Customer',
          attributes: ['user_id', 'full_name', 'phone']
        },
        {
          model: UserAddress,
          attributes: ['address_id', 'label', 'street', 'city', 'building', 'latitude', 'longitude']
        },
        {
          model: OrderStatus,
          attributes: ['status_id', 'name', 'color']
        },
        {
          model: OrderItem,
          include: [
            { 
              model: Product,
              attributes: ['product_id', 'name', 'image_url', 'price', 'weight']
            }
          ]
        }
      ],
      limit: parseInt(limit)
    });

    console.log(`   ├─ Found ${orders.length} pending orders`);

    let ordersWithDetails = orders.map(order => {
      const orderData = order.toJSON();
      
      let distance = null;
      let estimatedEarning = null;
      let estimatedTime = null;
      let isExpress = false;
      let orderWeight = 0;
      let requiresHeavyVehicle = false;

      if (orderData.OrderItems && orderData.OrderItems.length > 0) {
        orderData.OrderItems.forEach(item => {
          const weight = item.Product?.weight || 0.5;
          orderWeight += weight * item.quantity;
        });
      }

      requiresHeavyVehicle = orderWeight > 50;

      const addressLat = orderData.UserAddress?.latitude;
      const addressLng = orderData.UserAddress?.longitude;

      if (latitude && longitude && addressLat && addressLng) {
        try {
          distance = calculateDistance(
            parseFloat(latitude),
            parseFloat(longitude),
            parseFloat(addressLat),
            parseFloat(addressLng)
          );
          
          if (distance !== null && distance > 0) {
            estimatedTime = Math.round(distance * 5);
          }
        } catch (err) {
          console.warn('⚠️ Could not calculate distance:', err.message);
          distance = null;
        }
      }

      try {
        const baseFee = 5;
        const distanceFee = distance ? distance * 0.5 : 0;
        const weightFee = orderWeight * 0.1;
        const percentageFee = parseFloat(orderData.total || 0) * 0.1;
        estimatedEarning = Math.round((baseFee + distanceFee + weightFee + percentageFee) * 100) / 100;
      } catch (err) {
        estimatedEarning = 5.00;
      }

      const createdAt = new Date(orderData.created_at);
      const now = new Date();
      const minutesSinceOrder = (now - createdAt) / (1000 * 60);
      isExpress = minutesSinceOrder > 15;

      let vehicleMatch = 'perfect';
      if (requiresHeavyVehicle && driverVehicleType === 'Bicycle') {
        vehicleMatch = 'poor';
      } else if (requiresHeavyVehicle && driverVehicleType === 'Motorcycle') {
        vehicleMatch = 'medium';
      } else if (!requiresHeavyVehicle && driverVehicleType === 'Van') {
        vehicleMatch = 'medium';
      }

      return {
        ...orderData,
        distance: distance,
        estimated_earning: estimatedEarning,
        estimated_time: estimatedTime,
        is_express: isExpress,
        order_weight: orderWeight,
        requires_heavy_vehicle: requiresHeavyVehicle,
        vehicle_match: vehicleMatch,
      };
    });

    let filteredOrders = [...ordersWithDetails];

    const hasAnyCoordinates = ordersWithDetails.some(order => 
      order.distance !== null && order.distance !== undefined
    );

    if (hasAnyCoordinates) {
      if (filterBy === 'nearby') {
        filteredOrders = filteredOrders.filter(order => 
          order.distance !== null && order.distance <= 5
        );
      } else if (filterBy === 'express') {
        filteredOrders = filteredOrders.filter(order => order.is_express === true);
      } else if (filterBy === 'heavy') {
        filteredOrders = filteredOrders.filter(order => order.requires_heavy_vehicle === true);
      }

      if (latitude && longitude && radius) {
        filteredOrders = filteredOrders.filter(order => {
          if (order.distance === null || order.distance === undefined) return true;
          return order.distance <= parseFloat(radius);
        });
      }

      filteredOrders = filteredOrders.filter(order => {
        if (order.vehicle_match === 'poor') return false;
        return true;
      });

      switch (sortBy) {
        case 'distance':
          filteredOrders.sort((a, b) => {
            const distA = a.distance || 999999;
            const distB = b.distance || 999999;
            return distA - distB;
          });
          break;
        case 'time':
          filteredOrders.sort((a, b) => {
            const timeA = a.estimated_time || 999999;
            const timeB = b.estimated_time || 999999;
            return timeA - timeB;
          });
          break;
        case 'earning':
          filteredOrders.sort((a, b) => {
            const earnA = a.estimated_earning || 0;
            const earnB = b.estimated_earning || 0;
            return earnB - earnA;
          });
          break;
        case 'express':
          filteredOrders.sort((a, b) => {
            if (a.is_express && !b.is_express) return -1;
            if (!a.is_express && b.is_express) return 1;
            return 0;
          });
          break;
      }
    } else {
      console.log('   ⚠️ No coordinates found, returning all orders without filtering');
      
      filteredOrders.sort((a, b) => {
        const dateA = new Date(a.created_at);
        const dateB = new Date(b.created_at);
        return dateA - dateB;
      });
    }

    console.log(`   └─ Returning ${filteredOrders.length} orders`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      data: {
        orders: filteredOrders,
        count: filteredOrders.length,
        filters: {
          sortBy,
          filterBy,
          radius,
          driverVehicle: driverVehicleType,
          hasCoordinates: hasAnyCoordinates
        },
        stats: {
          total: orders.length,
          filtered: filteredOrders.length,
          express: filteredOrders.filter(o => o.is_express).length,
          nearby: filteredOrders.filter(o => o.distance !== null && o.distance <= 3).length
        }
      }
    });

  } catch (error) {
    console.error('❌ Get available orders error:', error);
    console.error('❌ Error stack:', error.stack);
    
    res.status(500).json({
      success: false,
      message: 'Server error fetching available orders',
      error: error.message
    });
  }
};


const calculateDistance = (lat1, lon1, lat2, lon2) => {
  const R = 6371;
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c;
};

const getOrderDetailsForDriver = async (req, res) => {
  try {
    const { orderId } = req.params;

    const order = await Order.findByPk(orderId, {
      include: [
        { 
          model: Business,
          attributes: ['business_id', 'name', 'logo', 'phone', 'rating']
        },
        { 
          model: User, 
          as: 'Customer',
          attributes: ['user_id', 'full_name', 'phone']
        },
        {
          model: UserAddress,
          attributes: ['address_id', 'label', 'street', 'city', 'building', 'latitude', 'longitude']
        },
        {
          model: OrderStatus,
          attributes: ['status_id', 'name', 'color']
        },
        {
          model: OrderItem,
          include: [
            { 
              model: Product,
              attributes: ['product_id', 'name', 'image_url', 'price', 'weight', 'description']
            }
          ]
        }
      ]
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    if (order.status_id !== 1 || order.driver_id !== null) {
      return res.status(400).json({
        success: false,
        message: 'Order is no longer available'
      });
    }

    res.status(200).json({
      success: true,
      data: order
    });

  } catch (error) {
    console.error('❌ Get order details error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching order details'
    });
  }
};

const getAvailableOffers = async (req, res) => {
  try {
    const driverId = req.user.user_id;
    
    const offers = await DispatchService.getActiveOffers(driverId);
    
    const driverProfile = await DriverProfile.findOne({
      where: { user_id: driverId }
    });

    res.status(200).json({
      success: true,
      data: {
        offers: offers,
        isOnline: driverProfile?.is_online || false,
        driverStatus: driverProfile?.status || 'Pending'
      }
    });

  } catch (error) {
    console.error('❌ Get available offers error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching offers'
    });
  }
};

const acceptOffer = async (req, res) => {
  try {
    const { offerId } = req.params;
    const driverId = req.user.user_id;

    const result = await DispatchService.acceptOffer(offerId, driverId);

    const io = req.app.get('io');
    if (io) {
      io.to(`driver_${driverId}`).emit('offer_accepted', {
        orderId: result.order.order_id,
        message: 'Order accepted successfully!'
      });
      
      io.to(`business_${result.order.business_id}`).emit('order_assigned', {
        orderId: result.order.order_id,
        driverId: driverId
      });
    }

    res.status(200).json({
      success: true,
      message: 'Order accepted successfully',
      data: result
    });

  } catch (error) {
    console.error('❌ Accept offer error:', error);
    res.status(400).json({
      success: false,
      message: error.message || 'Failed to accept offer'
    });
  }
};

const rejectOffer = async (req, res) => {
  try {
    const { offerId } = req.params;
    const driverId = req.user.user_id;
    const { reason } = req.body;

    const result = await DispatchService.rejectOffer(offerId, driverId, reason);

    res.status(200).json({
      success: true,
      message: 'Offer rejected'
    });

  } catch (error) {
    console.error('❌ Reject offer error:', error);
    res.status(400).json({
      success: false,
      message: error.message || 'Failed to reject offer'
    });
  }
};

const acceptOrder = async (req, res) => {
  try {
    const { orderId } = req.params;
    const driverId = req.user.user_id;

    const offer = await DeliveryOffer.findOne({
      where: {
        order_id: orderId,
        driver_id: driverId,
        status: 'pending'
      }
    });

    if (!offer) {
      return res.status(400).json({
        success: false,
        message: 'No active offer found for this order'
      });
    }

    const result = await DispatchService.acceptOffer(offer.offer_id, driverId);

    res.status(200).json({
      success: true,
      message: 'Order accepted successfully',
      data: result
    });

  } catch (error) {
    console.error('❌ Accept order error:', error);
    res.status(400).json({
      success: false,
      message: error.message || 'Failed to accept order'
    });
  }
};

const updateOrderStatus = async (req, res) => {
  try {
    const { orderId } = req.params;
    const { status_id, notes, latitude, longitude } = req.body;
    const driverId = req.user.user_id;

    console.log(`📨 Update order status:`, {
      orderId,
      status_id,
      notes,
      latitude,
      longitude,
      driverId
    });

    const order = await Order.findByPk(orderId);
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    if (order.driver_id !== driverId) {
      return res.status(403).json({
        success: false,
        message: 'You are not assigned to this order'
      });
    }

    const validStatuses = [5, 6, 7, 8]; 
    if (!validStatuses.includes(status_id)) {
      return res.status(400).json({
        success: false,
        message: `Invalid status: ${status_id}. Allowed: ${validStatuses.join(', ')}`
      });
    }

    const currentStatus = order.status_id;
    if (status_id <= currentStatus && currentStatus !== 1) {
      return res.status(400).json({
        success: false,
        message: `Cannot go backwards in status. Current: ${currentStatus}, New: ${status_id}`
      });
    }

    await order.update({
      status_id: status_id,
      updated_at: new Date()
    });

    await OrderStatusHistory.create({
      order_id: orderId,
      status_id: status_id,
      changed_by: driverId,
      notes: notes || `Status updated to ${status_id}`
    });

    if (status_id === 8) {
      await DriverProfile.increment('total_deliveries', {
        where: { user_id: driverId }
      });
    }

    const io = req.app.get('io');
    if (io) {
      const status = await OrderStatus.findByPk(status_id);
      io.to(`user_${order.customer_id}`).emit('order_status_updated', {
        orderId: orderId,
        status: status_id,
        statusName: status?.name || 'Unknown',
        driverLocation: latitude && longitude ? { latitude, longitude } : null
      });
    }

    res.status(200).json({
      success: true,
      message: 'Order status updated successfully',
      data: order
    });

  } catch (error) {
    console.error('❌ Update order status error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error updating order status'
    });
  }
};


async function getStatusName(statusId) {
  const status = await OrderStatus.findByPk(statusId);
  return status ? status.name : 'Unknown';
}


const updateDeliveryLocation = async (req, res) => {
  try {
    const { orderId, latitude, longitude } = req.body;
    const driverId = req.user.user_id;

    const order = await Order.findOne({
      where: {
        order_id: orderId,
        driver_id: driverId
      }
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found or not assigned to you'
      });
    }

    await DriverProfile.update({
      current_latitude: latitude,
      current_longitude: longitude,
      last_location_update: new Date()
    }, {
      where: { user_id: driverId }
    });

    const io = req.app.get('io');
    if (io) {
      io.to(`user_${order.customer_id}`).emit('driver_location_updated', {
        orderId: orderId,
        latitude: latitude,
        longitude: longitude,
        timestamp: new Date()
      });
    }

    res.status(200).json({
      success: true,
      message: 'Location updated successfully'
    });

  } catch (error) {
    console.error('❌ Update delivery location error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error updating location'
    });
  }
};


const getCurrentDelivery = async (req, res) => {
  try {
    const driverId = req.user.user_id;
    console.log(`🔍 Getting current delivery for driver ${driverId}`);

    const order = await Order.findOne({
      where: {
        driver_id: driverId,
        status_id: {
          [Op.between]: [2, 7] 
        }
      },
      include: [
        { model: Business, attributes: ['business_id', 'name', 'phone', 'latitude', 'longitude'] },
        { model: User, as: 'Customer', attributes: ['user_id', 'full_name', 'phone'] },
        { model: UserAddress, attributes: ['address_id', 'street', 'city', 'building', 'latitude', 'longitude'] },
        { model: OrderStatus, attributes: ['status_id', 'name', 'color'] },
        { 
          model: OrderItem,
          include: [{ model: Product, attributes: ['product_id', 'name', 'image_url'] }]
        }
      ],
      order: [['created_at', 'DESC']]
    });

    if (!order) {
      console.log(`❌ No active delivery found for driver ${driverId}`);
      return res.status(404).json({
        success: false,
        message: 'No active delivery found'
      });
    }

    console.log(`✅ Found delivery for driver ${driverId}: Order #${order.order_id}`);

    const driverProfile = await DriverProfile.findOne({
      where: { user_id: driverId }
    });

    res.status(200).json({
      success: true,
      data: {
        order: order,
        driverLocation: {
          latitude: driverProfile?.current_latitude,
          longitude: driverProfile?.current_longitude,
          lastUpdate: driverProfile?.last_location_update
        }
      }
    });

  } catch (error) {
    console.error('❌ Get current delivery error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching current delivery'
    });
  }
};

module.exports = {
  getAvailableOrders,
  getAvailableOffers, 
  getOrderDetailsForDriver,
  acceptOffer, 
  rejectOffer,
  acceptOrder, 
  updateDeliveryLocation,
  getCurrentDelivery,
  updateOrderStatus
  
};

