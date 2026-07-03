// src/models/OrderStatus.js
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const OrderStatus = sequelize.define('OrderStatus', {
  status_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  name: {
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: true
  },
  color: {
    type: DataTypes.STRING(7),
    allowNull: true,
    comment: 'Hex color code for UI'
  }
}, {
  tableName: 'order_statuses',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at'
});

module.exports = OrderStatus;