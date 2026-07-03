// src/models/index.js
const sequelize = require('../config/database');

// Import all models
const User = require('./User');
const Otp = require('./Otp');
const Role = require('./Role');
const UserRole = require('./UserRole');
const UserAddress = require('./UserAddress');
const BusinessCategory = require('./BusinessCategory');
const Business = require('./Business');
const ProductCategory = require('./ProductCategory');
const Product = require('./Product');
const ProductVariant = require('./ProductVariant');
const OrderStatus = require('./OrderStatus');
const Order = require('./Order');
const OrderItem = require('./OrderItem');
const OrderStatusHistory = require('./OrderStatusHistory');
const PaymentMethod = require('./PaymentMethod');
const PaymentStatus = require('./PaymentStatus');
const Payment = require('./Payment');
const Review = require('./Review');
const DriverProfile = require('./DriverProfile'); // ✅ جديد

// ============ Define Associations ============

// --- User & Role (Many-to-Many) ---
User.belongsToMany(Role, {
  through: UserRole,
  foreignKey: 'user_id',
  otherKey: 'role_id'
});
Role.belongsToMany(User, {
  through: UserRole,
  foreignKey: 'role_id',
  otherKey: 'user_id'
});

// ✅ IMPORTANT: Define associations for UserRole
UserRole.belongsTo(User, { foreignKey: 'user_id' });
UserRole.belongsTo(Role, { foreignKey: 'role_id' });
User.hasMany(UserRole, { foreignKey: 'user_id' });
Role.hasMany(UserRole, { foreignKey: 'role_id' });

// --- User & OTP (One-to-Many) ---
User.hasMany(Otp, { foreignKey: 'user_id' });
Otp.belongsTo(User, { foreignKey: 'user_id' });

// --- User & Address (One-to-Many) ---
User.hasMany(UserAddress, { foreignKey: 'user_id' });
UserAddress.belongsTo(User, { foreignKey: 'user_id' });

// --- User & Business (One-to-Many, as Owner) ---
User.hasMany(Business, { foreignKey: 'owner_id' });
Business.belongsTo(User, { foreignKey: 'owner_id' });

// --- User & DriverProfile (One-to-One) --- ✅ جديد
User.hasOne(DriverProfile, { foreignKey: 'user_id' });
DriverProfile.belongsTo(User, { foreignKey: 'user_id' });

// --- Business & BusinessCategory (Many-to-One) ---
BusinessCategory.hasMany(Business, { foreignKey: 'category_id' });
Business.belongsTo(BusinessCategory, { foreignKey: 'category_id' });

// --- Business & Product (One-to-Many) ---
Business.hasMany(Product, { foreignKey: 'business_id' });
Product.belongsTo(Business, { foreignKey: 'business_id' });

// --- ProductCategory & Product (One-to-Many) ---
ProductCategory.hasMany(Product, { foreignKey: 'category_id' });
Product.belongsTo(ProductCategory, { foreignKey: 'category_id' });

// --- Product & ProductVariant (One-to-Many) ---
Product.hasMany(ProductVariant, { foreignKey: 'product_id' });
ProductVariant.belongsTo(Product, { foreignKey: 'product_id' });

// --- Order Statuses ---
OrderStatus.hasMany(Order, { foreignKey: 'status_id' });
Order.belongsTo(OrderStatus, { foreignKey: 'status_id' });

// --- Order & User (Customer) ---
User.hasMany(Order, { foreignKey: 'customer_id', as: 'CustomerOrders' });
Order.belongsTo(User, { foreignKey: 'customer_id', as: 'Customer' });

// --- Order & Business ---
Business.hasMany(Order, { foreignKey: 'business_id' });
Order.belongsTo(Business, { foreignKey: 'business_id' });

// --- Order & User (Driver) ---
User.hasMany(Order, { foreignKey: 'driver_id', as: 'DriverOrders' });
Order.belongsTo(User, { foreignKey: 'driver_id', as: 'Driver' });

// --- Order & Address ---
UserAddress.hasMany(Order, { foreignKey: 'delivery_address_id' });
Order.belongsTo(UserAddress, { foreignKey: 'delivery_address_id' });

// --- Order & OrderItem (One-to-Many) ---
Order.hasMany(OrderItem, { foreignKey: 'order_id' });
OrderItem.belongsTo(Order, { foreignKey: 'order_id' });

// --- OrderItem & Product ---
Product.hasMany(OrderItem, { foreignKey: 'product_id' });
OrderItem.belongsTo(Product, { foreignKey: 'product_id' });

// --- OrderItem & ProductVariant ---
ProductVariant.hasMany(OrderItem, { foreignKey: 'variant_id' });
OrderItem.belongsTo(ProductVariant, { foreignKey: 'variant_id' });

// --- Order & OrderStatusHistory ---
Order.hasMany(OrderStatusHistory, { foreignKey: 'order_id' });
OrderStatusHistory.belongsTo(Order, { foreignKey: 'order_id' });

// --- OrderStatusHistory & User (who changed) ---
User.hasMany(OrderStatusHistory, { foreignKey: 'changed_by', as: 'StatusChanges' });
OrderStatusHistory.belongsTo(User, { foreignKey: 'changed_by', as: 'ChangedBy' });

// --- Order & Payment (One-to-One) ---
Order.hasOne(Payment, { foreignKey: 'order_id' });
Payment.belongsTo(Order, { foreignKey: 'order_id' });

// --- Payment & PaymentMethod ---
PaymentMethod.hasMany(Payment, { foreignKey: 'method_id' });
Payment.belongsTo(PaymentMethod, { foreignKey: 'method_id' });

// --- Payment & PaymentStatus ---
PaymentStatus.hasMany(Payment, { foreignKey: 'status_id' });
Payment.belongsTo(PaymentStatus, { foreignKey: 'status_id' });

// --- Order & Review (One-to-One) ---
Order.hasOne(Review, { foreignKey: 'order_id' });
Review.belongsTo(Order, { foreignKey: 'order_id' });

// Export all models
module.exports = {
  sequelize,
  User,
  Otp,
  Role,
  UserRole,
  UserAddress,
  BusinessCategory,
  Business,
  ProductCategory,
  Product,
  ProductVariant,
  OrderStatus,
  Order,
  OrderItem,
  OrderStatusHistory,
  PaymentMethod,
  PaymentStatus,
  Payment,
  Review,
  DriverProfile, // ✅ جديد
};