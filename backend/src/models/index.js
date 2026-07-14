// src/models/index.js
const sequelize = require('../config/database');

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
const DriverProfile = require('./DriverProfile'); 
const DeliveryOffer = require('./DeliveryOffer');
const Earning = require('./Earning');
const Rating = require('./Rating');
const ChatMessage = require('./ChatMessage');
const ScheduledOrder = require('./ScheduledOrder');

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

UserRole.belongsTo(User, { foreignKey: 'user_id' });
UserRole.belongsTo(Role, { foreignKey: 'role_id' });
User.hasMany(UserRole, { foreignKey: 'user_id' });
Role.hasMany(UserRole, { foreignKey: 'role_id' });

User.hasMany(Otp, { foreignKey: 'user_id' });
Otp.belongsTo(User, { foreignKey: 'user_id' });

User.hasMany(UserAddress, { foreignKey: 'user_id' });
UserAddress.belongsTo(User, { foreignKey: 'user_id' });

User.hasMany(Business, { foreignKey: 'owner_id' });
Business.belongsTo(User, { foreignKey: 'owner_id' });

User.hasOne(DriverProfile, { foreignKey: 'user_id' });
DriverProfile.belongsTo(User, { foreignKey: 'user_id' });

BusinessCategory.hasMany(Business, { foreignKey: 'category_id' });
Business.belongsTo(BusinessCategory, { foreignKey: 'category_id' });

Business.hasMany(Product, { foreignKey: 'business_id' });
Product.belongsTo(Business, { foreignKey: 'business_id' });

ProductCategory.hasMany(Product, { foreignKey: 'category_id' });
Product.belongsTo(ProductCategory, { foreignKey: 'category_id' });

Product.hasMany(ProductVariant, { foreignKey: 'product_id' });
ProductVariant.belongsTo(Product, { foreignKey: 'product_id' });

OrderStatus.hasMany(Order, { foreignKey: 'status_id' });
Order.belongsTo(OrderStatus, { foreignKey: 'status_id' });

User.hasMany(Order, { foreignKey: 'customer_id', as: 'CustomerOrders' });
Order.belongsTo(User, { foreignKey: 'customer_id', as: 'Customer' });

Business.hasMany(Order, { foreignKey: 'business_id' });
Order.belongsTo(Business, { foreignKey: 'business_id' });

User.hasMany(Order, { foreignKey: 'driver_id', as: 'DriverOrders' });
Order.belongsTo(User, { foreignKey: 'driver_id', as: 'Driver' });

UserAddress.hasMany(Order, { foreignKey: 'delivery_address_id' });
Order.belongsTo(UserAddress, { foreignKey: 'delivery_address_id' });

Order.hasMany(OrderItem, { foreignKey: 'order_id' });
OrderItem.belongsTo(Order, { foreignKey: 'order_id' });

Product.hasMany(OrderItem, { foreignKey: 'product_id' });
OrderItem.belongsTo(Product, { foreignKey: 'product_id' });

ProductVariant.hasMany(OrderItem, { foreignKey: 'variant_id' });
OrderItem.belongsTo(ProductVariant, { foreignKey: 'variant_id' });

Order.hasMany(OrderStatusHistory, { foreignKey: 'order_id' });
OrderStatusHistory.belongsTo(Order, { foreignKey: 'order_id' });

User.hasMany(OrderStatusHistory, { foreignKey: 'changed_by', as: 'StatusChanges' });
OrderStatusHistory.belongsTo(User, { foreignKey: 'changed_by', as: 'ChangedBy' });

Order.hasOne(Payment, { foreignKey: 'order_id' });
Payment.belongsTo(Order, { foreignKey: 'order_id' });

PaymentMethod.hasMany(Payment, { foreignKey: 'method_id' });
Payment.belongsTo(PaymentMethod, { foreignKey: 'method_id' });

PaymentStatus.hasMany(Payment, { foreignKey: 'status_id' });
Payment.belongsTo(PaymentStatus, { foreignKey: 'status_id' });

Order.hasOne(Review, { foreignKey: 'order_id' });
Review.belongsTo(Order, { foreignKey: 'order_id' });

Order.hasMany(DeliveryOffer, { foreignKey: 'order_id' });
DeliveryOffer.belongsTo(Order, { foreignKey: 'order_id' });

User.hasMany(DeliveryOffer, { foreignKey: 'driver_id', as: 'DeliveryOffers' });
DeliveryOffer.belongsTo(User, { foreignKey: 'driver_id', as: 'Driver' });

Earning.belongsTo(User, { foreignKey: 'driver_id', as: 'Driver' });
User.hasMany(Earning, { foreignKey: 'driver_id', as: 'Earnings' });

Earning.belongsTo(Order, { foreignKey: 'order_id' });
Order.hasOne(Earning, { foreignKey: 'order_id' });

Rating.belongsTo(User, { foreignKey: 'driver_id', as: 'Driver' });
Rating.belongsTo(User, { foreignKey: 'customer_id', as: 'Customer' });
Rating.belongsTo(Order, { foreignKey: 'order_id' });

ChatMessage.belongsTo(User, { foreignKey: 'sender_id', as: 'Sender' });
User.hasMany(ChatMessage, { foreignKey: 'sender_id', as: 'SentMessages' });

ChatMessage.belongsTo(User, { foreignKey: 'receiver_id', as: 'Receiver' });
User.hasMany(ChatMessage, { foreignKey: 'receiver_id', as: 'ReceivedMessages' });

ChatMessage.belongsTo(Order, { foreignKey: 'order_id' });
Order.hasMany(ChatMessage, { foreignKey: 'order_id' });

ScheduledOrder.belongsTo(Order, { foreignKey: 'order_id' });
Order.hasOne(ScheduledOrder, { foreignKey: 'order_id' });

ScheduledOrder.belongsTo(User, { foreignKey: 'driver_id', as: 'Driver' });
User.hasMany(ScheduledOrder, { foreignKey: 'driver_id', as: 'ScheduledOrders' });

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
  DriverProfile, 
  DeliveryOffer,
  Earning,
  Rating,
  ChatMessage,
  ScheduledOrder,
};