// backend/src/models/ChatMessage.js

const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const ChatMessage = sequelize.define('ChatMessage', {
  message_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  sender_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'users',
      key: 'user_id'
    }
  },
  receiver_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'users',
      key: 'user_id'
    }
  },
  order_id: {
    type: DataTypes.INTEGER,
    allowNull: true,
    references: {
      model: 'orders',
      key: 'order_id'
    }
  },
  message: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  type: {
    type: DataTypes.ENUM('text', 'location', 'eta', 'status', 'system'),
    defaultValue: 'text'
  },
  status: {
    type: DataTypes.ENUM('sent', 'delivered', 'read', 'failed'),
    defaultValue: 'sent'
  },
  metadata: {
    type: DataTypes.JSON,
    allowNull: true
  },
  is_read: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  read_at: {
    type: DataTypes.DATE,
    allowNull: true
  },
  is_from_driver: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  }
}, {
  tableName: 'chat_messages',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  indexes: [
    {
      name: 'idx_chat_sender_receiver',
      fields: ['sender_id', 'receiver_id']
    },
    {
      name: 'idx_chat_order_id',
      fields: ['order_id']
    },
    {
      name: 'idx_chat_created_at',
      fields: ['created_at']
    },
    {
      name: 'idx_chat_is_read',
      fields: ['is_read']
    }
  ]
});

module.exports = ChatMessage;