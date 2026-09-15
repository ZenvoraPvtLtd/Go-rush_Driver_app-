const mongoose = require('mongoose');
const config = require('./env');

let connectionStatus = 'disconnected';

/**
 * Connect to MongoDB database
 */
const connectDB = async () => {
  const uri = config.db.uri;

  // Check for unresolved placeholder password in Atlas URI
  if (uri.includes('<db_password>') || uri.includes('<password>')) {
    connectionStatus = 'misconfigured_credentials';
    console.warn(
      '\n⚠️ [MongoDB] Notice: Atlas connection string contains <db_password> placeholder.'
    );
    console.warn(
      '⚠️ [MongoDB] Please update your actual database password in .env to connect to MongoDB Atlas.\n'
    );
    return false;
  }

  let isConnecting = false;
  const attemptConnect = async () => {
    if (isConnecting || mongoose.connection.readyState === 1) return true;
    try {
      isConnecting = true;
      connectionStatus = 'connecting';
      const conn = await mongoose.connect(uri, {
        dbName: config.db.name,
        serverSelectionTimeoutMS: 5000,
        connectTimeoutMS: 10000,
      });

      connectionStatus = 'connected';
      console.log(`✅ [MongoDB] Connected successfully to host: ${conn.connection.host}`);
      console.log(`📁 [MongoDB] Active Database: ${conn.connection.name}`);
      return true;
    } catch (error) {
      connectionStatus = 'failed';
      console.error(`❌ [MongoDB] Connection Error: ${error.message}`);
      return false;
    } finally {
      isConnecting = false;
    }
  };

  const initialSuccess = await attemptConnect();

  // Continually monitor connection and auto-reconnect if lost or IP is pending
  setInterval(async () => {
    if (mongoose.connection.readyState !== 1 && connectionStatus !== 'misconfigured_credentials') {
      await attemptConnect();
    }
  }, 4000);

  return initialSuccess;
};

// Monitor connection events
mongoose.connection.on('connected', () => {
  connectionStatus = 'connected';
});

mongoose.connection.on('error', (err) => {
  connectionStatus = 'error';
  console.error(`⚠️ [MongoDB] Runtime connection error: ${err.message}`);
});

mongoose.connection.on('disconnected', () => {
  if (connectionStatus !== 'misconfigured_credentials') {
    connectionStatus = 'disconnected';
    console.warn('⚠️ [MongoDB] Disconnected from database. Auto-reconnect active...');
  }
});

/**
 * Get current MongoDB connection status
 */
const getDbStatus = () => {
  const readyStates = {
    0: 'disconnected',
    1: 'connected',
    2: 'connecting',
    3: 'disconnecting',
  };

  const stateFromMongoose = readyStates[mongoose.connection.readyState] || 'unknown';

  return {
    status: connectionStatus === 'connected' ? 'connected' : connectionStatus,
    readyState: stateFromMongoose,
    database: mongoose.connection.name || config.db.name,
    host: mongoose.connection.host || null,
  };
};

/**
 * Gracefully disconnect from database
 */
const disconnectDB = async () => {
  try {
    await mongoose.disconnect();
    connectionStatus = 'disconnected';
    console.log('🛑 [MongoDB] Connection closed gracefully.');
  } catch (err) {
    console.error(`Error disconnecting MongoDB: ${err.message}`);
  }
};

module.exports = {
  connectDB,
  getDbStatus,
  disconnectDB,
};
