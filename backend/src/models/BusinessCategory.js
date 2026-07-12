// src/models/BusinessCategory.js
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const BusinessCategory = sequelize.define('BusinessCategory', {
  category_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  parent_id: {
    type: DataTypes.INTEGER,
    allowNull: true,
    references: {
      model: 'business_categories',
      key: 'category_id'
    }
  },
  name: {
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: {
      msg: 'Category name already exists'
    }
  },
  icon: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  status: {
    type: DataTypes.ENUM('Active', 'Inactive'),
    defaultValue: 'Active'
  },
  sort_order: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    allowNull: false
  }
}, {
  tableName: 'business_categories',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at'
});

module.exports = BusinessCategory;