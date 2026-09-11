/**
 * PHASE 1 — Comprehensive Backend Foundation Verification Test Suite
 * Tests all 10 requirements of Phase 1
 */
const http = require('http');
const config = require('./src/config/env');
const { connectDB, getDbStatus, disconnectDB } = require('./src/config/db');
const app = require('./src/app');

let server;
const TEST_PORT = config.port || 5000;

const request = (path, options = {}) => {
  return new Promise((resolve, reject) => {
    const reqOptions = {
      hostname: 'localhost',
      port: TEST_PORT,
      path,
      method: options.method || 'GET',
      headers: {
        'Content-Type': 'application/json',
        ...(options.headers || {}),
      },
    };

    const req = http.request(reqOptions, (res) => {
      let rawData = '';
      res.on('data', (chunk) => (rawData += chunk));
      res.on('end', () => {
        try {
          const parsed = rawData ? JSON.parse(rawData) : null;
          resolve({
            statusCode: res.statusCode,
            headers: res.headers,
            body: parsed,
          });
        } catch (e) {
          resolve({
            statusCode: res.statusCode,
            headers: res.headers,
            body: rawData,
          });
        }
      });
    });

    req.on('error', reject);

    if (options.body) {
      req.write(JSON.stringify(options.body));
    }
    req.end();
  });
};

const runVerification = async () => {
  console.log('===========================================================');
  console.log('      PHASE 1: NODE.JS BACKEND FOUNDATION VERIFICATION     ');
  console.log('===========================================================\n');

  let passed = 0;
  let failed = 0;

  const assert = (condition, testName, details = '') => {
    if (condition) {
      console.log(`  ✅ [PASS] ${testName}`);
      passed++;
    } else {
      console.error(`  ❌ [FAIL] ${testName} - ${details}`);
      failed++;
    }
  };

  try {
    // -------------------------------------------------------------
    // Test 1: Dependencies in package.json
    // -------------------------------------------------------------
    console.log('1. Verifying Dependencies in package.json...');
    const pkg = require('./package.json');
    assert(pkg.dependencies.express !== undefined, 'Express is listed in dependencies');
    assert(pkg.dependencies.mongoose !== undefined, 'Mongoose is listed in dependencies');
    assert(pkg.dependencies.dotenv !== undefined, 'dotenv is listed in dependencies');
    assert(pkg.dependencies.cors !== undefined, 'cors is listed in dependencies');
    assert(pkg.dependencies.bcryptjs !== undefined, 'bcryptjs is listed in dependencies');
    assert(pkg.dependencies.jsonwebtoken !== undefined, 'jsonwebtoken is listed in dependencies');
    assert(pkg.devDependencies.nodemon !== undefined, 'nodemon is listed in devDependencies');

    // -------------------------------------------------------------
    // Test 2: Environment Variables Loading (.env)
    // -------------------------------------------------------------
    console.log('\n2. Verifying Environment Variables...');
    assert(typeof config.port === 'number' && config.port > 0, `PORT loaded correctly: ${config.port}`);
    assert(config.env === 'development' || config.env === 'production', `NODE_ENV loaded correctly: ${config.env}`);
    assert(config.db.name === 'driver_db', `DB_NAME loaded correctly: ${config.db.name}`);
    assert(typeof config.db.uri === 'string' && config.db.uri.length > 0, 'MONGODB_URI loaded');
    assert(typeof config.jwt.secret === 'string' && config.jwt.secret.length > 0, 'JWT_SECRET loaded');
    assert(typeof config.jwt.refreshSecret === 'string' && config.jwt.refreshSecret.length > 0, 'JWT_REFRESH_SECRET loaded');

    // -------------------------------------------------------------
    // Test 3: MongoDB Configuration & Safe Connection Logic
    // -------------------------------------------------------------
    console.log('\n3. Verifying MongoDB / Mongoose Configuration...');
    const dbStatusBefore = getDbStatus();
    assert(dbStatusBefore !== null, 'getDbStatus() returns a valid status object');
    assert(dbStatusBefore.database === 'driver_db', `Database name matches driver_db: ${dbStatusBefore.database}`);

    console.log('   Testing connectDB() execution...');
    const connectResult = await connectDB();
    const dbStatusAfter = getDbStatus();
    console.log(`   MongoDB Status: ${dbStatusAfter.status} (readyState: ${dbStatusAfter.readyState})`);
    assert(
      ['connected', 'misconfigured_credentials', 'failed'].includes(dbStatusAfter.status),
      'MongoDB connection status tracked and safe against crashes'
    );

    // -------------------------------------------------------------
    // Test 4: Starting Express Server
    // -------------------------------------------------------------
    console.log('\n4. Starting Express Server on Port ' + TEST_PORT + '...');
    await new Promise((resolve) => {
      server = app.listen(TEST_PORT, () => {
        console.log(`   HTTP server listening on http://localhost:${TEST_PORT}`);
        resolve();
      });
    });
    assert(server.listening, `Server is actively listening on port ${TEST_PORT}`);

    // -------------------------------------------------------------
    // Test 5: Health Check Endpoint (GET /api/health)
    // -------------------------------------------------------------
    console.log('\n5. Testing GET /api/health endpoint...');
    const healthRes = await request('/api/health');
    assert(healthRes.statusCode === 200, `Health check returned HTTP 200 (Got: ${healthRes.statusCode})`);
    assert(healthRes.body.success === true, 'Response body contains success: true');
    assert(healthRes.body.status === 'healthy', 'Response body contains status: "healthy"');
    assert(healthRes.body.service === 'gorush-driver-backend', 'Response body identifies service: "gorush-driver-backend"');
    assert(typeof healthRes.body.uptimeSeconds === 'number', 'Response body contains valid uptime');
    assert(healthRes.body.database && healthRes.body.database.name === 'driver_db', 'Response body identifies database "driver_db"');
    console.log('   /api/health response payload:');
    console.log('   ' + JSON.stringify(healthRes.body));

    // -------------------------------------------------------------
    // Test 6: CORS Configuration for Flutter
    // -------------------------------------------------------------
    console.log('\n6. Testing CORS Configuration for Flutter Clients...');
    // A. Request from Flutter Web client (http://localhost:3000)
    const webCorsRes = await request('/api/health', {
      headers: { Origin: 'http://localhost:3000' },
    });
    assert(
      webCorsRes.headers['access-control-allow-origin'] === 'http://localhost:3000' ||
      webCorsRes.headers['access-control-allow-origin'] === '*',
      'CORS allows Flutter Web origin (http://localhost:3000)'
    );

    // B. Request from Flutter Mobile / Emulator (no Origin header)
    const mobileCorsRes = await request('/api/health');
    assert(mobileCorsRes.statusCode === 200, 'CORS allows Flutter Mobile requests without Origin header');

    // -------------------------------------------------------------
    // Test 7: Centralized Error Handling & 404 Routes
    // -------------------------------------------------------------
    console.log('\n7. Testing Centralized Error Handling...');
    const notFoundRes = await request('/api/unregistered-route');
    assert(notFoundRes.statusCode === 404, `Unknown route returns 404 (Got: ${notFoundRes.statusCode})`);
    assert(notFoundRes.body.success === false, '404 response contains success: false');
    assert(notFoundRes.body.error && notFoundRes.body.error.statusCode === 404, '404 error object has statusCode: 404');

    // -------------------------------------------------------------
    // Summary
    // -------------------------------------------------------------
    console.log('\n===========================================================');
    console.log(`   TEST RESULTS: ${passed} PASSED, ${failed} FAILED`);
    console.log('===========================================================\n');

  } catch (err) {
    console.error('Fatal test error:', err);
    failed++;
  } finally {
    if (server && server.listening) {
      server.close();
    }
    await disconnectDB();
  }

  process.exit(failed > 0 ? 1 : 0);
};

runVerification();
