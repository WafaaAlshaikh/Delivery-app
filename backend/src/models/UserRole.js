// src/models/UserRole.js
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const UserRole = sequelize.define('UserRole', {
  user_role_id: {
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
  role_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'roles',
      key: 'role_id'
    }
  },
  assigned_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'user_roles',
  timestamps: false,
  indexes: [
    {
      name: 'idx_user_roles_user_id',
      fields: ['user_id']
    },
    {
      name: 'idx_user_roles_role_id',
      fields: ['role_id']
    },
    {
      name: 'idx_user_roles_unique',
      unique: true,
      fields: ['user_id', 'role_id']
    }
  ]
});

module.exports = UserRole;