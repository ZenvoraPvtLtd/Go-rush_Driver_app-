const express = require('express');
const router = express.Router();
const healthRoutes = require('./health.routes');
const authRoutes = require('./auth.routes');
const rideRoutes = require('./ride.routes');
const driverRoutes = require('./driver.routes');

// Mount health check route: GET /api/health
router.use('/health', healthRoutes);

// Mount authentication routes: POST /api/auth/register, POST /api/auth/login
router.use('/auth', authRoutes);

// Mount rides routes: /api/rides/...
router.use('/rides', rideRoutes);

// Mount driver routes: /api/driver/...
router.use('/driver', driverRoutes);

// Backward-compatible v1 aliases
router.use('/v1/rides', rideRoutes);
router.use('/v1/driver', driverRoutes);
router.use('/v1/auth', authRoutes);

// Root API welcome info
router.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Welcome to GoRush Driver Partner REST API',
    version: '1.0.0',
    endpoints: {
      health: 'GET /api/health',
      register: 'POST /api/auth/register',
      login: 'POST /api/auth/login',
      rides: '/api/rides',
      driver: '/api/driver',
    },
  });
});

module.exports = router;

