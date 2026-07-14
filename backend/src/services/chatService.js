// backend/src/services/chatService.js

const { Op } = require('sequelize');
const { ChatMessage, User, Order } = require('../models');

class ChatService {
  
   static async sendMessage({
    senderId,
    receiverId,
    message,
    type = 'text', 
    metadata = null,
    orderId = null,
    isFromDriver = false
  }) {
    try {
      const validTypes = ['text', 'location', 'eta', 'status', 'system'];
      const finalType = validTypes.includes(type) ? type : 'text';

      const chatMessage = await ChatMessage.create({
        sender_id: senderId,
        receiver_id: receiverId,
        order_id: orderId,
        message: message,
        type: finalType,  
        metadata: metadata,
        is_from_driver: isFromDriver,
        status: 'sent',
        is_read: false
      });

      const fullMessage = await ChatMessage.findByPk(chatMessage.message_id, {
        include: [
          { model: User, as: 'Sender', attributes: ['user_id', 'full_name'] },
          { model: User, as: 'Receiver', attributes: ['user_id', 'full_name'] }
        ]
      });

      return fullMessage;
    } catch (error) {
      console.error('❌ Send message error:', error);
      throw error;
    }
  }

  static async getChatHistory({
    senderId,
    receiverId,
    page = 1,
    limit = 50
  }) {
    try {
      const offset = (page - 1) * limit;

      const { count, rows } = await ChatMessage.findAndCountAll({
        where: {
          [Op.or]: [
            { sender_id: senderId, receiver_id: receiverId },
            { sender_id: receiverId, receiver_id: senderId }
          ]
        },
        order: [['created_at', 'DESC']],
        limit: parseInt(limit),
        offset: parseInt(offset),
        include: [
          { model: User, as: 'Sender', attributes: ['user_id', 'full_name'] },
          { model: User, as: 'Receiver', attributes: ['user_id', 'full_name'] }
        ]
      });

      await ChatMessage.update(
        { is_read: true, read_at: new Date(), status: 'read' },
        {
          where: {
            sender_id: receiverId,
            receiver_id: senderId,
            is_read: false
          }
        }
      );

      return {
        messages: rows,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          totalPages: Math.ceil(count / limit)
        }
      };
    } catch (error) {
      console.error('❌ Get chat history error:', error);
      throw error;
    }
  }

  static async getUnreadCount(driverId) {
    try {
      const count = await ChatMessage.count({
        where: {
          receiver_id: driverId,
          is_read: false,
          is_from_driver: false
        }
      });
      return count;
    } catch (error) {
      console.error('❌ Get unread count error:', error);
      throw error;
    }
  }

  static async markAsRead(messageId, userId) {
    try {
      const message = await ChatMessage.findByPk(messageId);
      
      if (!message) {
        throw new Error('Message not found');
      }

      if (message.receiver_id !== userId) {
        throw new Error('You are not the receiver of this message');
      }

      await message.update({
        is_read: true,
        read_at: new Date(),
        status: 'read'
      });

      return message;
    } catch (error) {
      console.error('❌ Mark as read error:', error);
      throw error;
    }
  }

  static async getLastMessage(senderId, receiverId) {
    try {
      const message = await ChatMessage.findOne({
        where: {
          [Op.or]: [
            { sender_id: senderId, receiver_id: receiverId },
            { sender_id: receiverId, receiver_id: senderId }
          ]
        },
        order: [['created_at', 'DESC']],
        limit: 1
      });
      return message;
    } catch (error) {
      console.error('❌ Get last message error:', error);
      throw error;
    }
  }

  static async deleteMessage(messageId, userId) {
    try {
      const message = await ChatMessage.findByPk(messageId);
      
      if (!message) {
        throw new Error('Message not found');
      }

      if (message.sender_id !== userId) {
        throw new Error('You are not the sender of this message');
      }

      await message.destroy();
      return { success: true };
    } catch (error) {
      console.error('❌ Delete message error:', error);
      throw error;
    }
  }
}

module.exports = ChatService;