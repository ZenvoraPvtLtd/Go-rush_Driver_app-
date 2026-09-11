const config = require('../config/env');
const { getDbStatus } = require('../config/db');

/**
 * Health check endpoint controller
 * GET /api/health
 */
const getHealth = (req, res) => {
  const dbStatus = getDbStatus();

  res.status(200).json({
    success: true,
    service: 'gorush-driver-backend',
    status: 'healthy',
    message: 'GoRush Driver Backend Foundation is running smoothly',
    environment: config.env,
    timestamp: new Date().toISOString(),
    uptimeSeconds: Math.floor(process.uptime()),
    database: {
      name: config.db.name,
      connection: dbStatus.status,
      readyState: dbStatus.readyState,
    },
  });
};

module.exports = {
  getHealth,
};
