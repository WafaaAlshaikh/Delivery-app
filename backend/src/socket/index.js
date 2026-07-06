// D:\Delivery\backend\src\socket\index.js

const socketIO = require('socket.io');
const jwt = require('jsonwebtoken');
const { User, DriverProfile, DeliveryOffer, Order, sequelize } = require('../models');
const DispatchService = require('../services/dispatchService');

let io;

function initializeSocket(server) {
  io = socketIO(server, {
    cors: {
      origin: '*',
      methods: ['GET', 'POST']
    },
    path: '/socket.io'
  });

  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token;
      if (!token) {
        return next(new Error('Authentication error'));
      }

      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findByPk(decoded.user_id);
      
      if (!user) {
        return next(new Error('User not found'));
      }

      socket.user = user;
      socket.userId = user.user_id;
      next();
    } catch (error) {
      next(new Error('Authentication error'));
    }
  });

  io.on('connection', async (socket) => {
    console.log(`🔌 Client connected: ${socket.id}`);
    console.log(`👤 User: ${socket.userId}`);

    socket.join(`user_${socket.userId}`);

    const isDriver = await DriverProfile.findOne({
      where: { user_id: socket.userId }
    });

    if (isDriver) {
      socket.join('drivers');
      socket.join(`driver_${socket.userId}`);
      console.log(`🚗 Driver ${socket.userId} joined driver room`);
    }



socket.on('accept_offer', async (data) => {
  console.log(`📨 Accept offer received:`, data);
  
  try {
    const { offerId } = data;
    const driverId = socket.userId;

    console.log(`🔍 Checking driver ${driverId}...`);

    const driver = await DriverProfile.findOne({
      where: { user_id: driverId }
    });

    if (!driver || driver.status !== 'Active') {
      console.log(`❌ Driver ${driverId} is not active`);
      socket.emit('error', { message: 'You are not an active driver' });
      return;
    }

    console.log(`✅ Driver ${driverId} is active`);

    console.log(`🔍 Checking offer ${offerId}...`);
    const offer = await DeliveryOffer.findByPk(offerId);
    
    if (!offer) {
      console.log(`❌ Offer ${offerId} not found`);
      socket.emit('error', { message: 'Offer not found' });
      return;
    }

    console.log(`✅ Offer found:`, {
      offerId: offer.offer_id,
      orderId: offer.order_id,
      driverId: offer.driver_id,
      status: offer.status,
      expiresAt: offer.expires_at
    });

    if (offer.driver_id !== driverId) {
      console.log(`❌ Offer ${offerId} is not for driver ${driverId}`);
      socket.emit('error', { message: 'This offer is not for you' });
      return;
    }

    if (offer.status !== 'pending') {
      console.log(`❌ Offer ${offerId} status is ${offer.status}`);
      socket.emit('error', { message: 'This offer has already been processed' });
      return;
    }

    if (new Date() > offer.expires_at) {
      console.log(`❌ Offer ${offerId} has expired`);
      offer.status = 'expired';
      await offer.save();
      socket.emit('error', { message: 'This offer has expired' });
      return;
    }

    console.log(`✅ Offer ${offerId} is valid, attempting to accept...`);

    const result = await DispatchService.acceptOffer(offerId, driverId);

    console.log(`✅ Driver ${driverId} accepted offer ${offerId}`);
    console.log(`✅ Order ${result.order.order_id} assigned to driver ${driverId}`);

    socket.emit('offer_accepted', {
      offerId: offerId,
      orderId: result.order.order_id,
      message: 'Order accepted successfully!'
    });

    io.to('drivers').emit('offer_taken', {
      offerId: offerId,
      message: 'Order has been taken by another driver'
    });

  } catch (error) {
    console.error('❌ Accept offer error:', error);
    console.error('❌ Error stack:', error.stack);
    socket.emit('error', { 
      message: error.message || 'Failed to accept offer' 
    });
  }
});

    
    socket.on('reject_offer', async (data) => {
      console.log(`📨 Reject offer received:`, data);
      
      try {
        const { offerId, reason } = data;
        const driverId = socket.userId;

        const result = await DispatchService.rejectOffer(offerId, driverId, reason);

        socket.emit('offer_rejected', {
          offerId: offerId,
          message: 'Offer rejected successfully'
        });

        console.log(`✅ Driver ${driverId} rejected offer ${offerId}`);

      } catch (error) {
        console.error('❌ Reject offer error:', error);
        socket.emit('error', { 
          message: error.message || 'Failed to reject offer' 
        });
      }
    });

    socket.on('update_location', async (data) => {
      try {
        const { latitude, longitude } = data;
        await DriverProfile.update({
          current_latitude: latitude,
          current_longitude: longitude,
          last_location_update: new Date()
        }, {
          where: { user_id: socket.userId }
        });
        
        socket.emit('location_updated', { success: true });
      } catch (error) {
        socket.emit('error', { message: 'Failed to update location' });
      }
    });


    socket.on('disconnect', () => {
      console.log(`🔌 Client disconnected: ${socket.id}`);
    });
  });

  return io;
}

function getIO() {
  if (!io) {
    throw new Error('Socket.IO not initialized');
  }
  return io;
}

module.exports = {
  initializeSocket,
  getIO
};