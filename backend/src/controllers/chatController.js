// backend/src/controllers/chatController.js

const ChatService = require('../services/chatService');

const sendMessage = async (req, res) => {
  try {
    const driverId = req.user.user_id;
    const { customer_id, text, type, metadata, order_id } = req.body;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('💬 [CHAT] Sending message');
    console.log(`   ├─ Driver ID: ${driverId}`);
    console.log(`   └─ Customer ID: ${customer_id}`);
    console.log(`   └─ Text: ${text}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const { User } = require('../models');
    const customer = await User.findByPk(customer_id);
    if (!customer) {
      return res.status(404).json({
        success: false,
        message: 'Customer not found'
      });
    }

    let finalType = 'text';
    if (type) {
      const typeParts = type.split('.');
      finalType = typeParts.length > 1 ? typeParts[1].toLowerCase() : type.toLowerCase();
    }

    const message = await ChatService.sendMessage({
      senderId: driverId,
      receiverId: customer_id,
      message: text,
      type: finalType,  
      metadata: metadata,
      orderId: order_id || null,
      isFromDriver: true
    });

    const io = req.app.get('io');
    if (io) {
      io.to(`user_${customer_id}`).emit('new_message', {
        message: message,
        fromDriver: true
      });
    }

    res.status(201).json({
      success: true,
      data: message
    });
  } catch (error) {
    console.error('❌ Send message error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error sending message'
    });
  }
};

const getChatHistory = async (req, res) => {
  try {
    const driverId = req.user.user_id;
    const { customer_id, page = 1, limit = 50 } = req.query;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('💬 [CHAT] Getting chat history');
    console.log(`   ├─ Driver ID: ${driverId}`);
    console.log(`   └─ Customer ID: ${customer_id}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (!customer_id) {
      return res.status(400).json({
        success: false,
        message: 'Customer ID is required'
      });
    }

    const result = await ChatService.getChatHistory({
      senderId: driverId,
      receiverId: parseInt(customer_id),
      page,
      limit
    });

    res.status(200).json({
      success: true,
      data: result.messages,
      pagination: result.pagination
    });
  } catch (error) {
    console.error('❌ Get chat history error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching chat history'
    });
  }
};

const getUnreadCount = async (req, res) => {
  try {
    const driverId = req.user.user_id;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('💬 [CHAT] Getting unread count');
    console.log(`   ├─ Driver ID: ${driverId}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const count = await ChatService.getUnreadCount(driverId);

    res.status(200).json({
      success: true,
      data: { count }
    });
  } catch (error) {
    console.error('❌ Get unread count error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error getting unread count'
    });
  }
};

const markAsRead = async (req, res) => {
  try {
    const driverId = req.user.user_id;
    const { messageId } = req.params;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('💬 [CHAT] Marking message as read');
    console.log(`   ├─ Driver ID: ${driverId}`);
    console.log(`   └─ Message ID: ${messageId}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const message = await ChatService.markAsRead(messageId, driverId);

    res.status(200).json({
      success: true,
      data: message
    });
  } catch (error) {
    console.error('❌ Mark as read error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error marking message as read'
    });
  }
};

const notifyOnTheWay = async (req, res) => {
  try {
    const driverId = req.user.user_id;
    const { customer_id, eta_minutes } = req.body;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('🚗 [CHAT] Driver on the way');
    console.log(`   ├─ Driver ID: ${driverId}`);
    console.log(`   └─ Customer ID: ${customer_id}`);
    console.log(`   └─ ETA: ${eta_minutes || 'N/A'} minutes`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const message = await ChatService.sendMessage({
      senderId: driverId,
      receiverId: customer_id,
      message: eta_minutes 
        ? `🚗 أنا في الطريق، سأصل خلال ${eta_minutes} دقائق`
        : '🚗 أنا في الطريق إليك',
      type: 'status',
      metadata: { eta_minutes },
      isFromDriver: true
    });

    const io = req.app.get('io');
    if (io) {
      io.to(`user_${customer_id}`).emit('driver_on_the_way', {
        driverId: driverId,
        eta: eta_minutes,
        message: message
      });
    }

    res.status(200).json({
      success: true,
      message: 'On the way notification sent',
      data: message
    });
  } catch (error) {
    console.error('❌ Notify on the way error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error sending notification'
    });
  }
};

const notifyArrived = async (req, res) => {
  try {
    const driverId = req.user.user_id;
    const { customer_id } = req.body;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📍 [CHAT] Driver arrived');
    console.log(`   ├─ Driver ID: ${driverId}`);
    console.log(`   └─ Customer ID: ${customer_id}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const message = await ChatService.sendMessage({
      senderId: driverId,
      receiverId: customer_id,
      message: '📍 وصلت إلى موقعك',
      type: 'status',
      metadata: { arrived: true },
      isFromDriver: true
    });

    const io = req.app.get('io');
    if (io) {
      io.to(`user_${customer_id}`).emit('driver_arrived', {
        driverId: driverId,
        message: message
      });
    }

    res.status(200).json({
      success: true,
      message: 'Arrival notification sent',
      data: message
    });
  } catch (error) {
    console.error('❌ Notify arrived error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error sending arrival notification'
    });
  }
};

const getSmartSuggestions = async (req, res) => {
  try {
    const { message, context } = req.body;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('🤖 [CHAT] Getting smart suggestions');
    console.log(`   └─ Message: ${message}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const suggestions = [
      { text: 'أنا في الطريق الآن', emoji: '🚗', translation: "I'm on my way now", confidence: 0.95 },
      { text: 'سأصل خلال 5 دقائق', emoji: '⏱️', translation: "I'll arrive in 5 minutes", confidence: 0.9 },
      { text: 'هل لديك أي تعليمات إضافية؟', emoji: '📝', translation: 'Do you have any additional instructions?', confidence: 0.85 },
      { text: 'وصلت إلى موقعك', emoji: '📍', translation: "I've arrived at your location", confidence: 0.95 },
      { text: 'تم التوصيل بنجاح ✅', emoji: '✅', translation: 'Successfully delivered', confidence: 0.98 },
      { text: 'آسف على التأخير', emoji: '🙏', translation: 'Sorry for the delay', confidence: 0.8 },
      { text: 'هل يمكنك تحديد موقعك بشكل أفضل؟', emoji: '📍', translation: 'Can you specify your location better?', confidence: 0.75 },
      { text: 'سأتصل بك عند الوصول', emoji: '📞', translation: "I'll call you upon arrival", confidence: 0.85 }
    ];

    res.status(200).json({
      success: true,
      data: suggestions
    });
  } catch (error) {
    console.error('❌ Get smart suggestions error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error getting suggestions'
    });
  }
};

module.exports = {
  sendMessage,
  getChatHistory,
  getUnreadCount,
  markAsRead,
  notifyOnTheWay,
  notifyArrived,
  getSmartSuggestions,
};