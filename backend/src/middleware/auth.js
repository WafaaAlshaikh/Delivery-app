// src/middleware/auth.js
const jwt = require('jsonwebtoken');
const { User, UserRole, Role } = require('../models');
require('dotenv').config();

const JWT_SECRET = process.env.JWT_SECRET;

// ============================================
// 📌 AUTHENTICATION MIDDLEWARE
// ============================================
const auth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'No token provided. Please login.'
      });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, JWT_SECRET);

    const user = await User.findByPk(decoded.user_id, {
      attributes: { exclude: ['password_hash'] }
    });

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'User not found. Please login again.'
      });
    }

    if (!user.is_active) {
      return res.status(403).json({
        success: false,
        message: 'Your account has been deactivated.'
      });
    }

    const userRoles = await UserRole.findAll({
      where: { user_id: user.user_id },
      include: [{ model: Role, attributes: ['name'] }]
    });
    const roles = userRoles.map(ur => ur.Role.name);

    req.user = {
      user_id: user.user_id,
      email: user.email,
      full_name: user.full_name,
      roles: roles,
      is_verified: user.is_verified,
      is_active: user.is_active
    };

    next();

  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: 'Invalid token. Please login again.'
      });
    }
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Token expired. Please login again.'
      });
    }
    console.error('Auth middleware error:', error);
    return res.status(500).json({
      success: false,
      message: 'Authentication error'
    });
  }
};

// ============================================
// 📌 AUTHORIZATION MIDDLEWARE
// ============================================
const authorize = (allowedRoles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required'
      });
    }

    const roles = Array.isArray(allowedRoles) ? allowedRoles : [allowedRoles];
    
    const hasAccess = req.user.roles.some(role => roles.includes(role));
    
    if (!hasAccess) {
      return res.status(403).json({
        success: false,
        message: `Access denied. Required role(s): ${roles.join(', ')}`
      });
    }

    next();
  };
};

// ============================================
// 📌 ADMIN MIDDLEWARE (اختصار)
// ============================================
const adminOnly = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({
      success: false,
      message: 'Authentication required'
    });
  }

  if (!req.user.roles.includes('Admin')) {
    return res.status(403).json({
      success: false,
      message: 'Admin access required'
    });
  }

  next();
};

// ============================================
// 📌 CHECK ROLE HELPERS
// ============================================
const hasRole = (req, roles) => {
  if (!req.user) return false;
  const allowedRoles = Array.isArray(roles) ? roles : [roles];
  return req.user.roles.some(role => allowedRoles.includes(role));
};

const isAdmin = (req) => hasRole(req, 'Admin');
const isMerchant = (req) => hasRole(req, 'Merchant');
const isDriver = (req) => hasRole(req, 'Driver');
const isCustomer = (req) => hasRole(req, 'Customer');

module.exports = {
  auth,
  authorize,
  adminOnly, 
  hasRole,
  isAdmin,
  isMerchant,
  isDriver,
  isCustomer
};