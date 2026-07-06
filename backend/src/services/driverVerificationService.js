// D:\Delivery\backend\src\services\driverVerificationService.js
const { DriverProfile, User } = require('../models');
const { sendEmail } = require('./emailService');
const { Op } = require('sequelize');

class DriverVerificationService {
  
  
  static async checkAutoApproval(driverProfile) {
    const checks = {
      hasBasicInfo: false,
      hasValidLicense: false,
      hasValidVehicle: false,
      hasValidExperience: true, 
      hasValidDocuments: true, 
    };

    if (driverProfile.license_number && 
        driverProfile.vehicle_type && 
        driverProfile.vehicle_plate) {
      checks.hasBasicInfo = true;
    }

    if (driverProfile.license_number && 
        driverProfile.license_number.length >= 6) {
      checks.hasValidLicense = true;
    }

    const validVehicleTypes = ['Bicycle', 'Motorcycle', 'Car', 'Van', 'Company'];
    if (driverProfile.vehicle_type && 
        validVehicleTypes.includes(driverProfile.vehicle_type)) {
      checks.hasValidVehicle = true;
    }

    const allPassed = Object.values(checks).every(check => check === true);
    
    return {
      passed: allPassed,
      checks: checks,
      details: {
        hasBasicInfo: checks.hasBasicInfo,
        hasValidLicense: checks.hasValidLicense,
        hasValidVehicle: checks.hasValidVehicle,
        hasValidExperience: checks.hasValidExperience,
        hasValidDocuments: checks.hasValidDocuments
      }
    };
  }

  
  static async processAutoApproval(profileId) {
    try {
      const driverProfile = await DriverProfile.findByPk(profileId, {
        include: [{ model: User, attributes: ['user_id', 'full_name', 'email', 'phone'] }]
      });

      if (!driverProfile) {
        throw new Error('Driver profile not found');
      }

      if (driverProfile.status !== 'Pending') {
        return {
          success: false,
          message: `Driver status is ${driverProfile.status}, cannot auto-approve`
        };
      }

      const verification = await this.checkAutoApproval(driverProfile);

      if (verification.passed) {
        await driverProfile.update({
          status: 'Active',
          approved_at: new Date(),
          auto_approved: true,
          onboarding_completed_at: new Date()
        });

        await this.sendApprovalNotification(driverProfile.User);

        await this.notifyAdminsOfNewDriver(driverProfile);

        return {
          success: true,
          message: 'Driver automatically approved',
          data: driverProfile,
          verificationDetails: verification.details
        };
      } else {
        await this.notifyAdminsOfIncompleteProfile(driverProfile, verification.details);

        return {
          success: false,
          message: 'Driver profile incomplete',
          data: driverProfile,
          missingChecks: verification.details
        };
      }

    } catch (error) {
      console.error('❌ Auto-approval error:', error);
      throw error;
    }
  }


  static async sendApprovalNotification(user) {
    const subject = '🎉 Congratulations! Your driver account is active';
    const text = `
      Hello ${user.full_name},

      Great news! Your driver profile has been automatically approved.

      You can now:
      ✅ Go online and start accepting orders
      ✅ View available deliveries in your area
      ✅ Track your earnings and performance

      To get started, open the app and toggle your status to "Online".

      Happy delivering! 🚗

      Best regards,
      Delivery App Team
    `;

    await sendEmail(user.email, subject, text);
  }


  static async notifyAdminsOfNewDriver(driverProfile) {
    const { UserRole, Role, User } = require('../models');
    
    const adminRole = await Role.findOne({ where: { name: 'Admin' } });
    if (!adminRole) return;

    const adminUsers = await UserRole.findAll({
      where: { role_id: adminRole.role_id },
      include: [{ model: User, attributes: ['user_id', 'email', 'full_name'] }]
    });

    const subject = '🚗 New Driver Auto-Approved';
    const text = `
      Hello Admin,

      A new driver has been automatically approved:

      📋 Driver Details:
      - Name: ${driverProfile.User.full_name}
      - Email: ${driverProfile.User.email}
      - Phone: ${driverProfile.User.phone || 'N/A'}
      - Vehicle: ${driverProfile.vehicle_type}
      - License: ${driverProfile.license_number || 'N/A'}

      The driver is now active and can start accepting deliveries.

      You can manage this driver from the admin panel.

      Best regards,
      Delivery App System
    `;

    for (const admin of adminUsers) {
      await sendEmail(admin.User.email, subject, text);
    }
  }


  static async notifyAdminsOfIncompleteProfile(driverProfile, missingChecks) {
    const { UserRole, Role, User } = require('../models');
    
    const adminRole = await Role.findOne({ where: { name: 'Admin' } });
    if (!adminRole) return;

    const adminUsers = await UserRole.findAll({
      where: { role_id: adminRole.role_id },
      include: [{ model: User, attributes: ['user_id', 'email', 'full_name'] }]
    });

    const missingFields = [];
    if (!missingChecks.hasBasicInfo) missingFields.push('Basic Information');
    if (!missingChecks.hasValidLicense) missingFields.push('Valid License');
    if (!missingChecks.hasValidVehicle) missingFields.push('Valid Vehicle');
    if (!missingChecks.hasValidDocuments) missingFields.push('Required Documents');

    const subject = '⚠️ Incomplete Driver Profile - Needs Review';
    const text = `
      Hello Admin,

      A driver has submitted an incomplete profile:

      📋 Driver Details:
      - Name: ${driverProfile.User.full_name}
      - Email: ${driverProfile.User.email}

      ❌ Missing Requirements:
      ${missingFields.map(f => `  - ${f}`).join('\n')}

      The driver needs to complete their profile before they can be approved.

      Please contact the driver to complete their profile.

      Best regards,
      Delivery App System
    `;

    for (const admin of adminUsers) {
      await sendEmail(admin.User.email, subject, text);
    }
  }


  static async adminReview(profileId, action, notes = '') {
    try {
      const driverProfile = await DriverProfile.findByPk(profileId);
      if (!driverProfile) {
        throw new Error('Driver profile not found');
      }

      if (action === 'approve') {
        await driverProfile.update({
          status: 'Active',
          approved_at: new Date(),
          auto_approved: false,
          admin_notes: notes,
          onboarding_completed_at: new Date()
        });

        // Send notification to driver
        // await this.sendApprovalNotification(driverProfile.User);

        return {
          success: true,
          message: 'Driver manually approved',
          data: driverProfile
        };
      } else if (action === 'reject') {
        await driverProfile.update({
          status: 'Rejected',
          admin_notes: notes,
          rejection_reason: notes
        });

        await this.sendRejectionNotification(driverProfile.User, notes);

        return {
          success: true,
          message: 'Driver rejected',
          data: driverProfile
        };
      } else if (action === 'suspend') {
        await driverProfile.update({
          status: 'Suspended',
          admin_notes: notes
        });

        return {
          success: true,
          message: 'Driver suspended',
          data: driverProfile
        };
      } else {
        throw new Error('Invalid action');
      }
    } catch (error) {
      console.error('❌ Admin review error:', error);
      throw error;
    }
  }

 
  static async sendRejectionNotification(user, reason) {
    const subject = 'Driver Application Status Update';
    const text = `
      Hello ${user.full_name},

      We regret to inform you that your driver application has been reviewed and was not approved at this time.

      Reason: ${reason || 'Not specified'}

      If you have any questions, please contact our support team.

      Best regards,
      Delivery App Team
    `;

    await sendEmail(user.email, subject, text);
  }

  
  static async getDriversByStatus(status = null) {
    const where = {};
    if (status) {
      where.status = status;
    }

    const drivers = await DriverProfile.findAll({
      where: where,
      include: [{ 
        model: User, 
        attributes: ['user_id', 'full_name', 'email', 'phone', 'is_active'] 
      }],
      order: [['created_at', 'DESC']]
    });

    return drivers;
  }


  static async getDriverStats() {
    const stats = {
      total: await DriverProfile.count(),
      pending: await DriverProfile.count({ where: { status: 'Pending' } }),
      active: await DriverProfile.count({ where: { status: 'Active' } }),
      suspended: await DriverProfile.count({ where: { status: 'Suspended' } }),
      rejected: await DriverProfile.count({ where: { status: 'Rejected' } }),
      online: await DriverProfile.count({ where: { is_online: true, status: 'Active' } }),
      avgRating: await DriverProfile.findAll({
        attributes: [
          [sequelize.fn('AVG', sequelize.col('rating')), 'avgRating']
        ],
        where: { status: 'Active' }
      })
    };

    return stats;
  }
}

module.exports = DriverVerificationService;