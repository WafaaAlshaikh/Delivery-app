// src/models/Payment.js
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Payment = sequelize.define('Payment', {
  payment_id: {
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
    unique: true  // One payment per order
  },
  method_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'payment_methods',
      key: 'method_id'
    }
  },
  status_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'payment_statuses',
      key: 'status_id'
    }
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
  currency: {
    type: DataTypes.STRING(3),
    allowNull: true,
    defaultValue: 'USD'
  },
  transaction_reference: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  paid_at: {
    type: DataTypes.DATE,
    allowNull: true
  }
}, {
  tableName: 'payments',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  indexes: [
    {
      name: 'idx_payments_order_id',
      fields: ['order_id']
    },
    {
      name: 'idx_payments_transaction_reference',
      fields: ['transaction_reference']
    }
  ]
});

module.exports = Payment;