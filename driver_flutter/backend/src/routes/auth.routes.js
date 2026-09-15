const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { protect, optionalProtect } = require('../middleware/auth.middleware');

// POST /api/auth/register - Register new driver partner
router.post('/register', authController.register);

// POST /api/auth/login - Authenticate driver & issue JWT token
router.post('/login', authController.login);

// GET /api/auth/me - Get currently authenticated driver profile (Protected)
router.get('/me', protect, authController.getProfile);

// GET /api/auth/profile - Alias for authenticated driver profile
router.get('/profile', protect, authController.getProfile);

// PUT /api/auth/profile - Update driver profile in MongoDB Atlas
router.put('/profile', optionalProtect, authController.updateProfile);

// POST /api/auth/change-password - Change password securely
router.post('/change-password', optionalProtect, authController.changePassword);

// GET /api/auth/vehicles - Get registered vehicles for driver
router.get('/vehicles', optionalProtect, authController.getVehicles);

// POST /api/auth/vehicles - Add secondary vehicle to MongoDB Atlas
router.post('/vehicles', optionalProtect, authController.addVehicle);

module.exports = router;
