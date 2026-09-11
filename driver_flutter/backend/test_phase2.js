/**
 * GoRush Driver App - Phase 2 Verification & Test Runner
 * Tests Driver Registration & Login APIs, Validations, JWT, and Security
 */
const http = require('http');
const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const config = require('./src/config/env');
const Driver = require('./src/models/driver.model');

const BASE_URL = `http://localhost:${config.port}`;

function makeRequest(method, path, body = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, BASE_URL);
    const postData = body ? JSON.stringify(body) : null;

    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname,
      method: method,
      headers: {
        'Content-Type': 'application/json',
        ...(postData && { 'Content-Length': Buffer.byteLength(postData) }),
      },
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        let parsed = null;
        try {
          parsed = JSON.parse(data);
        } catch {
          parsed = data;
        }
        resolve({
          statusCode: res.statusCode,
          headers: res.headers,
          data: parsed,
        });
      });
    });

    req.on('error', reject);

    if (postData) {
      req.write(postData);
    }
    req.end();
  });
}

async function runTests() {
  console.log('\n===========================================================');
  console.log('       PHASE 2: DRIVER REGISTRATION & LOGIN API TESTS      ');
  console.log('===========================================================\n');

  let passed = 0;
  let failed = 0;

  function assert(condition, message) {
    if (condition) {
      console.log(`  ✅ [PASS] ${message}`);
      passed++;
    } else {
      console.error(`  ❌ [FAIL] ${message}`);
      failed++;
    }
  }

  const testId = Date.now();
  const testEmail = `driver_${testId}@testgorush.com`;
  const testPhone = `98${Math.floor(10000000 + Math.random() * 90000000)}`;
  const testPassword = 'SecurePassword123!';

  try {
    // 1. Verify GET /api/health
    console.log('1. Verifying Server Health & MongoDB Connection...');
    const healthRes = await makeRequest('GET', '/api/health');
    assert(healthRes.statusCode === 200, `Health check returned HTTP 200 (Got: ${healthRes.statusCode})`);
    assert(healthRes.data?.success === true, 'Health check response has success: true');
    assert(healthRes.data?.database?.readyState === 'connected', `MongoDB is connected (Got: ${healthRes.data?.database?.readyState})`);

    // 2. Test Registration - Validation: Missing name
    console.log('\n2. Testing Validation Errors on Registration...');
    const noNameRes = await makeRequest('POST', '/api/auth/register', {
      phone: testPhone,
      email: testEmail,
      password: testPassword,
    });
    assert(noNameRes.statusCode === 400, `Missing name returns 400 (Got: ${noNameRes.statusCode})`);
    assert(noNameRes.data?.success === false, 'Error response has success: false');

    // 3. Test Registration - Validation: Invalid email format
    const badEmailRes = await makeRequest('POST', '/api/auth/register', {
      name: 'Test Driver',
      phone: testPhone,
      email: 'not-an-email',
      password: testPassword,
    });
    assert(badEmailRes.statusCode === 400, `Invalid email returns 400 (Got: ${badEmailRes.statusCode})`);

    // 4. Test Registration - Validation: Password too short
    const shortPassRes = await makeRequest('POST', '/api/auth/register', {
      name: 'Test Driver',
      phone: testPhone,
      email: testEmail,
      password: '123',
    });
    assert(shortPassRes.statusCode === 400, `Short password returns 400 (Got: ${shortPassRes.statusCode})`);

    // 5. Test Registration - Success
    console.log('\n3. Testing Successful Driver Registration (POST /api/auth/register)...');
    const regPayload = {
      name: 'Ramesh Kumar',
      phone: testPhone,
      email: testEmail,
      password: testPassword,
      licenseNumber: 'DL1420110012345',
      profileImage: 'https://storage.gorush.com/drivers/avatar1.jpg',
      vehicleId: 'VEH-9921',
    };

    const regRes = await makeRequest('POST', '/api/auth/register', regPayload);
    assert(regRes.statusCode === 201, `Driver registration returns HTTP 201 Created (Got: ${regRes.statusCode})`);
    assert(regRes.data?.success === true, 'Registration response contains success: true');
    assert(regRes.data?.message === 'Driver registered successfully', `Message matches spec: "${regRes.data?.message}"`);

    const driverData = regRes.data?.data?.driver;
    assert(!!driverData?._id, 'Driver record has generated _id');
    assert(driverData?.name === 'Ramesh Kumar', `Driver name matches: "${driverData?.name}"`);
    assert(driverData?.email === testEmail.toLowerCase(), `Driver email matches: "${driverData?.email}"`);
    assert(driverData?.phone === testPhone, `Driver phone matches: "${driverData?.phone}"`);
    assert(driverData?.status === 'offline', `Driver default status is offline: "${driverData?.status}"`);
    assert(driverData?.licenseNumber === 'DL1420110012345', 'Driver licenseNumber matches');
    assert(driverData?.vehicleId === 'VEH-9921', 'Driver vehicleId matches');
    assert(!!driverData?.createdAt, 'Driver has createdAt timestamp');
    assert(!!driverData?.updatedAt, 'Driver has updatedAt timestamp');

    // Security assertions on registration response
    assert(driverData?.password === undefined, 'Driver response does NOT expose password field');
    assert(driverData?.passwordHash === undefined, 'Driver response does NOT expose passwordHash');
    assert(driverData?.__v === undefined, 'Driver response does NOT expose __v');

    // 6. Test Duplicate Registration - Duplicate Email
    console.log('\n4. Testing Duplicate Conflict Handling (HTTP 409)...');
    const dupEmailRes = await makeRequest('POST', '/api/auth/register', {
      name: 'Another Driver',
      phone: `98${Math.floor(10000000 + Math.random() * 90000000)}`,
      email: testEmail,
      password: 'password999',
    });
    assert(dupEmailRes.statusCode === 409, `Duplicate email returns HTTP 409 Conflict (Got: ${dupEmailRes.statusCode})`);
    assert(dupEmailRes.data?.success === false, 'Duplicate response has success: false');

    // 7. Test Duplicate Registration - Duplicate Phone
    const dupPhoneRes = await makeRequest('POST', '/api/auth/register', {
      name: 'Another Driver',
      phone: testPhone,
      email: `another_${testId}@testgorush.com`,
      password: 'password999',
    });
    assert(dupPhoneRes.statusCode === 409, `Duplicate phone returns HTTP 409 Conflict (Got: ${dupPhoneRes.statusCode})`);

    // 8. Test Login - Incorrect Password
    console.log('\n5. Testing Driver Login (POST /api/auth/login)...');
    const badPassLogin = await makeRequest('POST', '/api/auth/login', {
      email: testEmail,
      password: 'WrongPassword!',
    });
    assert(badPassLogin.statusCode === 401, `Incorrect password returns HTTP 401 (Got: ${badPassLogin.statusCode})`);
    assert(badPassLogin.data?.message === 'Invalid email or password', 'Safe error message returned without disclosing user existence');

    // 9. Test Login - Non-existent Email
    const nonExistLogin = await makeRequest('POST', '/api/auth/login', {
      email: 'nobody@nowhere99823.com',
      password: testPassword,
    });
    assert(nonExistLogin.statusCode === 401, `Non-existent email returns HTTP 401 (Got: ${nonExistLogin.statusCode})`);
    assert(nonExistLogin.data?.message === 'Invalid email or password', 'Safe error message returned for unknown email');

    // 10. Test Login - Missing fields
    const missingLogin = await makeRequest('POST', '/api/auth/login', {
      email: testEmail,
    });
    assert(missingLogin.statusCode === 400, `Missing password returns HTTP 400 (Got: ${missingLogin.statusCode})`);

    // 11. Test Login - Success
    const goodLogin = await makeRequest('POST', '/api/auth/login', {
      email: testEmail,
      password: testPassword,
    });
    assert(goodLogin.statusCode === 200, `Valid login returns HTTP 200 OK (Got: ${goodLogin.statusCode})`);
    assert(goodLogin.data?.success === true, 'Login response contains success: true');
    assert(goodLogin.data?.message === 'Login successful', `Login message is: "${goodLogin.data?.message}"`);

    const loginData = goodLogin.data?.data;
    assert(typeof loginData?.token === 'string' && loginData.token.length > 20, 'JWT token returned in login response');
    assert(loginData?.driver?.email === testEmail.toLowerCase(), 'Driver profile included in login response');
    assert(loginData?.driver?.password === undefined, 'Driver login does NOT expose password');

    // 12. Security Verification of JWT Token
    console.log('\n6. Verifying JWT Token Authenticity & Cryptography...');
    const decoded = jwt.verify(loginData.token, config.jwt.secret);
    assert(decoded.id === driverData._id, 'JWT payload contains correct driver ID');
    assert(decoded.email === testEmail.toLowerCase(), 'JWT payload contains correct driver email');

    // 13. Verify Database-level Storage in drivers collection
    console.log('\n7. Verifying MongoDB Record Security in drivers Collection...');
    if (mongoose.connection.readyState !== 1) {
      await mongoose.connect(config.db.uri, { dbName: config.db.name });
    }
    const dbRecord = await Driver.findOne({ email: testEmail.toLowerCase() }).select('+password');
    assert(!!dbRecord, 'Driver record found directly in MongoDB drivers collection');
    assert(dbRecord.password !== testPassword, 'Password in MongoDB is NOT plain text');
    assert(dbRecord.password.startsWith('$2'), 'Password in MongoDB is securely hashed with bcrypt');

    // Clean up test driver
    await Driver.deleteOne({ _id: dbRecord._id });
    console.log('   Cleaned up test record from database.');

  } catch (err) {
    console.error('Test execution error:', err);
    failed++;
  } finally {
    if (mongoose.connection.readyState === 1) {
      await mongoose.disconnect();
    }
  }

  console.log('\n===========================================================');
  console.log(`   TEST RESULTS: ${passed} PASSED, ${failed} FAILED`);
  console.log('===========================================================\n');

  if (failed > 0) {
    process.exit(1);
  }
}

runTests();
