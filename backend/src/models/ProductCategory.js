// src/models/ProductCategory.js
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const ProductCategory = sequelize.define('ProductCategory', {
  category_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  business_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'businesses',
      key: 'business_id'
    }
  },
  parent_id: {
    type: DataTypes.INTEGER,
    allowNull: true,
    references: {
      model: 'product_categories',
      key: 'category_id'
    }
  },
  name: {
    type: DataTypes.STRING(50),
    allowNull: false
  },
  icon: {
    type: DataTypes.STRING(255),
    allowNull: true
  }
}, {
  tableName: 'product_categories',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  indexes: [
    {
      name: 'idx_product_categories_business_id',
      fields: ['business_id']
    }
  ]
});

module.exports = ProductCategory;