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
  sequelize 
} = require('../models');

// ============================================
// 📌 GET AVAILABLE ORDERS (النسخة النهائية)
// ============================================
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

    // ✅ جلب بيانات السائق (نوع المركبة)
    const driverProfile = await DriverProfile.findOne({
      where: { user_id: req.user.user_id }
    });

    const driverVehicleType = driverProfile?.vehicle_type || 'Motorcycle';
    console.log(`   ├─ Driver Vehicle: ${driverVehicleType}`);

    // ✅ Build where clause - Only pending orders
    const whereClause = {
      status_id: 1, // Pending
      driver_id: null // No driver assigned yet
    };

    // ✅ جلب الطلبات
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

    // ✅ معالجة كل طلب
    let ordersWithDetails = orders.map(order => {
      const orderData = order.toJSON();
      
      let distance = null;
      let estimatedEarning = null;
      let estimatedTime = null;
      let isExpress = false;
      let orderWeight = 0;
      let requiresHeavyVehicle = false;

      // ✅ حساب وزن الطلب
      if (orderData.OrderItems && orderData.OrderItems.length > 0) {
        orderData.OrderItems.forEach(item => {
          const weight = item.Product?.weight || 0.5;
          orderWeight += weight * item.quantity;
        });
      }

      requiresHeavyVehicle = orderWeight > 50;

      // ✅ حساب المسافة من عنوان التوصيل
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

      // ✅ حساب الأرباح المتوقعة
      try {
        const baseFee = 5;
        const distanceFee = distance ? distance * 0.5 : 0;
        const weightFee = orderWeight * 0.1;
        const percentageFee = parseFloat(orderData.total || 0) * 0.1;
        estimatedEarning = Math.round((baseFee + distanceFee + weightFee + percentageFee) * 100) / 100;
      } catch (err) {
        estimatedEarning = 5.00;
      }

      // ✅ تحديد إذا كان الطلب مستعجل
      const createdAt = new Date(orderData.created_at);
      const now = new Date();
      const minutesSinceOrder = (now - createdAt) / (1000 * 60);
      isExpress = minutesSinceOrder > 15;

      // ✅ تحديد مدى مناسبة الطلب لنوع مركبة السائق
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

    // ✅ ✅ ✅ التعديل الأهم: لا نفلتر إذا كانت الإحداثيات غير موجودة
    let filteredOrders = [...ordersWithDetails];

    // ✅ نتحقق إذا كان أي طلب عنده إحداثيات
    const hasAnyCoordinates = ordersWithDetails.some(order => 
      order.distance !== null && order.distance !== undefined
    );

    // ✅ تطبيق الفلاتر فقط إذا كان في إحداثيات
    if (hasAnyCoordinates) {
      // 1️⃣ فلتر حسب النوع
      if (filterBy === 'nearby') {
        filteredOrders = filteredOrders.filter(order => 
          order.distance !== null && order.distance <= 5
        );
      } else if (filterBy === 'express') {
        filteredOrders = filteredOrders.filter(order => order.is_express === true);
      } else if (filterBy === 'heavy') {
        filteredOrders = filteredOrders.filter(order => order.requires_heavy_vehicle === true);
      }

      // 2️⃣ فلتر حسب المسافة
      if (latitude && longitude && radius) {
        filteredOrders = filteredOrders.filter(order => {
          if (order.distance === null || order.distance === undefined) return true;
          return order.distance <= parseFloat(radius);
        });
      }

      // 3️⃣ فلتر حسب نوع المركبة
      filteredOrders = filteredOrders.filter(order => {
        if (order.vehicle_match === 'poor') return false;
        return true;
      });

      // ✅ الترتيب (فقط إذا في إحداثيات)
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
      // ✅ ✅ ✅ إذا مافيش إحداثيات، نرجع كل الطلبات بدون ترتيب
      console.log('   ⚠️ No coordinates found, returning all orders without filtering');
      
      // ✅ نرتب حسب التاريخ فقط
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

// ============================================
// 📌 HELPER: Calculate distance
// ============================================
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

// ============================================
// 📌 GET ORDER DETAILS
// ============================================
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

module.exports = {
  getAvailableOrders,
  getOrderDetailsForDriver
};