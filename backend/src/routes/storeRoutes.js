// src/routes/storeRoutes.js
const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const {
  getCategories,
  getStores,
  getStoreDetail,
  createStore,
  getMyStore,
  updateMyStore,
  createProduct
} = require('../controllers/storeController');

router.get('/categories', getCategories);

router.get('/my-store', auth, authorize('Merchant'), getMyStore);
router.put('/my-store', auth, authorize('Merchant'), updateMyStore);

router.get('/', getStores);
router.get('/:id', getStoreDetail);

router.post('/', auth, authorize('Merchant'), createStore);
router.post('/:id/products', auth, authorize('Merchant'), createProduct);

module.exports = router;
