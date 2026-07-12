// src/controllers/storeController.js
const { BusinessCategory, Business, Product, User } = require('../models');
const BusinessVerificationService = require('../services/businessVerificationService');

const getCategories = async (req, res) => {
  try {
    const categories = await BusinessCategory.findAll({
      order: [['sort_order', 'ASC']]
    });

    res.status(200).json({
      success: true,
      categories: categories.map(c => ({
        id: c.category_id,
        name: c.name,
        icon: c.icon,
        sort_order: c.sort_order
      }))
    });
  } catch (error) {
    console.error('❌ Get categories error:', error);
    res.status(500).json({ success: false, message: 'Server error while fetching categories' });
  }
};

const getStores = async (req, res) => {
  try {
    const { category_id } = req.query;

    const where = { status: 'Active', verification_status: 'Verified' };
    if (category_id) where.category_id = category_id;

    const stores = await Business.findAll({ where });

    res.status(200).json({
      success: true,
      stores: stores.map(formatStore)
    });
  } catch (error) {
    console.error('❌ Get stores error:', error);
    res.status(500).json({ success: false, message: 'Server error while fetching stores' });
  }
};

const getStoreDetail = async (req, res) => {
  try {
    const store = await Business.findByPk(req.params.id, {
      include: [{ model: Product, where: { is_available: true }, required: false }]
    });

    if (!store) {
      return res.status(404).json({ success: false, message: 'Store not found' });
    }

    res.status(200).json({
      success: true,
      store: formatStore(store),
      products: (store.Products || []).map(formatProduct)
    });
  } catch (error) {
    console.error('❌ Get store detail error:', error);
    res.status(500).json({ success: false, message: 'Server error while fetching store details' });
  }
};


const createStore = async (req, res) => {
  try {
    const {
      name, description, category_id, logo,
      address, latitude, longitude, city, region, phone, email,
      opening_time, closing_time, minimum_order, delivery_radius
    } = req.body;

    if (!name || !category_id || !phone) {
      return res.status(400).json({ success: false, message: 'Name, category and phone are required' });
    }

    const store = await Business.create({
      owner_id: req.user.user_id,
      name,
      description,
      category_id,
      logo,
      address,
      latitude,
      longitude,
      city,
      region,
      phone,
      email,
      opening_time,
      closing_time,
      minimum_order: minimum_order || 0,
      delivery_radius
    });

    const autoApprovalResult = await BusinessVerificationService.processAutoApproval(
      store.business_id
    );

    const updatedStore = await Business.findByPk(store.business_id);

    res.status(201).json({
      success: true,
      message: updatedStore.verification_status === 'Verified'
        ? '🎉 Your store is now active! You can start receiving orders.'
        : 'Store created. It will be reviewed and approved shortly.',
      store: formatStore(updatedStore),
      autoApproval: autoApprovalResult || null,
    });
  } catch (error) {
    console.error('❌ Create store error:', error);
    res.status(500).json({ success: false, message: 'Server error while creating store' });
  }
};

const getMyStore = async (req, res) => {
  try {
    const store = await Business.findOne({ where: { owner_id: req.user.user_id } });

    if (!store) {
      return res.status(200).json({ success: true, store: null });
    }

    res.status(200).json({ success: true, store: formatStore(store) });
  } catch (error) {
    console.error('❌ Get my store error:', error);
    res.status(500).json({ success: false, message: 'Server error while fetching your store' });
  }
};

const updateMyStore = async (req, res) => {
  try {
    const store = await Business.findOne({ where: { owner_id: req.user.user_id } });
    if (!store) {
      return res.status(404).json({ success: false, message: 'You do not have a store yet' });
    }

    const {
      name, description, category_id, logo,
      address, latitude, longitude, city, region, phone, email,
      opening_time, closing_time, minimum_order, delivery_radius
    } = req.body;

    await store.update({
      name: name ?? store.name,
      description: description ?? store.description,
      category_id: category_id ?? store.category_id,
      logo: logo ?? store.logo,
      address: address ?? store.address,
      latitude: latitude ?? store.latitude,
      longitude: longitude ?? store.longitude,
      city: city ?? store.city,
      region: region ?? store.region,
      phone: phone ?? store.phone,
      email: email ?? store.email,
      opening_time: opening_time ?? store.opening_time,
      closing_time: closing_time ?? store.closing_time,
      minimum_order: minimum_order ?? store.minimum_order,
      delivery_radius: delivery_radius ?? store.delivery_radius,
      verification_status: store.verification_status === 'Rejected' ? 'Pending' : store.verification_status,
      rejection_reason: store.verification_status === 'Rejected' ? null : store.rejection_reason
    });

    res.status(200).json({ success: true, message: 'Store updated', store: formatStore(store) });
  } catch (error) {
    console.error('❌ Update my store error:', error);
    res.status(500).json({ success: false, message: 'Server error while updating your store' });
  }
};

const createProduct = async (req, res) => {
  try {
    const store = await Business.findByPk(req.params.id);
    if (!store) return res.status(404).json({ success: false, message: 'Store not found' });

    if (store.owner_id !== req.user.user_id) {
      return res.status(403).json({ success: false, message: 'You do not own this store' });
    }

    const { name, description, image_url, price, category_id } = req.body;
    if (!name || price === undefined || !category_id) {
      return res.status(400).json({ success: false, message: 'name, price and category_id are required' });
    }

    const product = await Product.create({
      business_id: store.business_id,
      category_id,
      name,
      description,
      image_url,
      price
    });

    res.status(201).json({ success: true, product: formatProduct(product) });
  } catch (error) {
    console.error('❌ Create product error:', error);
    res.status(500).json({ success: false, message: 'Server error while creating product' });
  }
};

function formatStore(store) {
  return {
    id: store.business_id.toString(),
    name: store.name,
    category_id: store.category_id ? store.category_id.toString() : '',
    image_url: store.logo || '',
    average_rating: parseFloat(store.rating || 0),
    status: store.status,
    approval_status: store.verification_status, 
    is_approved: store.verification_status === 'Verified',
    rejection_reason: store.rejection_reason || null,
    address: store.address || '',
    city: store.city || '',
    region: store.region || '',
    phone: store.phone,
    email: store.email || '',
    description: store.description || '',
    opening_time: store.opening_time,
    closing_time: store.closing_time,
    delivery_fee: store.delivery_radius ? store.delivery_radius.toString() : '0',
    minimum_order: store.minimum_order ? store.minimum_order.toString() : '0'
  };
}

function formatProduct(product) {
  return {
    id: product.product_id.toString(),
    name: product.name,
    description: product.description || '',
    store_id: product.business_id.toString(),
    image_url: product.image_url || '',
    price: parseFloat(product.price),
    is_available: product.is_available
  };
}

module.exports = {
  getCategories,
  getStores,
  getStoreDetail,
  createStore,
  getMyStore,
  updateMyStore,
  createProduct
};