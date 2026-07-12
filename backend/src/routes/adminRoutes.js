// src/routes/adminRoutes.js
const express = require('express');
const router = express.Router();
const { auth, adminOnly } = require('../middleware/auth');
const {
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
  getAllDriversForAdmin,
  createUser,
  getStores,
  approveStore,
  rejectStore,
  deleteStore,
  getCategories
} = require('../controllers/adminController');

router.use(auth, adminOnly);

router.get('/stats', getDashboardStats);
router.get('/chart-data', getChartData);

router.get('/users', getUsers);
router.get('/users/:id', getUserDetails);
router.put('/users/:id/status', updateUserStatus);
router.put('/users/:id/role', updateUserRole);
router.delete('/users/:id', deleteUser);
router.post('/users', createUser);

router.get('/merchants', getMerchants);

router.get('/drivers', getDrivers);


router.get('/orders', getOrders);
router.get('/orders/:id', getOrderDetails);
router.put('/orders/:id/status', updateOrderStatus);

router.get('/driver-applications', auth, adminOnly, getDriverApplications);
router.put('/driver-applications/:profileId', auth, adminOnly, reviewDriverApplication);
router.get('/drivers/stats', auth, adminOnly, getDriverStats);
router.get('/drivers/all', auth, adminOnly, getAllDriversForAdmin);

router.get('/dashboard', getDashboardStats);

router.get('/stores', getStores);
router.put('/stores/:id/approve', approveStore);
router.put('/stores/:id/reject', rejectStore);
router.delete('/stores/:id', deleteStore);

router.get('/users', getUsers);

router.get('/categories', getCategories);

module.exports = router;