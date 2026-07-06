// src/controllers/adminController.js
const { Op } = require('sequelize');
const { 
  User, 
  Role, 
  UserRole, 
  Business, 
  Order, 
  OrderItem,
  Payment,
  OrderStatus,
  sequelize 
} = require('../models');
const DriverVerificationService = require('../services/driverVerificationService');


const getDashboardStats = async (req, res) => {
  try {
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📊 [ADMIN] Fetching dashboard stats');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const totalUsers = await User.count();

    const customerRole = await Role.findOne({ where: { name: 'Customer' } });
    const merchantRole = await Role.findOne({ where: { name: 'Merchant' } });
    const driverRole = await Role.findOne({ where: { name: 'Driver' } });

    let totalCustomers = 0;
    let totalMerchants = 0;
    let totalDrivers = 0;

    if (customerRole) {
      totalCustomers = await UserRole.count({ 
        where: { role_id: customerRole.role_id } 
      });
    }
    if (merchantRole) {
      totalMerchants = await UserRole.count({ 
        where: { role_id: merchantRole.role_id } 
      });
    }
    if (driverRole) {
      totalDrivers = await UserRole.count({ 
        where: { role_id: driverRole.role_id } 
      });
    }

    const totalOrders = await Order.count();

    const pendingOrders = await Order.count({ 
      where: { status_id: 1 }
    });
    const activeOrders = await Order.count({ 
      where: { status_id: { [Op.between]: [2, 7] } } 
    });
    const completedOrders = await Order.count({ 
      where: { status_id: 8 }
    });

    const revenueResult = await Order.sum('total', {
      where: { status_id: 8 } 
    });
    const totalRevenue = revenueResult || 0;

    const recentOrders = await Order.findAll({
      limit: 5,
      order: [['created_at', 'DESC']],
      include: [
        { model: User, as: 'Customer', attributes: ['full_name', 'email'] },
        { model: Business, attributes: ['name'] }
      ]
    });

    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);
    const newMerchants = await UserRole.count({
      where: {
        role_id: merchantRole?.role_id,
        assigned_at: { [Op.gte]: weekAgo }
      }
    });

    console.log('✅ Dashboard stats fetched successfully');
    console.log(`   ├─ Users: ${totalUsers}`);
    console.log(`   ├─ Orders: ${totalOrders}`);
    console.log(`   └─ Revenue: $${totalRevenue}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      data: {
        users: {
          total: totalUsers,
          customers: totalCustomers,
          merchants: totalMerchants,
          drivers: totalDrivers,
          newMerchants: newMerchants
        },
        orders: {
          total: totalOrders,
          pending: pendingOrders,
          active: activeOrders,
          completed: completedOrders
        },
        revenue: totalRevenue,
        recentOrders: recentOrders
      }
    });

  } catch (error) {
    console.error('❌ Dashboard stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching dashboard stats'
    });
  }
};

const getUsers = async (req, res) => {
  try {
    const { role, search, page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('👥 [ADMIN] Fetching users');
    console.log(`   ├─ role: ${role || 'All'}`);
    console.log(`   ├─ search: ${search || 'None'}`);
    console.log(`   └─ page: ${page}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const whereClause = {};
    if (search) {
      whereClause[Op.or] = [
        { full_name: { [Op.like]: `%${search}%` } },
        { email: { [Op.like]: `%${search}%` } }
      ];
    }

    const users = await User.findAndCountAll({
      where: whereClause,
      attributes: { exclude: ['password_hash'] },
      limit: parseInt(limit),
      offset: parseInt(offset),
      order: [['created_at', 'DESC']]
    });

    const usersWithRoles = await Promise.all(users.rows.map(async (user) => {
      const userRoles = await UserRole.findAll({
        where: { user_id: user.user_id },
        include: [{ model: Role, attributes: ['name'] }]
      });
      const roles = userRoles.map(ur => ur.Role.name);
      return {
        ...user.toJSON(),
        roles
      };
    }));

    let filteredUsers = usersWithRoles;
    if (role) {
      filteredUsers = usersWithRoles.filter(u => u.roles.includes(role));
    }

    console.log(`✅ Found ${filteredUsers.length} users`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      data: {
        users: filteredUsers,
        pagination: {
          total: filteredUsers.length,
          page: parseInt(page),
          limit: parseInt(limit)
        }
      }
    });

  } catch (error) {
    console.error('❌ Get users error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching users'
    });
  }
};


const getUserDetails = async (req, res) => {
  try {
    const { id } = req.params;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`👤 [ADMIN] Fetching user details: ${id}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const user = await User.findByPk(id, {
      attributes: { exclude: ['password_hash'] }
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const userRoles = await UserRole.findAll({
      where: { user_id: user.user_id },
      include: [{ model: Role, attributes: ['name'] }]
    });
    const roles = userRoles.map(ur => ur.Role.name);

    const ordersCount = await Order.count({
      where: { customer_id: user.user_id }
    });

    const userData = {
      ...user.toJSON(),
      roles,
      ordersCount
    };

    console.log(`✅ User details fetched: ${user.email}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      data: userData
    });

  } catch (error) {
    console.error('❌ Get user details error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching user details'
    });
  }
};


const updateUserStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { is_active } = req.body;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`🔄 [ADMIN] Updating user status: ${id}`);
    console.log(`   └─ is_active: ${is_active}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const user = await User.findByPk(id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    await user.update({ is_active });

    console.log(`✅ User ${user.email} status updated to ${is_active}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      message: `User ${is_active ? 'activated' : 'deactivated'} successfully`,
      data: { user_id: user.user_id, is_active: user.is_active }
    });

  } catch (error) {
    console.error('❌ Update user status error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error updating user status'
    });
  }
};


const updateUserRole = async (req, res) => {
  try {
    const { id } = req.params;
    const { role } = req.body;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`🔄 [ADMIN] Updating user role: ${id}`);
    console.log(`   └─ new role: ${role}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const user = await User.findByPk(id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const roleRecord = await Role.findOne({ where: { name: role } });
    if (!roleRecord) {
      return res.status(400).json({
        success: false,
        message: `Role "${role}" not found`
      });
    }

    await UserRole.destroy({ where: { user_id: user.user_id } });

    await UserRole.create({
      user_id: user.user_id,
      role_id: roleRecord.role_id,
      assigned_at: new Date()
    });

    console.log(`✅ User ${user.email} role updated to ${role}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      message: `User role updated to ${role}`,
      data: { user_id: user.user_id, role }
    });

  } catch (error) {
    console.error('❌ Update user role error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error updating user role'
    });
  }
};


const deleteUser = async (req, res) => {
  try {
    const { id } = req.params;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`🗑️ [ADMIN] Deleting user: ${id}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const user = await User.findByPk(id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    await UserRole.destroy({ where: { user_id: user.user_id } });

    await user.destroy();

    console.log(`✅ User ${user.email} deleted successfully`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      message: 'User deleted successfully'
    });

  } catch (error) {
    console.error('❌ Delete user error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error deleting user'
    });
  }
};


const getMerchants = async (req, res) => {
  try {
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('🏪 [ADMIN] Fetching merchants');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const merchantRole = await Role.findOne({ where: { name: 'Merchant' } });
    if (!merchantRole) {
      return res.status(404).json({
        success: false,
        message: 'Merchant role not found'
      });
    }

    const userRoles = await UserRole.findAll({
      where: { role_id: merchantRole.role_id },
      include: [
        { 
          model: User, 
          attributes: { exclude: ['password_hash'] },
          include: [
            { model: Business, attributes: ['business_id', 'name', 'status', 'rating'] }
          ]
        }
      ]
    });

    const merchants = userRoles.map(ur => {
      const user = ur.User;
      return {
        user_id: user.user_id,
        full_name: user.full_name,
        email: user.email,
        phone: user.phone,
        is_active: user.is_active,
        is_verified: user.is_verified,
        business: user.Businesses?.[0] || null,
        created_at: user.created_at
      };
    });

    console.log(`✅ Found ${merchants.length} merchants`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      data: merchants
    });

  } catch (error) {
    console.error('❌ Get merchants error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching merchants'
    });
  }
};


const getDrivers = async (req, res) => {
  try {
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('🚗 [ADMIN] Fetching drivers');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const driverRole = await Role.findOne({ where: { name: 'Driver' } });
    if (!driverRole) {
      return res.status(404).json({
        success: false,
        message: 'Driver role not found'
      });
    }

    const userRoles = await UserRole.findAll({
      where: { role_id: driverRole.role_id },
      include: [
        { 
          model: User, 
          attributes: { exclude: ['password_hash'] }
        }
      ]
    });

    const drivers = userRoles.map(ur => {
      const user = ur.User;
      return {
        user_id: user.user_id,
        full_name: user.full_name,
        email: user.email,
        phone: user.phone,
        is_active: user.is_active,
        is_verified: user.is_verified,
        created_at: user.created_at
      };
    });

    console.log(`✅ Found ${drivers.length} drivers`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      data: drivers
    });

  } catch (error) {
    console.error('❌ Get drivers error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching drivers'
    });
  }
};


const getOrders = async (req, res) => {
  try {
    const { status, page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📦 [ADMIN] Fetching orders');
    console.log(`   ├─ status: ${status || 'All'}`);
    console.log(`   └─ page: ${page}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const whereClause = {};
    if (status) {
      whereClause.status_id = status;
    }

    const orders = await Order.findAndCountAll({
      where: whereClause,
      limit: parseInt(limit),
      offset: parseInt(offset),
      order: [['created_at', 'DESC']],
      include: [
        { model: User, as: 'Customer', attributes: ['full_name', 'email', 'phone'] },
        { model: Business, attributes: ['name'] },
        { model: User, as: 'Driver', attributes: ['full_name'], required: false },
        { model: OrderStatus, attributes: ['name', 'color'] }
      ]
    });

    console.log(`✅ Found ${orders.count} orders`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      data: {
        orders: orders.rows,
        pagination: {
          total: orders.count,
          page: parseInt(page),
          limit: parseInt(limit)
        }
      }
    });

  } catch (error) {
    console.error('❌ Get orders error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching orders'
    });
  }
};


const getOrderDetails = async (req, res) => {
  try {
    const { id } = req.params;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`📦 [ADMIN] Fetching order details: ${id}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const order = await Order.findByPk(id, {
      include: [
        { model: User, as: 'Customer', attributes: ['full_name', 'email', 'phone'] },
        { model: Business, attributes: ['name', 'phone', 'email'] },
        { model: User, as: 'Driver', attributes: ['full_name', 'phone'], required: false },
        { model: OrderStatus, attributes: ['name', 'color'] },
        { 
          model: OrderItem,
          include: [
            { model: Product, attributes: ['name', 'image_url'] }
          ]
        },
        { model: Payment, include: [{ model: PaymentStatus, attributes: ['name'] }] }
      ]
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    console.log(`✅ Order ${id} details fetched`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      data: order
    });

  } catch (error) {
    console.error('❌ Get order details error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching order details'
    });
  }
};


const updateOrderStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status_id, notes } = req.body;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`🔄 [ADMIN] Updating order status: ${id}`);
    console.log(`   ├─ status_id: ${status_id}`);
    console.log(`   └─ notes: ${notes || 'None'}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const order = await Order.findByPk(id);
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    await order.update({ status_id });

    const { OrderStatusHistory } = require('../models');
    await OrderStatusHistory.create({
      order_id: order.order_id,
      status_id: status_id,
      changed_by: req.user.user_id,
      notes: notes || null
    });

    console.log(`✅ Order ${id} status updated to ${status_id}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      message: 'Order status updated successfully',
      data: { order_id: order.order_id, status_id: order.status_id }
    });

  } catch (error) {
    console.error('❌ Update order status error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error updating order status'
    });
  }
};


const getChartData = async (req, res) => {
  try {
    const { period = 'week' } = req.query;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`📊 [ADMIN] Fetching chart data: ${period}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    let startDate;
    const now = new Date();

    switch (period) {
      case 'week':
        startDate = new Date(now);
        startDate.setDate(now.getDate() - 7);
        break;
      case 'month':
        startDate = new Date(now);
        startDate.setMonth(now.getMonth() - 1);
        break;
      case 'year':
        startDate = new Date(now);
        startDate.setFullYear(now.getFullYear() - 1);
        break;
      default:
        startDate = new Date(now);
        startDate.setDate(now.getDate() - 7);
    }

    const orders = await Order.findAll({
      where: {
        created_at: { [Op.gte]: startDate },
        status_id: 8 
      },
      attributes: [
        [sequelize.fn('DATE', sequelize.col('created_at')), 'date'],
        [sequelize.fn('COUNT', sequelize.col('order_id')), 'count'],
        [sequelize.fn('SUM', sequelize.col('total')), 'revenue']
      ],
      group: [sequelize.fn('DATE', sequelize.col('created_at'))],
      order: [[sequelize.fn('DATE', sequelize.col('created_at')), 'ASC']]
    });

    console.log(`✅ Chart data fetched: ${orders.length} entries`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      data: orders
    });

  } catch (error) {
    console.error('❌ Chart data error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching chart data'
    });
  }
};

const getDriverApplications = async (req, res) => {
  try {
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📋 [ADMIN] Fetching driver applications');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const { status = 'Pending' } = req.query;
    
    const drivers = await DriverVerificationService.getDriversByStatus(status);

    console.log(`✅ Found ${drivers.length} driver applications`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      data: drivers
    });

  } catch (error) {
    console.error('❌ Get driver applications error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching driver applications'
    });
  }
};

const reviewDriverApplication = async (req, res) => {
  try {
    const { profileId } = req.params;
    const { action, notes } = req.body;

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📋 [ADMIN] Reviewing driver application');
    console.log(`   ├─ Profile ID: ${profileId}`);
    console.log(`   ├─ Action: ${action}`);
    console.log(`   └─ Notes: ${notes || 'None'}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (!['approve', 'reject', 'suspend'].includes(action)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid action. Use: approve, reject, or suspend'
      });
    }

    const result = await DriverVerificationService.adminReview(
      profileId,
      action,
      notes
    );

    console.log(`✅ Driver ${action}d successfully`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json(result);

  } catch (error) {
    console.error('❌ Review driver application error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error reviewing driver application'
    });
  }
};

const getDriverStats = async (req, res) => {
  try {
    const stats = await DriverVerificationService.getDriverStats();

    res.status(200).json({
      success: true,
      data: stats
    });

  } catch (error) {
    console.error('❌ Get driver stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching driver stats'
    });
  }
};

const getAllDriversForAdmin = async (req, res) => {
  try {
    const { status } = req.query;
    const drivers = await DriverVerificationService.getDriversByStatus(status || null);

    res.status(200).json({
      success: true,
      data: drivers
    });

  } catch (error) {
    console.error('❌ Get all drivers error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching drivers'
    });
  }
};

module.exports = {
  getDashboardStats,
  getUsers,
  getUserDetails,
  updateUserStatus,
  updateUserRole,
  deleteUser,
  getMerchants,
  getDrivers,
  getOrders,
  getOrderDetails,
  updateOrderStatus,
  getChartData,
  getDriverApplications,
  reviewDriverApplication,
  getDriverStats,
  getAllDriversForAdmin
};