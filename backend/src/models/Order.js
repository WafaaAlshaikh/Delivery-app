// src/models/Order.js
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Order = sequelize.define('Order', {
  order_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  customer_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'users',
      key: 'user_id'
    }
  },
  business_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'businesses',
      key: 'business_id'
    }
  },
  driver_id: {
    type: DataTypes.INTEGER,
    allowNull: true,
    references: {
      model: 'users',
      key: 'user_id'
    }
  },
  delivery_address_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'user_addresses',
      key: 'address_id'
    }
  },
  status_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'order_statuses',
      key: 'status_id'
    },
    defaultValue: 1 
  },
  subtotal: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
    validate: {
      min: {
        args: [0],
        msg: 'Subtotal must be greater than or equal to 0'
      }
    }
  },
  delivery_fee: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
    defaultValue: 0
  },
  discount: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: true,
    defaultValue: 0
  },
  tax: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: true,
    defaultValue: 0
  },
  total: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
    validate: {
      min: {
        args: [0],
        msg: 'Total must be greater than or equal to 0'
      }
    }
  },
  estimated_delivery_time: {
    type: DataTypes.INTEGER,
    allowNull: true,
    comment: 'Estimated delivery time in minutes'
  }
}, {
  tableName: 'orders',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  indexes: [
    {
      name: 'idx_orders_customer_id',
      fields: ['customer_id']
    },
    {
      name: 'idx_orders_business_id',
      fields: ['business_id']
    },
    {
      name: 'idx_orders_driver_id',
      fields: ['driver_id']
    },
    {
      name: 'idx_orders_status_id',
      fields: ['status_id']
    },
    {
      name: 'idx_orders_created_at',
      fields: ['created_at']
    }
  ]
});

module.exports = Order;