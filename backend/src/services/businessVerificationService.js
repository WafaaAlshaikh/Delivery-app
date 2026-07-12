// src/services/businessVerificationService.js

const { Business, User } = require('../models');
const { sendEmail } = require('./emailService');

class BusinessVerificationService {

  static async checkAutoApproval(business) {
    const checks = {
      hasBasicInfo: false,
      hasValidContact: false,
      hasValidLocation: false,
      hasValidCategory: false,
    };

    if (business.name && business.name.trim().length >= 2 &&
        business.description && business.description.trim().length > 0) {
      checks.hasBasicInfo = true;
    }

    if (business.phone && /^[0-9+\-\s()]{10,15}$/.test(business.phone)) {
      checks.hasValidContact = true;
    }

    if (business.address && business.city && business.region &&
        business.latitude !== null && business.longitude !== null) {
      checks.hasValidLocation = true;
    }

    if (business.category_id) {
      checks.hasValidCategory = true;
    }

    const allPassed = Object.values(checks).every((check) => check === true);

    return {
      passed: allPassed,
      checks,
      details: { ...checks },
    };
  }

  static async processAutoApproval(businessId) {
    try {
      const business = await Business.findByPk(businessId, {
        include: [{ model: User, attributes: ['user_id', 'full_name', 'email', 'phone'] }],
      });

      if (!business) {
        throw new Error('Business not found');
      }

      if (business.verification_status !== 'Pending' &&
          business.verification_status !== 'Unverified') {
        return {
          success: false,
          message: `Business verification status is ${business.verification_status}, cannot auto-approve`,
        };
      }

      const verification = await this.checkAutoApproval(business);

      if (verification.passed) {
        await business.update({
          status: 'Active',
          verification_status: 'Verified',
          rejection_reason: null,
        });

        await this.sendApprovalNotification(business.User, business);
        await this.notifyAdminsOfNewBusiness(business);

        return {
          success: true,
          message: 'Business automatically approved',
          data: business,
          verificationDetails: verification.details,
        };
      }

      await this.notifyAdminsOfIncompleteProfile(business, verification.details);

      return {
        success: false,
        message: 'Business profile incomplete',
        data: business,
        missingChecks: verification.details,
      };
    } catch (error) {
      console.error('❌ Business auto-approval error:', error);
      throw error;
    }
  }

  static async sendApprovalNotification(user, business) {
    const subject = '🎉 Your store has been approved!';
    const text = `
      Hello ${user.full_name},

      Great news! Your store "${business.name}" has been automatically approved.

      You can now:
      ✅ Add products to your store
      ✅ Start receiving orders
      ✅ Manage your storefront from the app

      Best regards,
      Delivery App Team
    `;

    await sendEmail(user.email, subject, text);
  }

  static async notifyAdminsOfNewBusiness(business) {
    const { UserRole, Role, User } = require('../models');

    const adminRole = await Role.findOne({ where: { name: 'Admin' } });
    if (!adminRole) return;

    const adminUsers = await UserRole.findAll({
      where: { role_id: adminRole.role_id },
      include: [{ model: User, attributes: ['user_id', 'email', 'full_name'] }],
    });

    const subject = '🏬 New Store Auto-Approved';
    const text = `
      Hello Admin,

      A new store has been automatically approved:

      📋 Store Details:
      - Name: ${business.name}
      - Owner: ${business.User.full_name} (${business.User.email})
      - Phone: ${business.phone}
      - Category ID: ${business.category_id}

      The store is now active and visible to customers.

      Best regards,
      Delivery App System
    `;

    for (const admin of adminUsers) {
      await sendEmail(admin.User.email, subject, text);
    }
  }

  static async notifyAdminsOfIncompleteProfile(business, missingChecks) {
    const { UserRole, Role, User } = require('../models');

    const adminRole = await Role.findOne({ where: { name: 'Admin' } });
    if (!adminRole) return;

    const adminUsers = await UserRole.findAll({
      where: { role_id: adminRole.role_id },
      include: [{ model: User, attributes: ['user_id', 'email', 'full_name'] }],
    });

    const missingFields = [];
    if (!missingChecks.hasBasicInfo) missingFields.push('Basic Information (name/description)');
    if (!missingChecks.hasValidContact) missingFields.push('Valid Phone Number');
    if (!missingChecks.hasValidLocation) missingFields.push('Complete Location (address/city/region/coordinates)');
    if (!missingChecks.hasValidCategory) missingFields.push('Valid Category');

    const subject = '⚠️ Incomplete Store Profile - Needs Review';
    const text = `
      Hello Admin,

      A store has been submitted with an incomplete profile:

      📋 Store Details:
      - Name: ${business.name}
      - Owner: ${business.User.full_name} (${business.User.email})

      ❌ Missing Requirements:
      ${missingFields.map((f) => `  - ${f}`).join('\n')}

      Please review this store manually from the admin panel.

      Best regards,
      Delivery App System
    `;

    for (const admin of adminUsers) {
      await sendEmail(admin.User.email, subject, text);
    }
  }

  static async adminReview(businessId, action, notes = '') {
    try {
      const business = await Business.findByPk(businessId, {
        include: [{ model: User, attributes: ['user_id', 'full_name', 'email'] }],
      });
      if (!business) {
        throw new Error('Business not found');
      }

      if (action === 'approve') {
        await business.update({
          status: 'Active',
          verification_status: 'Verified',
          rejection_reason: null,
        });

        await this.sendApprovalNotification(business.User, business);

        return { success: true, message: 'Store manually approved', data: business };
      }

      if (action === 'reject') {
        await business.update({
          status: 'Suspended',
          verification_status: 'Rejected',
          rejection_reason: notes,
        });

        await this.sendRejectionNotification(business.User, business, notes);

        return { success: true, message: 'Store rejected', data: business };
      }

      throw new Error('Invalid action');
    } catch (error) {
      console.error('❌ Admin review error:', error);
      throw error;
    }
  }

  static async sendRejectionNotification(user, business, reason) {
    const subject = 'Store Application Status Update';
    const text = `
      Hello ${user.full_name},

      We regret to inform you that your store "${business.name}" was not approved at this time.

      Reason: ${reason || 'Not specified'}

      You can update your store details and resubmit for review.

      Best regards,
      Delivery App Team
    `;

    await sendEmail(user.email, subject, text);
  }
}

module.exports = BusinessVerificationService;