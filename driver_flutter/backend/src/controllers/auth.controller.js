const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');
const config = require('../config/env');
const Driver = require('../models/driver.model');

/**
 * Generate JWT token for an authenticated driver
 * Uses existing JWT_SECRET and JWT_EXPIRES_IN from environment
 */
const generateToken = (driverId, email) => {
  return jwt.sign(
    { id: driverId, email },
    config.jwt.secret,
    { expiresIn: config.jwt.expiresIn || '7d' }
  );
};

/**
 * Email format validation helper
 */
const isValidEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

/**
 * @route   POST /api/auth/register
 * @desc    Register a new driver partner
 * @access  Public
 */
const register = async (req, res, next) => {
  try {
    const {
      name,
      phone,
      email,
      password,
      licenseNumber,
      profileImage,
      vehicleId,
      status,
    } = req.body;

    // 1. Validate required fields
    if (!name || !name.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Driver name is required',
      });
    }

    if (!phone || !phone.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Phone number is required',
      });
    }

    if (!email || !email.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Email address is required',
      });
    }

    if (!password) {
      return res.status(400).json({
        success: false,
        message: 'Password is required',
      });
    }

    // 2. Validate email format
    const normalizedEmail = email.toLowerCase().trim();
    if (!isValidEmail(normalizedEmail)) {
      return res.status(400).json({
        success: false,
        message: 'Please provide a valid email address',
      });
    }

    // 3. Validate password length
    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 6 characters long',
      });
    }

    // 4. Verify MongoDB connection state
    if (mongoose.connection.readyState !== 1) {
      return res.status(503).json({
        success: false,
        message: 'Database service is currently unavailable. Please check MongoDB Atlas connection and IP whitelist.',
      });
    }

    const normalizedPhone = phone.trim();

    // 5. Check if email already registered
    const existingEmail = await Driver.findOne({ email: normalizedEmail });
    if (existingEmail) {
      return res.status(409).json({
        success: false,
        message: 'Email is already registered',
      });
    }

    // 6. Check if phone already registered
    const existingPhone = await Driver.findOne({ phone: normalizedPhone });
    if (existingPhone) {
      return res.status(409).json({
        success: false,
        message: 'Phone number is already registered',
      });
    }

    // 7. Create driver record in MongoDB drivers collection
    const newDriver = await Driver.create({
      name: name.trim(),
      phone: normalizedPhone,
      email: normalizedEmail,
      password,
      licenseNumber: licenseNumber ? licenseNumber.trim() : null,
      profileImage: profileImage ? profileImage.trim() : null,
      vehicleId: vehicleId ? vehicleId.trim() : null,
      status: status || 'offline',
    });

    // 8. Format success response matching expected specification
    return res.status(201).json({
      success: true,
      message: 'Driver registered successfully',
      data: {
        driver: newDriver.toSafeObject(),
      },
    });
  } catch (err) {
    // Handle MongoDB duplicate key collision safety (code 11000)
    if (err.code === 11000) {
      const field = Object.keys(err.keyValue || {})[0] || 'field';
      return res.status(409).json({
        success: false,
        message: `${field === 'email' ? 'Email' : field === 'phone' ? 'Phone number' : field} is already registered`,
      });
    }

    if (err.name === 'ValidationError') {
      const firstMessage = Object.values(err.errors)[0]?.message || 'Validation Error';
      return res.status(400).json({
        success: false,
        message: firstMessage,
      });
    }

    next(err);
  }
};

/**
 * @route   POST /api/auth/login
 * @desc    Driver login & JWT token generation
 * @access  Public
 */
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    // 1. Validate required fields
    if (!email || !email.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Email is required',
      });
    }

    if (!password) {
      return res.status(400).json({
        success: false,
        message: 'Password is required',
      });
    }

    // 2. Verify MongoDB connection state
    if (mongoose.connection.readyState !== 1) {
      return res.status(503).json({
        success: false,
        message: 'Database service is currently unavailable. Please check MongoDB Atlas connection and IP whitelist.',
      });
    }

    const normalizedEmail = email.toLowerCase().trim();

    // 3. Find driver by email, explicitly including password field for check
    const driver = await Driver.findOne({ email: normalizedEmail }).select('+password');

    // 4. Verify credentials safely without revealing if email exists
    if (!driver) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    const isMatch = await driver.matchPassword(password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    // 5. Handle account status (suspended or inactive accounts)
    if (driver.status === 'suspended' || driver.status === 'inactive') {
      return res.status(403).json({
        success: false,
        message: 'Account is inactive or suspended. Please contact support.',
      });
    }

    // 6. Generate JWT token using existing secret and expiration
    const token = generateToken(driver._id, driver.email);

    // 7. Return JWT token and safe driver information
    return res.status(200).json({
      success: true,
      message: 'Login successful',
      data: {
        token,
        driver: driver.toSafeObject(),
      },
    });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  register,
  login,
};
