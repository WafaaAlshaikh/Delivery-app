// src/services/otpService.js
const { Op } = require('sequelize');
const { Otp } = require('../models');
require('dotenv').config();

const OTP_LENGTH = parseInt(process.env.OTP_LENGTH) || 6;
const OTP_EXPIRY_MINUTES = parseInt(process.env.OTP_EXPIRY_MINUTES) || 15;

// ============================================
// 📌 GENERATE OTP
// ============================================
const generateOTP = (length = OTP_LENGTH) => {
  let otp = '';
  for (let i = 0; i < length; i++) {
    otp += Math.floor(Math.random() * 10).toString();
  }
  return otp;
};

// ============================================
// 📌 GENERATE TEMPORARY TOKEN
// ============================================
const generateTempToken = (data, secret = process.env.JWT_SECRET, expiryMinutes = OTP_EXPIRY_MINUTES) => {
  const jwt = require('jsonwebtoken');
  return jwt.sign(
    { ...data, temp: true },
    secret,
    { expiresIn: `${expiryMinutes}m` }
  );
};

// ============================================
// 📌 STORE OTP
// ============================================
const storeOTP = async (email, otp, type = 'Verification', tempToken = null, metadata = {}) => {
  // Mark old OTPs as used
  await Otp.update(
    { is_used: true },
    {
      where: {
        email,
        type,
        is_used: false,
        expires_at: { [Op.gt]: new Date() }
      }
    }
  );

  const expiresAt = new Date(Date.now() + OTP_EXPIRY_MINUTES * 60 * 1000);

  const otpRecord = await Otp.create({
    email,
    otp_code: otp,
    type,
    temp_token: tempToken,
    expires_at: expiresAt,
    is_used: false,
    attempts: 0,
    ip_address: metadata.ip || null,
    user_agent: metadata.userAgent || null
  });

  return otpRecord;
};

// ============================================
// 📌 VERIFY OTP
// ============================================
const verifyOTP = async (email, otp, type = 'Verification', markUsed = true) => {
  try {
    const otpRecord = await Otp.findOne({
      where: {
        email,
        otp_code: otp,
        type,
        is_used: false,
        expires_at: { [Op.gt]: new Date() }
      }
    });

    if (!otpRecord) {
      return {
        valid: false,
        message: 'Invalid or expired OTP'
      };
    }

    if (otpRecord.attempts >= 5) {
      await otpRecord.update({ is_used: true });
      return {
        valid: false,
        message: 'Too many failed attempts. Please request a new OTP.'
      };
    }

    if (markUsed) {
      await otpRecord.update({ 
        is_used: true,
        attempts: otpRecord.attempts + 1
      });
    } else {
      await otpRecord.update({ 
        attempts: otpRecord.attempts + 1
      });
    }

    return {
      valid: true,
      message: 'OTP verified successfully',
      data: otpRecord.temp_token ? { tempToken: otpRecord.temp_token } : null
    };

  } catch (error) {
    console.error('OTP verification error:', error);
    return {
      valid: false,
      message: 'Error verifying OTP'
    };
  }
};

// ============================================
// 📌 DELETE OTP
// ============================================
const deleteOTP = async (email, type = null) => {
  const where = { email };
  if (type) {
    where.type = type;
  }
  return await Otp.destroy({ where });
};

// ============================================
// 📌 CLEAN EXPIRED OTPs
// ============================================
const cleanExpiredOTPs = async () => {
  return await Otp.destroy({
    where: {
      expires_at: { [Op.lt]: new Date() }
    }
  });
};

// ============================================
// 📌 CHECK IF CAN REQUEST OTP
// ============================================
const canRequestOTP = async (email, type = 'Verification', cooldownMinutes = 1) => {
  const recentOTP = await Otp.findOne({
    where: {
      email,
      type,
      is_used: false,
      created_at: { 
        [Op.gt]: new Date(Date.now() - cooldownMinutes * 60 * 1000) 
      }
    }
  });

  if (recentOTP) {
    return {
      allowed: false,
      message: `Please wait ${cooldownMinutes} minute(s) before requesting a new OTP`
    };
  }

  return {
    allowed: true,
    message: 'OK to request OTP'
  };
};

module.exports = {
  generateOTP,
  generateTempToken,
  storeOTP,
  verifyOTP,
  deleteOTP,
  cleanExpiredOTPs,
  canRequestOTP,
  OTP_LENGTH,
  OTP_EXPIRY_MINUTES
};