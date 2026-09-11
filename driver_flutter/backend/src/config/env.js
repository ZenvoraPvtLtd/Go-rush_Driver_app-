const dotenv = require('dotenv');
const path = require('path');

// Load environment variables from .env file
dotenv.config({ path: path.resolve(__dirname, '../../.env') });

const config = {
  env: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT || '5000', 10),
  db: {
    uri: process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/driver_db',
    name: process.env.DB_NAME || 'driver_db',
  },
  jwt: {
    secret: process.env.JWT_SECRET || 'gorush_driver_jwt_secret_key_2026_dev',
    refreshSecret: process.env.JWT_REFRESH_SECRET || 'gorush_driver_refresh_secret_key_2026_dev',
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  },
  cors: {
    origin: process.env.CORS_ORIGIN || '*',
  },
};

module.exports = config;
