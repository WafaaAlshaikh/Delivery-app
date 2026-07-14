// backend/src/models/ScheduledOrder.js

const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const ScheduledOrder = sequelize.define('ScheduledOrder', {
  scheduled_id: {
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
    },
    unique: true
  },
  driver_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'users',
      key: 'user_id'
    }
  },
  scheduled_time: {
    type: DataTypes.DATE,
    allowNull: false
  },
  estimated_duration: {
    type: DataTypes.INTEGER,
    allowNull: true,
    comment: 'Estimated duration in minutes'
  },
  status: {
    type: DataTypes.ENUM('pending', 'confirmed', 'in_progress', 'completed', 'cancelled'),
    defaultValue: 'pending'
  },
  priority: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    comment: 'Higher number = higher priority'
  },
  route_order: {
    type: DataTypes.INTEGER,
    allowNull: true,
    comment: 'Order in the optimized route'
  },
  confirmed_at: {
    type: DataTypes.DATE,
    allowNull: true
  },
  cancelled_at: {
    type: DataTypes.DATE,
    allowNull: true
  },
  cancellation_reason: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  ai_suggested_time: {
    type: DataTypes.DATE,
    allowNull: true
  },
  route_optimized: {
    type: DataTypes.JSON,
    allowNull: true,
    comment: 'Optimized route data'
  }
}, {
  tableName: 'scheduled_orders',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  indexes: [
    {
      name: 'idx_scheduled_driver_id',
      fields: ['driver_id']
    },
    {
      name: 'idx_scheduled_order_id',
      fields: ['order_id']
    },
    {
      name: 'idx_scheduled_status',
      fields: ['status']
    },
    {
      name: 'idx_scheduled_time',
      fields: ['scheduled_time']
    }
  ]
});

module.exports = ScheduledOrder;