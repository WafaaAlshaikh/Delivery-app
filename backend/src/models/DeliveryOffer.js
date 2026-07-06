// D:\Delivery\backend\src\models\DeliveryOffer.js
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const DeliveryOffer = sequelize.define('DeliveryOffer', {
  offer_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  order_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'orders',
      key: 'order_id'
    }
  },
  driver_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'users',
      key: 'user_id'
    }
  },
  status: {
    type: DataTypes.ENUM('pending', 'accepted', 'rejected', 'expired', 'taken'),
    defaultValue: 'pending'
  },
  attempt_id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    unique: true
  },
  expires_at: {
    type: DataTypes.DATE,
    allowNull: false
  },
  sent_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  },
  accepted_at: {
    type: DataTypes.DATE,
    allowNull: true
  },
  rejection_reason: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  offer_type: {
    type: DataTypes.ENUM('smart', 'direct', 'contract', 'preferred'),
    defaultValue: 'smart'
  },
  priority: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  }
}, {
  tableName: 'delivery_offers',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  indexes: [
    {
      name: 'idx_offer_order_driver',
      fields: ['order_id', 'driver_id']
    },
    {
      name: 'idx_offer_status_expires',
      fields: ['status', 'expires_at']
    },
    
  ]
});

module.exports = DeliveryOffer;