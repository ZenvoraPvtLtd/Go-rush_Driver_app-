const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');

// POST /api/auth/register - Register new driver partner
router.post('/register', authController.register);

// POST /api/auth/login - Authenticate driver & issue JWT token
router.post('/login', authController.login);

module.exports = router;
