// src/controllers/authController.js
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { Op } = require('sequelize');
const { User, Otp, Role, UserRole,DriverProfile,Order } = require('../models');
const { sendOTPEmail, sendWelcomeEmail } = require('../services/emailService');
const { 
  generateOTP, 
  generateTempToken, 
  storeOTP, 
  verifyOTP, 
  deleteOTP,
  canRequestOTP 
} = require('../services/otpService');
const { validateEmail, validatePassword } = require('../utils/validators');
require('dotenv').config();

const JWT_SECRET = process.env.JWT_SECRET;
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

// src/controllers/authController.js - تعديل دالة signupInitial

const signupInitial = async (req, res) => {
  const { 
    full_name, 
    email, 
    password, 
    phone, 
    role = 'Customer',
    businessType // ✅ جديد - نوع المركبة للـ Driver أو نوع النشاط للـ Merchant
  } = req.body;

  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('📥 [SIGNUP INITIAL] Received signup request');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('👤 User Data:');
  console.log(`   ├─ full_name: ${full_name}`);
  console.log(`   ├─ email: ${email}`);
  console.log(`   ├─ role: ${role}`);
  console.log(`   ├─ businessType: ${businessType || 'Not provided'}`);
  console.log(`   └─ phone: ${phone || 'Not provided'}`);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  try {
    // ✅ Validation
    if (!full_name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Full name, email, and password are required'
      });
    }

    if (!validateEmail(email)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid email format'
      });
    }

    if (!validatePassword(password)) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 6 characters long'
      });
    }

    // ✅ Check if role exists in database
    const roleRecord = await Role.findOne({ 
      where: { name: role } 
    });
    
    if (!roleRecord) {
      return res.status(400).json({
        success: false,
        message: `Invalid role. Please choose from: Admin, Merchant, Driver, Customer, Support`
      });
    }

    // ✅ Check if email already registered
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Email already registered. Please login or use a different email.'
      });
    }

    // ✅ Check OTP cooldown
    const canRequest = await canRequestOTP(email, 'Verification', 1);
    if (!canRequest.allowed) {
      return res.status(429).json({
        success: false,
        message: canRequest.message
      });
    }

    // ✅ Generate OTP
    const otp = generateOTP();
    console.log(`🔑 Generated OTP for ${email}: ${otp}`);

    // ✅ Store temp data - ✅ حفظ businessType
    const tempData = {
      full_name,
      email,
      password,
      phone: phone || null,
      role,
      businessType: businessType || null // ✅ حفظ businessType
    };

    const tempToken = generateTempToken(tempData, JWT_SECRET);

    // ✅ Store OTP
    await storeOTP(
      email,
      otp,
      'Verification',
      tempToken,
      {
        ip: req.ip || req.connection.remoteAddress,
        userAgent: req.headers['user-agent']
      }
    );

    // ✅ Send OTP email
    await sendOTPEmail(email, otp, 'Verification');

    console.log(`✅ OTP sent successfully to ${email}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      message: 'OTP sent successfully to your email. Please verify to complete registration.',
      tempToken,
      expiresIn: `${process.env.OTP_EXPIRY_MINUTES || 15} minutes`
    });

  } catch (error) {
    console.error('❌ Signup initial error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during signup. Please try again.'
    });
  }
};



// ============================================
// 📌 RESEND OTP
// ============================================
const resendOTP = async (req, res) => {
  const { email } = req.body;
  const tempToken = req.headers.authorization?.split(' ')[1];

  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('📥 [RESEND OTP] Resending OTP');
  console.log(`   ├─ email: ${email}`);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  try {
    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Email is required'
      });
    }

    if (!tempToken) {
      return res.status(400).json({
        success: false,
        message: 'Temporary token is required'
      });
    }

    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Email already registered. Please login.'
      });
    }

    let tempData;
    try {
      tempData = jwt.verify(tempToken, JWT_SECRET);
    } catch (error) {
      return res.status(400).json({
        success: false,
        message: 'Invalid or expired temporary token. Please start signup again.'
      });
    }

    if (tempData.email !== email) {
      return res.status(400).json({
        success: false,
        message: 'Email mismatch. Please start signup again.'
      });
    }

    const canRequest = await canRequestOTP(email, 'Verification', 1);
    if (!canRequest.allowed) {
      return res.status(429).json({
        success: false,
        message: canRequest.message
      });
    }

    await deleteOTP(email, 'Verification');

    const otp = generateOTP();
    console.log(`🔑 New OTP for ${email}: ${otp}`);

    await storeOTP(
      email,
      otp,
      'Verification',
      tempToken,
      {
        ip: req.ip || req.connection.remoteAddress,
        userAgent: req.headers['user-agent']
      }
    );

    await sendOTPEmail(email, otp, 'Verification');

    console.log(`✅ OTP resent successfully to ${email}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      message: 'New OTP sent successfully to your email',
      expiresIn: `${process.env.OTP_EXPIRY_MINUTES || 15} minutes`
    });

  } catch (error) {
    console.error('❌ Resend OTP error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error. Please try again.'
    });
  }
};

// ============================================
// 📌 LOGIN
// ============================================
const login = async (req, res) => {
  const { email, password } = req.body;

  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('📥 [LOGIN] Login attempt');
  console.log(`   ├─ email: ${email}`);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  try {
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email and password are required'
      });
    }

    const user = await User.findOne({ 
      where: { email }
    });

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    if (!user.is_active) {
      return res.status(403).json({
        success: false,
        message: 'Your account has been deactivated. Please contact support.'
      });
    }

    if (!user.is_verified) {
      // Send new OTP for verification
      const otp = generateOTP();
      const tempData = { email: user.email, user_id: user.user_id };
      const tempToken = generateTempToken(tempData, JWT_SECRET, 15);

      await storeOTP(
        user.email,
        otp,
        'Verification',
        tempToken,
        {
          ip: req.ip || req.connection.remoteAddress,
          userAgent: req.headers['user-agent']
        }
      );

      await sendOTPEmail(user.email, otp, 'Verification');

      return res.status(200).json({
        success: false,
        requireVerification: true,
        message: 'Account not verified. OTP sent to your email.',
        tempToken,
        expiresIn: '15 minutes'
      });
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    // ✅ Update last login
    await user.update({ last_login: new Date() });

    // ✅ Get user roles
    const userRoles = await UserRole.findAll({
      where: { user_id: user.user_id },
      include: [{ model: Role, attributes: ['name'] }]
    });
    const roles = userRoles.map(ur => ur.Role.name);

    // ✅ Generate JWT
    const token = jwt.sign(
      { 
        user_id: user.user_id, 
        email: user.email,
        roles: roles
      },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );

    console.log(`✅ User logged in: ${user.email} (${roles.join(', ')})`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      message: 'Login successful',
      token,
      user: {
        user_id: user.user_id,
        full_name: user.full_name,
        email: user.email,
        phone: user.phone,
        roles: roles,
        is_verified: user.is_verified,
        profile_image: user.profile_image
      }
    });

  } catch (error) {
    console.error('❌ Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during login. Please try again.'
    });
  }
};

// ============================================
// 📌 FORGOT PASSWORD
// ============================================
const forgotPassword = async (req, res) => {
  const { email } = req.body;

  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('📥 [FORGOT PASSWORD] Request received');
  console.log(`   ├─ email: ${email}`);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  try {
    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Email is required'
      });
    }

    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(200).json({
        success: true,
        message: 'If your email is registered, you will receive a password reset OTP.'
      });
    }

    const canRequest = await canRequestOTP(email, 'ResetPassword', 1);
    if (!canRequest.allowed) {
      return res.status(429).json({
        success: false,
        message: canRequest.message
      });
    }

    await deleteOTP(email, 'ResetPassword');

    const otp = generateOTP();
    console.log(`🔑 Password reset OTP for ${email}: ${otp}`);

    await storeOTP(
      email,
      otp,
      'ResetPassword',
      null,
      {
        ip: req.ip || req.connection.remoteAddress,
        userAgent: req.headers['user-agent']
      }
    );

    await sendOTPEmail(email, otp, 'ResetPassword');

    console.log(`✅ Password reset OTP sent to ${email}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      message: 'Password reset OTP sent to your email',
      expiresIn: `${process.env.OTP_EXPIRY_MINUTES || 15} minutes`
    });

  } catch (error) {
    console.error('❌ Forgot password error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error. Please try again.'
    });
  }
};

// ============================================
// 📌 RESET PASSWORD
// ============================================
const resetPassword = async (req, res) => {
  const { email, otp, new_password } = req.body;

  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('📥 [RESET PASSWORD] Request received');
  console.log(`   ├─ email: ${email}`);
  console.log(`   └─ otp: ${otp}`);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  try {
    if (!email || !otp || !new_password) {
      return res.status(400).json({
        success: false,
        message: 'Email, OTP, and new password are required'
      });
    }

    if (!validatePassword(new_password)) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 6 characters long'
      });
    }

    const verification = await verifyOTP(email, otp, 'ResetPassword', true);
    if (!verification.valid) {
      return res.status(400).json({
        success: false,
        message: verification.message
      });
    }

    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const hashedPassword = await bcrypt.hash(new_password, 10);

    await user.update({ 
      password_hash: hashedPassword
    });

    await deleteOTP(email, 'ResetPassword');

    console.log(`✅ Password reset successful for ${email}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      message: 'Password reset successful. You can now login with your new password.'
    });

  } catch (error) {
    console.error('❌ Reset password error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error. Please try again.'
    });
  }
};

// ============================================
// 📌 VERIFY OTP ONLY
// ============================================
const verifyOTPOnly = async (req, res) => {
  const { email, otp, type = 'Verification' } = req.body;

  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('📥 [VERIFY OTP] Verifying OTP');
  console.log(`   ├─ email: ${email}`);
  console.log(`   └─ type: ${type}`);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  try {
    if (!email || !otp) {
      return res.status(400).json({
        success: false,
        message: 'Email and OTP are required'
      });
    }

    const verification = await verifyOTP(email, otp, type, true);
    if (!verification.valid) {
      return res.status(400).json({
        success: false,
        message: verification.message
      });
    }

    if (type === 'Verification') {
      const user = await User.findOne({ where: { email } });
      if (user) {
        await user.update({ is_verified: true });
        console.log(`✅ User verified: ${email}`);
      }
    }

    console.log(`✅ OTP verified successfully for ${email}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(200).json({
      success: true,
      message: 'OTP verified successfully'
    });

  } catch (error) {
    console.error('❌ Verify OTP error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error. Please try again.'
    });
  }
};

// ============================================
// 📌 LOGOUT
// ============================================
const logout = async (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Logged out successfully'
  });
};

// ============================================
// 📌 GET PROFILE
// ============================================
const getProfile = async (req, res) => {
  try {
    const user = await User.findByPk(req.user.user_id, {
      attributes: { exclude: ['password_hash'] }
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // ✅ Get user roles
    const userRoles = await UserRole.findAll({
      where: { user_id: user.user_id },
      include: [{ model: Role, attributes: ['name'] }]
    });
    const roles = userRoles.map(ur => ur.Role.name);

    res.status(200).json({
      success: true,
      user: {
        user_id: user.user_id,
        full_name: user.full_name,
        email: user.email,
        phone: user.phone,
        roles: roles,
        is_verified: user.is_verified,
        is_active: user.is_active,
        profile_image: user.profile_image,
        gender: user.gender,
        birth_date: user.birth_date,
        last_login: user.last_login,
        created_at: user.created_at
      }
    });

  } catch (error) {
    console.error('❌ Get profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

// ============================================
// 📌 UPDATE PROFILE
// ============================================
const updateProfile = async (req, res) => {
  const { full_name, phone, profile_image, gender, birth_date } = req.body;

  try {
    const user = await User.findByPk(req.user.user_id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    await user.update({
      full_name: full_name || user.full_name,
      phone: phone || user.phone,
      profile_image: profile_image || user.profile_image,
      gender: gender || user.gender,
      birth_date: birth_date || user.birth_date
    });

    // ✅ Get user roles
    const userRoles = await UserRole.findAll({
      where: { user_id: user.user_id },
      include: [{ model: Role, attributes: ['name'] }]
    });
    const roles = userRoles.map(ur => ur.Role.name);

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      user: {
        user_id: user.user_id,
        full_name: user.full_name,
        email: user.email,
        phone: user.phone,
        roles: roles,
        profile_image: user.profile_image,
        gender: user.gender,
        birth_date: user.birth_date
      }
    });

  } catch (error) {
    console.error('❌ Update profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

// ============================================
// 📌 ADMIN - GET ALL USERS
// ============================================
const getAllUsers = async (req, res) => {
  try {
    const users = await User.findAll({
      attributes: { exclude: ['password_hash'] },
      order: [['created_at', 'DESC']]
    });

    // ✅ Get roles for each user
    const usersWithRoles = await Promise.all(users.map(async (user) => {
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

    res.json({
      success: true,
      users: usersWithRoles
    });

  } catch (error) {
    console.error('❌ Error fetching users:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};



const verifySignup = async (req, res) => {
  const { email, otp } = req.body;
  const tempToken = req.headers.authorization?.split(' ')[1];

  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('📥 [VERIFY SIGNUP] Verifying OTP');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log(`   ├─ email: ${email}`);
  console.log(`   └─ otp: ${otp}`);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  try {
    if (!email || !otp) {
      return res.status(400).json({
        success: false,
        message: 'Email and OTP are required'
      });
    }

    if (!tempToken) {
      return res.status(400).json({
        success: false,
        message: 'Temporary token is required'
      });
    }

    // ✅ Verify OTP
    const verification = await verifyOTP(email, otp, 'Verification', true);
    if (!verification.valid) {
      return res.status(400).json({
        success: false,
        message: verification.message
      });
    }

    // ✅ Decode temp token
    let tempData;
    try {
      tempData = jwt.verify(tempToken, JWT_SECRET);
    } catch (error) {
      return res.status(400).json({
        success: false,
        message: 'Invalid or expired temporary token. Please start signup again.'
      });
    }

    if (tempData.email !== email) {
      return res.status(400).json({
        success: false,
        message: 'Email mismatch. Please start signup again.'
      });
    }

    // ✅ Check if user already exists
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Email already registered. Please login.'
      });
    }

    // ✅ Hash password
    const hashedPassword = await bcrypt.hash(tempData.password, 10);

    // ✅ Create user
    const user = await User.create({
      full_name: tempData.full_name,
      email: tempData.email,
      password_hash: hashedPassword,
      phone: tempData.phone,
      is_verified: true,
      is_active: true
    });

    // ✅ Assign role to user
    const roleRecord = await Role.findOne({ 
      where: { name: tempData.role || 'Customer' } 
    });
    
    if (roleRecord) {
      await UserRole.create({
        user_id: user.user_id,
        role_id: roleRecord.role_id,
        assigned_at: new Date()
      });
    } else {
      // Fallback: assign Customer role
      const customerRole = await Role.findOne({ where: { name: 'Customer' } });
      if (customerRole) {
        await UserRole.create({
          user_id: user.user_id,
          role_id: customerRole.role_id,
          assigned_at: new Date()
        });
      }
    }

    // ✅ ✅ ✅ NEW: Create DriverProfile if role is Driver
    if (tempData.role === 'Driver' && tempData.businessType) {
      try {
        await DriverProfile.create({
          user_id: user.user_id,
          vehicle_type: tempData.businessType, // من DriverTypeScreen
          status: 'Pending' // يحتاج موافقة Admin
        });
        console.log(`✅ DriverProfile created for ${user.email} with vehicle: ${tempData.businessType}`);
      } catch (driverError) {
        console.error('⚠️ Failed to create DriverProfile:', driverError);
        // لا نوقف التسجيل إذا فشل إنشاء DriverProfile
      }
    }

    // ✅ Delete OTP
    await deleteOTP(email, 'Verification');

    // ✅ Send welcome email
    await sendWelcomeEmail(user.email, user.full_name, tempData.role);

    // ✅ Get user roles
    const userRoles = await UserRole.findAll({
      where: { user_id: user.user_id },
      include: [{ model: Role, attributes: ['name'] }]
    });
    const roles = userRoles.map(ur => ur.Role.name);

    // ✅ Generate JWT
    const token = jwt.sign(
      { 
        user_id: user.user_id, 
        email: user.email,
        roles: roles
      },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );

    console.log(`✅ User created successfully: ${user.email} (${roles.join(', ')})`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    res.status(201).json({
      success: true,
      message: 'Account created successfully',
      token,
      user: {
        user_id: user.user_id,
        full_name: user.full_name,
        email: user.email,
        phone: user.phone,
        roles: roles,
        is_verified: user.is_verified,
        profile_image: user.profile_image
      }
    });

  } catch (error) {
    console.error('❌ Verify signup error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during verification. Please try again.'
    });
  }
};

// ✅ ✅ ✅ NEW: Get Driver Profile
const getDriverProfile = async (req, res) => {
  try {
    const driverProfile = await DriverProfile.findOne({
      where: { user_id: req.user.user_id }
    });

    if (!driverProfile) {
      return res.status(404).json({
        success: false,
        message: 'Driver profile not found'
      });
    }

    res.status(200).json({
      success: true,
      data: driverProfile
    });
  } catch (error) {
    console.error('❌ Get driver profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching driver profile'
    });
  }
};

// ✅ ✅ ✅ NEW: Update Driver Profile
const updateDriverProfile = async (req, res) => {
  try {
    const {
      vehicle_type,
      vehicle_plate,
      vehicle_color,
      vehicle_model,
      license_number
    } = req.body;

    const driverProfile = await DriverProfile.findOne({
      where: { user_id: req.user.user_id }
    });

    if (!driverProfile) {
      return res.status(404).json({
        success: false,
        message: 'Driver profile not found'
      });
    }

    await driverProfile.update({
      vehicle_type: vehicle_type || driverProfile.vehicle_type,
      vehicle_plate: vehicle_plate || driverProfile.vehicle_plate,
      vehicle_color: vehicle_color || driverProfile.vehicle_color,
      vehicle_model: vehicle_model || driverProfile.vehicle_model,
      license_number: license_number || driverProfile.license_number
    });

    res.status(200).json({
      success: true,
      message: 'Driver profile updated successfully',
      data: driverProfile
    });
  } catch (error) {
    console.error('❌ Update driver profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error updating driver profile'
    });
  }
};

// ✅ ✅ ✅ NEW: Toggle Driver Online Status
const toggleDriverOnline = async (req, res) => {
  try {
    const { is_online } = req.body;
    const { latitude, longitude } = req.body;

    const driverProfile = await DriverProfile.findOne({
      where: { user_id: req.user.user_id }
    });

    if (!driverProfile) {
      return res.status(404).json({
        success: false,
        message: 'Driver profile not found'
      });
    }

    await driverProfile.update({
      is_online: is_online !== undefined ? is_online : !driverProfile.is_online,
      current_latitude: latitude || driverProfile.current_latitude,
      current_longitude: longitude || driverProfile.current_longitude,
      last_location_update: new Date()
    });

    res.status(200).json({
      success: true,
      message: `Driver is now ${driverProfile.is_online ? 'online' : 'offline'}`,
      data: driverProfile
    });
  } catch (error) {
    console.error('❌ Toggle driver online error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error toggling online status'
    });
  }
};

// ✅ ✅ ✅ NEW: Update Driver Location
const updateDriverLocation = async (req, res) => {
  try {
    const { latitude, longitude } = req.body;

    if (!latitude || !longitude) {
      return res.status(400).json({
        success: false,
        message: 'Latitude and longitude are required'
      });
    }

    const driverProfile = await DriverProfile.findOne({
      where: { user_id: req.user.user_id }
    });

    if (!driverProfile) {
      return res.status(404).json({
        success: false,
        message: 'Driver profile not found'
      });
    }

    await driverProfile.update({
      current_latitude: latitude,
      current_longitude: longitude,
      last_location_update: new Date()
    });

    res.status(200).json({
      success: true,
      message: 'Location updated successfully',
      data: {
        latitude: driverProfile.current_latitude,
        longitude: driverProfile.current_longitude,
        last_update: driverProfile.last_location_update
      }
    });
  } catch (error) {
    console.error('❌ Update driver location error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error updating location'
    });
  }
};

// ✅ ✅ ✅ NEW: Get Driver Stats (Earnings, Deliveries, Rating)
const getDriverStats = async (req, res) => {
  try {
    const driverProfile = await DriverProfile.findOne({
      where: { user_id: req.user.user_id }
    });

    if (!driverProfile) {
      return res.status(404).json({
        success: false,
        message: 'Driver profile not found'
      });
    }

    // ✅ Get completed deliveries count
    const completedDeliveries = await Order.count({
      where: {
        driver_id: req.user.user_id,
        status_id: 8 // Delivered
      }
    });

    // ✅ Get total earnings from delivered orders
    const earningsResult = await Order.sum('total', {
      where: {
        driver_id: req.user.user_id,
        status_id: 8 // Delivered
      }
    });

    // ✅ Get current orders
    const currentOrders = await Order.count({
      where: {
        driver_id: req.user.user_id,
        status_id: {
          [Op.between]: [2, 7] // Accepted to On The Way
        }
      }
    });

    res.status(200).json({
      success: true,
      data: {
        rating: driverProfile.rating || 0,
        total_deliveries: driverProfile.total_deliveries || completedDeliveries,
        total_earnings: earningsResult || 0,
        current_orders: currentOrders,
        is_online: driverProfile.is_online,
        status: driverProfile.status
      }
    });
  } catch (error) {
    console.error('❌ Get driver stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching driver stats'
    });
  }
};

// ============================================
// 📌 EXPORT - إضافة الدوال الجديدة
// ============================================
module.exports = {
  signupInitial,
  verifySignup,
  resendOTP,
  login,
  forgotPassword,
  resetPassword,
  verifyOTPOnly,
  logout,
  getProfile,
  updateProfile,
  getAllUsers,
  getDriverProfile,
  updateDriverProfile,
  toggleDriverOnline,
  updateDriverLocation,
  getDriverStats
};