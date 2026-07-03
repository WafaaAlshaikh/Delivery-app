// src/models/DriverProfile.js
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const DriverProfile = sequelize.define('DriverProfile', {
  profile_id: {
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
    },
    unique: true
  },
  vehicle_type: {
    type: DataTypes.ENUM('Bicycle', 'Motorcycle', 'Car', 'Van', 'Company'),
    allowNull: false,
    defaultValue: 'Motorcycle'
  },
  vehicle_plate: {
    type: DataTypes.STRING(20),
    allowNull: true
  },
  vehicle_color: {
    type: DataTypes.STRING(30),
    allowNull: true
  },
  vehicle_model: {
    type: DataTypes.STRING(50),
    allowNull: true
  },
  license_number: {
    type: DataTypes.STRING(50),
    allowNull: true
  },
  license_image: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  is_online: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  current_latitude: {
    type: DataTypes.DECIMAL(10, 8),
    allowNull: true
  },
  current_longitude: {
    type: DataTypes.DECIMAL(11, 8),
    allowNull: true
  },
  last_location_update: {
    type: DataTypes.DATE,
    allowNull: true
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
  total_deliveries: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    validate: {
      min: 0
    }
  },
  status: {
    type: DataTypes.ENUM('Pending', 'Active', 'Suspended', 'Rejected'),
    defaultValue: 'Pending'
  }
}, {
  tableName: 'driver_profiles',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  indexes: [
    {
      name: 'idx_driver_profiles_user_id',
      fields: ['user_id']
    },
    {
      name: 'idx_driver_profiles_status',
      fields: ['status']
    },
    {
      name: 'idx_driver_profiles_is_online',
      fields: ['is_online']
    }
  ]
});

module.exports = DriverProfile;