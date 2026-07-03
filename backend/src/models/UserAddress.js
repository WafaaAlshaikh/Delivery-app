// src/models/UserAddress.js
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const UserAddress = sequelize.define('UserAddress', {
  address_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'users',
      key: 'user_id'
    }
  },
  label: {
    type: DataTypes.STRING(50),
    allowNull: false,
    defaultValue: 'Home',
    validate: {
      notEmpty: { msg: 'Address label is required' }
    }
  },
  country: {
    type: DataTypes.STRING(50),
    allowNull: false
  },
  city: {
    type: DataTypes.STRING(50),
    allowNull: false
  },
  street: {
    type: DataTypes.STRING(100),
    allowNull: false
  },
  building: {
    type: DataTypes.STRING(50),
    allowNull: true
  },
  floor: {
    type: DataTypes.STRING(10),
    allowNull: true
  },
  apartment: {
    type: DataTypes.STRING(10),
    allowNull: true
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  latitude: {
    type: DataTypes.DECIMAL(10, 8),
    allowNull: true,
    validate: {
      min: -90,
      max: 90
    }
  },
  longitude: {
    type: DataTypes.DECIMAL(11, 8),
    allowNull: true,
    validate: {
      min: -180,
      max: 180
    }
  },
  is_default: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  }
}, {
  tableName: 'user_addresses',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  indexes: [
    {
      name: 'idx_user_addresses_user_id',
      fields: ['user_id']
    }
  ]
});

module.exports = UserAddress;