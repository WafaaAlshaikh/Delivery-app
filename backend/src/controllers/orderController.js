// src/controllers/orderController.js
const {
  Order,
  OrderItem,
  Product,
  Restaurant,
  User,
  sequelize,
} = require("../models");

const createOrder = async (req, res) => {
  const t = await sequelize.transaction();
  try {
    const {
      restaurant_id,
      items,
      delivery_address,
      delivery_lat,
      delivery_lng,
      payment_method,
      special_instructions,
    } = req.body;

    if (
      !restaurant_id ||
      !items ||
      !items.length ||
      !delivery_address ||
      !payment_method
    ) {
      await t.rollback();
      return res
        .status(400)
        .json({ success: false, message: "Missing required order fields" });
    }

    const store = await Restaurant.findByPk(restaurant_id, { transaction: t });
    if (!store) {
      await t.rollback();
      return res
        .status(404)
        .json({ success: false, message: "Store not found" });
    }

    const productIds = items.map((i) => i.product_id);
    const products = await Product.findAll({
      where: { product_id: productIds },
      transaction: t,
    });

    if (products.length !== productIds.length) {
      await t.rollback();
      return res
        .status(400)
        .json({ success: false, message: "One or more products not found" });
    }

    let totalAmount = 0;
    const orderItemsData = items.map((item) => {
      const product = products.find((p) => p.product_id === item.product_id);
      const subtotal = parseFloat(product.price) * item.quantity;
      totalAmount += subtotal;
      return {
        product_id: product.product_id,
        quantity: item.quantity,
        unit_price: product.price,
        subtotal,
      };
    });

    const deliveryFee = parseFloat(store.delivery_fee || 0);
    const finalAmount = totalAmount + deliveryFee;
    const orderNumber = `ORD-${Date.now()}`;

    const order = await Order.create(
      {
        customer_id: req.user.user_id,
        restaurant_id: store.restaurant_id,
        order_number: orderNumber,
        status: "Pending",
        total_amount: totalAmount,
        delivery_fee: deliveryFee,
        final_amount: finalAmount,
        delivery_address,
        delivery_lat: delivery_lat || null,
        delivery_lng: delivery_lng || null,
        special_instructions: special_instructions || null,
        payment_method,
        payment_status: "Pending",
      },
      { transaction: t },
    );

    await OrderItem.bulkCreate(
      orderItemsData.map((i) => ({ ...i, order_id: order.order_id })),
      { transaction: t },
    );

    await t.commit();

    const fullOrder = await Order.findByPk(order.order_id, {
      include: [
        {
          model: OrderItem,
          as: "items",
          include: [{ model: Product, as: "product" }],
        },
      ],
    });

    res
      .status(201)
      .json({
        success: true,
        message: "Order placed successfully",
        order: formatOrder(fullOrder),
      });
  } catch (error) {
    await t.rollback();
    console.error("❌ Create order error:", error);
    res
      .status(500)
      .json({ success: false, message: "Server error while creating order" });
  }
};

const getMyOrders = async (req, res) => {
  try {
    const { role, user_id } = req.user;
    let where = {};

    if (role === "Customer") where = { customer_id: user_id };
    else if (role === "Restaurant") {
      const store = await Restaurant.findOne({ where: { user_id } });
      if (!store) return res.status(200).json({ success: true, orders: [] });
      where = { restaurant_id: store.restaurant_id };
    } else if (role === "Driver") where = { driver_id: user_id };

    const orders = await Order.findAll({
      where,
      include: [
        {
          model: OrderItem,
          as: "items",
          include: [{ model: Product, as: "product" }],
        },
      ],
      order: [["order_time", "DESC"]],
    });

    res.status(200).json({ success: true, orders: orders.map(formatOrder) });
  } catch (error) {
    console.error("❌ Get my orders error:", error);
    res
      .status(500)
      .json({ success: false, message: "Server error while fetching orders" });
  }
};

const getAvailableOrders = async (req, res) => {
  try {
    const orders = await Order.findAll({
      where: { status: "Ready", driver_id: null },
      include: [{ model: Restaurant, as: "store" }],
      order: [["order_time", "ASC"]],
    });

    res.status(200).json({ success: true, orders: orders.map(formatOrder) });
  } catch (error) {
    console.error("❌ Get available orders error:", error);
    res
      .status(500)
      .json({
        success: false,
        message: "Server error while fetching available orders",
      });
  }
};

const updateOrderStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const validStatuses = [
      "Pending",
      "Confirmed",
      "Preparing",
      "Ready",
      "PickedUp",
      "Delivered",
      "Cancelled",
    ];

    if (!validStatuses.includes(status)) {
      return res
        .status(400)
        .json({ success: false, message: "Invalid status value" });
    }

    const order = await Order.findByPk(req.params.id);
    if (!order)
      return res
        .status(404)
        .json({ success: false, message: "Order not found" });

    const { role, user_id } = req.user;

    if (role === "Restaurant") {
      const store = await Restaurant.findOne({ where: { user_id } });
      if (!store || store.restaurant_id !== order.restaurant_id) {
        return res
          .status(403)
          .json({
            success: false,
            message: "This order does not belong to your store",
          });
      }
      const allowed = ["Confirmed", "Preparing", "Ready", "Cancelled"];
      if (!allowed.includes(status)) {
        return res
          .status(403)
          .json({
            success: false,
            message: "Restaurants cannot set this status",
          });
      }
    } else if (role === "Driver") {
      const allowed = ["PickedUp", "Delivered"];
      if (!allowed.includes(status)) {
        return res
          .status(403)
          .json({ success: false, message: "Drivers cannot set this status" });
      }
      if (status === "Delivered" && order.driver_id !== user_id) {
        return res
          .status(403)
          .json({
            success: false,
            message: "You are not assigned to this order",
          });
      }
      if (
        status === "PickedUp" &&
        order.driver_id &&
        order.driver_id !== user_id
      ) {
        return res
          .status(403)
          .json({
            success: false,
            message: "This order is already assigned to another driver",
          });
      }
    } else if (role === "Customer") {
      if (
        order.customer_id !== user_id ||
        status !== "Cancelled" ||
        order.status !== "Pending"
      ) {
        return res
          .status(403)
          .json({
            success: false,
            message: "You can only cancel your own pending orders",
          });
      }
    } else if (role !== "Admin") {
      return res.status(403).json({ success: false, message: "Access denied" });
    }

    if (status === "PickedUp" && !order.driver_id && role === "Driver") {
      order.driver_id = user_id;
    }

    order.status = status;
    if (status === "Delivered") order.completed_time = new Date();

    await order.save();

    res
      .status(200)
      .json({
        success: true,
        message: "Order status updated",
        order: formatOrder(order),
      });
  } catch (error) {
    console.error("❌ Update order status error:", error);
    res
      .status(500)
      .json({
        success: false,
        message: "Server error while updating order status",
      });
  }
};

function formatOrder(order) {
  return {
    id: order.order_id.toString(),
    order_number: order.order_number,
    status: order.status,
    total_amount: parseFloat(order.total_amount),
    delivery_fee: parseFloat(order.delivery_fee),
    final_amount: parseFloat(order.final_amount),
    delivery_address: order.delivery_address,
    payment_method: order.payment_method,
    payment_status: order.payment_status,
    order_time: order.order_time,
    store_id: order.restaurant_id ? order.restaurant_id.toString() : null,
    store_name: order.store ? order.store.name : undefined,
    driver_id: order.driver_id ? order.driver_id.toString() : null,
    items: (order.items || []).map((i) => ({
      product_id: i.product_id.toString(),
      name: i.product ? i.product.name : "",
      quantity: i.quantity,
      unit_price: parseFloat(i.unit_price),
      subtotal: parseFloat(i.subtotal),
    })),
  };
}

module.exports = {
  createOrder,
  getMyOrders,
  getAvailableOrders,
  updateOrderStatus,
};
