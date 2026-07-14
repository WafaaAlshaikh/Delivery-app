// backend/src/models/Rating.js

const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Rating = sequelize.define('Rating', {
  rating_id: {
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
    unique: true
  },
  driver_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'users',
      key: 'user_id'
    }
  },
  customer_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'users',
      key: 'user_id'
    }
  },
  rating: {
    type: DataTypes.DECIMAL(3, 2),
    allowNull: false,
    validate: {
      min: 0,
      max: 5
    }
  },
  comment: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  delivery_time: {
    type: DataTypes.ENUM('on_time', 'late', 'early'),
    defaultValue: 'on_time'
  },
  is_anonymous: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  sentiment: {
    type: DataTypes.ENUM('positive', 'neutral', 'negative'),
    allowNull: true
  },
  sentiment_score: {
    type: DataTypes.DECIMAL(5, 4),
    allowNull: true
  },
  keywords: {
    type: DataTypes.JSON,
    allowNull: true
  }
}, {
  tableName: 'ratings',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  indexes: [
    {
      name: 'idx_ratings_driver_id',
      fields: ['driver_id']
    },
    {
      name: 'idx_ratings_order_id',
      fields: ['order_id']
    },
    {
      name: 'idx_ratings_rating',
      fields: ['rating']
    },
    {
      name: 'idx_ratings_created_at',
      fields: ['created_at']
    }
  ]
});

module.exports = Rating;