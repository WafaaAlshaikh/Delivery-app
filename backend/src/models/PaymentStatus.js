// src/models/PaymentStatus.js
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const PaymentStatus = sequelize.define('PaymentStatus', {
  status_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  name: {
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: true
  }
}, {
  tableName: 'payment_statuses',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at'
});

module.exports = PaymentStatus;