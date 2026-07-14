// backend/src/models/Earning.js

const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Earning = sequelize.define('Earning', {
  earning_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  driver_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'users',
      key: 'user_id'
    }
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
  amount: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
    validate: {
      min: {
        args: [0],
        msg: 'Amount must be greater than or equal to 0'
      }
    }
  },
  delivery_fee: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
    defaultValue: 0
  },
  tips: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: true,
    defaultValue: 0
  },
  bonus: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: true,
    defaultValue: 0
  },
  status: {
    type: DataTypes.ENUM('pending', 'completed', 'cancelled', 'refunded'),
    defaultValue: 'pending'
  },
  distance: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: true,
    defaultValue: 0
  },
  duration: {
    type: DataTypes.INTEGER,
    allowNull: true,
    defaultValue: 0,
    comment: 'Duration in minutes'
  },
  rating: {
    type: DataTypes.DECIMAL(3, 2),
    allowNull: true,
    defaultValue: 0,
    validate: {
      min: 0,
      max: 5
    }
  },
  customer_name: {
    type: DataTypes.STRING(100),
    allowNull: true
  },
  delivery_address: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  paid_at: {
    type: DataTypes.DATE,
    allowNull: true
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true
  }
}, {
  tableName: 'earnings',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  indexes: [
    {
      name: 'idx_earnings_driver_id',
      fields: ['driver_id']
    },
    {
      name: 'idx_earnings_order_id',
      fields: ['order_id']
    },
    {
      name: 'idx_earnings_status',
      fields: ['status']
    },
    {
      name: 'idx_earnings_created_at',
      fields: ['created_at']
    }
  ]
});

module.exports = Earning;