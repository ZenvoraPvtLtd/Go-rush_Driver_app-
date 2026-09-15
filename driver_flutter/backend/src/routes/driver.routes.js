const express = require('express');
const router = express.Router();
const driverController = require('../controllers/driver.controller');
const { protect, optionalProtect } = require('../middleware/auth.middleware');

// PUT /api/driver/status - Toggle online/offline status
router.put('/status', optionalProtect, driverController.updateStatus);
router.patch('/status', optionalProtect, driverController.updateStatus);

// GET /api/driver/status - Get current driver status
router.get('/status', optionalProtect, driverController.getStatus);

module.exports = router;
