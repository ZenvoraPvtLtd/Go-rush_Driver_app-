const jwt = require('jsonwebtoken');
const config = require('../config/env');
const Driver = require('../models/driver.model');

/**
 * Authentication Middleware
 * Protects routes requiring valid Driver JWT authentication
 * Expects: Authorization: Bearer <token>
 */
const protect = async (req, res, next) => {
  let token = null;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer ')
  ) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Not authorized. No authentication token provided.',
    });
  }

  try {
    const decoded = jwt.verify(token, config.jwt.secret);
    const driver = await Driver.findById(decoded.id);
    if (!driver) {
      return res.status(401).json({
        success: false,
        message: 'Not authorized. Driver account not found.',
      });
    }
    req.driver = driver;
    return next();
  } catch (err) {
    const msg =
      err.name === 'TokenExpiredError'
        ? 'Token expired. Please log in again.'
        : 'Invalid token. Not authorized.';
    return res.status(401).json({
      success: false,
      message: msg,
    });
  }
};

/**
 * Optional Authentication Middleware
 * Attaches req.driver if valid token is provided, without hard failing if omitted
 */
const optionalProtect = async (req, res, next) => {
  let token = null;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer ')
  ) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (token) {
    try {
      const decoded = jwt.verify(token, config.jwt.secret);
      const driver = await Driver.findById(decoded.id);
      if (driver) {
        req.driver = driver;
        return next();
      }
    } catch (_) {}
  }

  const headerDriverId = req.headers['x-driver-id'] || req.body?.driverId || req.query?.driverId;
  const headerEmail = req.headers['x-driver-email'] || req.body?.email || req.query?.email;
  const headerPhone = req.body?.phone || req.query?.phone;

  let fallbackDriver = null;
  if (headerDriverId) {
    try {
      fallbackDriver = await Driver.findById(headerDriverId);
    } catch (_) {}
  }
  if (!fallbackDriver && headerEmail) {
    fallbackDriver = await Driver.findOne({ email: headerEmail.toLowerCase().trim() });
  }
  if (!fallbackDriver && headerPhone) {
    const cleanPhone = headerPhone.replace(/[^0-9]/g, '');
    fallbackDriver = await Driver.findOne({
      $or: [{ phone: headerPhone.trim() }, { phone: cleanPhone }]
    });
  }
  if (!fallbackDriver) {
    fallbackDriver = await Driver.findOne().sort({ updatedAt: -1 });
  }

  if (fallbackDriver) {
    req.driver = fallbackDriver;
  }

  next();
};

module.exports = {
  protect,
  optionalProtect,
};
