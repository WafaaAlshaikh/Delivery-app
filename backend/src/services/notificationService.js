// backend/src/services/notificationService.js

const admin = require("firebase-admin");
const { Order, User, DriverProfile, Role, UserRole } = require("../models");

class NotificationService {
  constructor() {
    try {
      if (admin && typeof admin.initializeApp === "function") {
        if (!admin.apps || admin.apps.length === 0) {
          const privateKey = process.env.FIREBASE_PRIVATE_KEY
            ? process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n")
            : undefined;

          const projectId = process.env.FIREBASE_PROJECT_ID;
          const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;

          if (privateKey && projectId && clientEmail) {
            admin.initializeApp({
              credential: admin.credential.cert({
                projectId: projectId,
                privateKey: privateKey,
                clientEmail: clientEmail,
              }),
            });
            console.log("✅ Firebase Admin initialized successfully");
          } else {
            console.warn(
              "⚠️ Firebase credentials missing. Push notifications disabled.",
            );
            console.warn(
              "   Required: FIREBASE_PROJECT_ID, FIREBASE_PRIVATE_KEY, FIREBASE_CLIENT_EMAIL",
            );
          }
        } else {
          console.log("✅ Firebase Admin already initialized");
        }
      } else {
        console.warn(
          "⚠️ Firebase Admin SDK not available. Push notifications disabled.",
        );
      }
    } catch (error) {
      console.error("❌ Firebase Admin initialization error:", error.message);
    }
  }

  isFirebaseReady() {
    try {
      return admin && admin.apps && admin.apps.length > 0;
    } catch (e) {
      return false;
    }
  }

  static async sendLowRatingNotification(token, driverName, rating, comment, orderId) {
    try {
      if (!token) {
        console.warn("⚠️ No FCM token provided for low rating notification");
        return { success: false, message: "No token provided" };
      }

      const instance = new NotificationService();
      if (!instance.isFirebaseReady()) {
        console.warn("⚠️ Firebase not ready, skipping notification");
        return { success: false, message: "Firebase not initialized" };
      }

      const title = `⚠️ Low Rating Alert`;
      const body = `${driverName}, you received a ${rating}⭐ rating: "${comment}"`;

      const result = await instance.sendPushNotification({
        token: token,
        title: title,
        body: body,
        data: {
          type: "low_rating",
          orderId: String(orderId),
          rating: String(rating),
          comment: comment || "",
        },
      });

      console.log(`✅ Low rating notification sent to ${driverName}`);
      return result;
    } catch (error) {
      console.error("❌ Send low rating notification error:", error.message);
      return { success: false, message: error.message };
    }
  }

  static async sendExcellentRatingNotification(token, driverName, rating, comment, orderId) {
    try {
      if (!token) {
        console.warn("⚠️ No FCM token provided for excellent rating notification");
        return { success: false, message: "No token provided" };
      }

      const instance = new NotificationService();
      if (!instance.isFirebaseReady()) {
        console.warn("⚠️ Firebase not ready, skipping notification");
        return { success: false, message: "Firebase not initialized" };
      }

      const title = `🌟 Excellent Rating!`;
      const body = `${driverName}, you received a ${rating}⭐ rating! "${comment}"`;

      const result = await instance.sendPushNotification({
        token: token,
        title: title,
        body: body,
        data: {
          type: "excellent_rating",
          orderId: String(orderId),
          rating: String(rating),
          comment: comment || "",
        },
      });

      console.log(`✅ Excellent rating notification sent to ${driverName}`);
      return result;
    } catch (error) {
      console.error("❌ Send excellent rating notification error:", error.message);
      return { success: false, message: error.message };
    }
  }

  static async sendNewRatingNotification(token, driverName, rating, comment, orderId) {
    try {
      if (!token) {
        console.warn("⚠️ No FCM token provided for new rating notification");
        return { success: false, message: "No token provided" };
      }

      const instance = new NotificationService();
      if (!instance.isFirebaseReady()) {
        console.warn("⚠️ Firebase not ready, skipping notification");
        return { success: false, message: "Firebase not initialized" };
      }

      const stars = '⭐'.repeat(Math.round(rating));
      const title = `📝 New Rating Received!`;
      const body = `${driverName}, you received ${stars} ${rating}⭐ from a customer`;

      const result = await instance.sendPushNotification({
        token: token,
        title: title,
        body: body,
        data: {
          type: "new_rating",
          orderId: String(orderId),
          rating: String(rating),
          comment: comment || "",
        },
      });

      console.log(`✅ New rating notification sent to ${driverName}`);
      return result;
    } catch (error) {
      console.error("❌ Send new rating notification error:", error.message);
      return { success: false, message: error.message };
    }
  }


  async sendOrderNotification(orderId, driverId, customerId) {
    try {
      if (!this.isFirebaseReady()) {
        console.warn("⚠️ Firebase not ready, skipping notification");
        return { success: false, message: "Firebase not initialized" };
      }

      const order = await Order.findByPk(orderId, {
        include: [{ model: User, as: "Customer" }, { model: DriverProfile }],
      });

      if (!order) throw new Error("Order not found");

      if (driverId) {
        const token = await this.getDriverToken(driverId);
        if (token) {
          await this.sendPushNotification({
            token: token,
            title: "📦 New Order Available",
            body: `Order #${orderId} - ${order.Customer?.full_name || "Customer"}`,
            data: {
              type: "order",
              orderId: String(orderId),
              driverId: String(driverId),
              screen: "order_details",
            },
          });
        }
      }

      if (customerId) {
        const token = await this.getCustomerToken(customerId);
        if (token) {
          await this.sendPushNotification({
            token: token,
            title: "🚗 Driver Assigned",
            body: `Your order #${orderId} has been assigned to a driver`,
            data: {
              type: "order_status",
              orderId: String(orderId),
              status: "assigned",
              screen: "track_order",
            },
          });
        }
      }

      return { success: true };
    } catch (error) {
      console.error("❌ Send order notification error:", error);
      throw error;
    }
  }

  async sendDriverStatusNotification(driverId, isOnline) {
    try {
      if (!this.isFirebaseReady()) {
        console.warn("⚠️ Firebase not ready, skipping notification");
        return;
      }

      const driver = await User.findByPk(driverId);
      if (!driver) throw new Error("Driver not found");

      const status = isOnline ? "online" : "offline";
      const token = await this.getDriverToken(driverId);

      if (token) {
        await this.sendPushNotification({
          token: token,
          title: isOnline ? "✅ You are online" : "🔴 You are offline",
          body: `Your status has been updated to ${status}`,
          data: {
            type: "driver_status",
            driverId: String(driverId),
            status: status,
          },
        });
      }
    } catch (error) {
      console.error("❌ Send driver status notification error:", error);
    }
  }

  async sendWelcomeNotification(userId, fullName, email, role) {
    try {
      if (!this.isFirebaseReady()) {
        console.warn("⚠️ Firebase not ready, skipping welcome notification");
        return { success: false, message: "Firebase not initialized" };
      }

      const user = await User.findByPk(userId, {
        attributes: ["fcm_token", "full_name", "email"],
      });

      if (!user?.fcm_token) {
        console.log(
          `⚠️ No FCM token for user ${email}, skipping welcome notification`,
        );
        return { success: false, message: "No FCM token" };
      }

      const roleEmoji =
        role === "Driver"
          ? "🚗"
          : role === "Merchant"
            ? "🏪"
            : role === "Admin"
              ? "👑"
              : "👤";

      const result = await this.sendPushNotification({
        token: user.fcm_token,
        title: `🎉 Welcome to PickNGo, ${fullName}!`,
        body: `Your account has been created as ${role}. Start exploring now!`,
        data: {
          type: "welcome",
          userId: String(userId),
          role: role,
          screen: "home",
        },
      });

      console.log(`✅ Welcome notification sent to ${email}`);
      return result;
    } catch (error) {
      console.error("❌ Send welcome notification error:", error);
      return { success: false, message: error.message };
    }
  }

  async notifyAdminsNewUser(userId, fullName, email, role) {
    try {
      if (!this.isFirebaseReady()) {
        console.warn("⚠️ Firebase not ready, skipping admin notification");
        return { success: false, message: "Firebase not initialized" };
      }

      const adminRole = await Role.findOne({ where: { name: "Admin" } });
      if (!adminRole) {
        console.log("⚠️ Admin role not found");
        return { success: false, message: "Admin role not found" };
      }

      const adminUsers = await UserRole.findAll({
        where: { role_id: adminRole.role_id },
        include: [
          { model: User, attributes: ["user_id", "email", "fcm_token"] },
        ],
      });

      let sentCount = 0;
      for (const admin of adminUsers) {
        if (admin.User?.fcm_token) {
          await this.sendPushNotification({
            token: admin.User.fcm_token,
            title: "👤 New User Registered",
            body: `${fullName} (${email}) just joined as ${role}`,
            data: {
              type: "new_user",
              userId: String(userId),
              screen: "admin_users",
            },
          });
          sentCount++;
        }
      }

      console.log(
        `✅ Admin notifications sent to ${sentCount} admins for new user: ${email}`,
      );
      return { success: true, sentCount };
    } catch (error) {
      console.error("❌ Send admin notification error:", error);
      return { success: false, message: error.message };
    }
  }

  async sendPushNotification({ token, title, body, data = {} }) {
    if (!token) {
      console.warn("⚠️ No FCM token provided");
      return { success: false, message: "No token provided" };
    }

    if (!this.isFirebaseReady()) {
      console.warn("⚠️ Firebase not ready, skipping push notification");
      return { success: false, message: "Firebase not initialized" };
    }

    try {
      const message = {
        token: token,
        notification: {
          title: title,
          body: body,
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          ...Object.fromEntries(
            Object.entries(data).map(([key, value]) => [key, String(value)]),
          ),
        },
        android: {
          priority: "high",
          notification: {
            sound: "default",
            priority: "max",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
        webpush: {
          headers: {
            Urgency: "high",
          },
          notification: {
            icon: "/icons/Icon-192.png",
            badge: "/icons/badge-72x72.png",
          },
        },
      };

      const response = await admin.messaging().send(message);
      console.log("✅ Notification sent:", response);
      return { success: true, message: "Notification sent", response };
    } catch (error) {
      console.error("❌ Send push notification error:", error.message);
      return { success: false, message: error.message };
    }
  }

  async getDriverToken(driverId) {
    try {
      const profile = await DriverProfile.findOne({
        where: { user_id: driverId },
        attributes: ["fcm_token"],
      });
      return profile?.fcm_token || null;
    } catch (error) {
      console.error("❌ Get driver token error:", error);
      return null;
    }
  }

  async getCustomerToken(customerId) {
    try {
      const user = await User.findByPk(customerId, {
        attributes: ["fcm_token"],
      });
      return user?.fcm_token || null;
    } catch (error) {
      console.error("❌ Get customer token error:", error);
      return null;
    }
  }

  async registerToken(userId, token) {
    try {
      await User.update({ fcm_token: token }, { where: { user_id: userId } });
      console.log(`✅ FCM Token registered for user ${userId}`);
      return { success: true };
    } catch (error) {
      console.error("❌ Register token error:", error);
      throw error;
    }
  }
}

let instance;
try {
  instance = new NotificationService();
} catch (error) {
  console.error("❌ Failed to create NotificationService instance:", error);
  instance = {
    isFirebaseReady: () => false,
    sendPushNotification: async () => ({
      success: false,
      message: "Service unavailable",
    }),
    sendLowRatingNotification: async () => ({ success: false }),
    sendExcellentRatingNotification: async () => ({ success: false }),
    sendNewRatingNotification: async () => ({ success: false }),
  };
}

module.exports = instance;