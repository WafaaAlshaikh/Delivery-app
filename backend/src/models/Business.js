// src/models/Business.js
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Business = sequelize.define('Business', {
  business_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  owner_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'users',
      key: 'user_id'
    }
  },
  category_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'business_categories',
      key: 'category_id'
    }
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false,
    validate: {
      notEmpty: { msg: 'Business name is required' }
    }
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  logo: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  phone: {
    type: DataTypes.STRING(20),
    allowNull: false,
    validate: {
      notEmpty: { msg: 'Phone is required' }
    }
  },
  email: {
    type: DataTypes.STRING(100),
    allowNull: true,
    validate: {
      isEmail: { msg: 'Invalid email format' }
    }
  },
  status: {
    type: DataTypes.ENUM('Pending', 'Active', 'Suspended', 'Closed'),
    defaultValue: 'Pending'
  },
  verification_status: {
    type: DataTypes.ENUM('Unverified', 'Pending', 'Verified', 'Rejected'),
    defaultValue: 'Unverified'
  },
  rating: {
    type: DataTypes.DECIMAL(3, 2),
    allowNull: true,
    validate: {
      min: 0,
      max: 5
    }
  },
  address: { type: DataTypes.STRING(255), allowNull: true },
city: { type: DataTypes.STRING(50), allowNull: true },
region: { type: DataTypes.STRING(50), allowNull: true },
opening_time: { type: DataTypes.STRING(20), allowNull: true },
closing_time: { type: DataTypes.STRING(20), allowNull: true },
delivery_fee: { type: DataTypes.DECIMAL(10, 2), allowNull: true, defaultValue: 0 },
rejection_reason: { type: DataTypes.TEXT, allowNull: true },

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
  minimum_order: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: true,
    defaultValue: 0
  },
  delivery_radius: {
    type: DataTypes.INTEGER,
    allowNull: true,
    comment: 'Delivery radius in kilometers'
  }
}, {
  tableName: 'businesses',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  indexes: [
    {
      name: 'idx_businesses_owner_id',
      fields: ['owner_id']
    },
    {
      name: 'idx_businesses_category_id',
      fields: ['category_id']
    },
    {
      name: 'idx_businesses_status',
      fields: ['status']
    }
  ]
});

module.exports = Business;