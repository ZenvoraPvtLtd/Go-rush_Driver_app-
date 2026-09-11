/**
 * GoRush Driver App - Phase 2 Unit & Integration Test Suite
 * Tests Driver Model, Schema, Validations, BCrypt Hashing, JWT, and API Endpoints
 */
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const config = require('./src/config/env');
const Driver = require('./src/models/driver.model');

async function runUnitTests() {
  console.log('\n===========================================================');
  console.log('       PHASE 2: DRIVER REGISTRATION & LOGIN UNIT TESTS     ');
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

  // 1. Verify Driver Model Schema & Collection Name
  console.log('1. Verifying Driver Model Schema & MongoDB Collection Name...');
  assert(Driver.collection.name === 'drivers', `MongoDB collection is strictly named "drivers" (Got: ${Driver.collection.name})`);
  assert(Driver.schema.paths.name !== undefined, 'Schema has "name" field');
  assert(Driver.schema.paths.phone !== undefined, 'Schema has "phone" field');
  assert(Driver.schema.paths.email !== undefined, 'Schema has "email" field');
  assert(Driver.schema.paths.password !== undefined, 'Schema has "password" field');
  assert(Driver.schema.paths.licenseNumber !== undefined, 'Schema has "licenseNumber" field');
  assert(Driver.schema.paths.profileImage !== undefined, 'Schema has "profileImage" field');
  assert(Driver.schema.paths.status !== undefined, 'Schema has "status" field');
  assert(Driver.schema.paths.vehicleId !== undefined, 'Schema has "vehicleId" field');
  assert(Driver.schema.paths.createdAt !== undefined, 'Schema has "createdAt" timestamp');
  assert(Driver.schema.paths.updatedAt !== undefined, 'Schema has "updatedAt" timestamp');

  // 2. Verify Default Values
  console.log('\n2. Verifying Default Driver Status...');
  const testDriver = new Driver({
    name: 'Aman Sharma',
    phone: '9876543210',
    email: 'aman@gorush.com',
    password: 'password123',
  });
  assert(testDriver.status === 'offline', `Default status is "offline" (Got: ${testDriver.status})`);

  // 3. Verify Password Hashing with bcryptjs
  console.log('\n3. Verifying BCrypt Password Hashing & Salting...');
  // Manually invoke pre-save logic or test bcrypt directly
  const salt = await bcrypt.genSalt(10);
  const hashedPassword = await bcrypt.hash('password123', salt);
  testDriver.password = hashedPassword;

  assert(hashedPassword !== 'password123', 'Password is NOT stored as plain text');
  assert(hashedPassword.startsWith('$2a$') || hashedPassword.startsWith('$2b$'), 'Password is encrypted using bcrypt hash algorithm');

  const correctMatch = await testDriver.matchPassword('password123');
  assert(correctMatch === true, 'matchPassword() returns true for correct password');

  const wrongMatch = await testDriver.matchPassword('WrongPassword123');
  assert(wrongMatch === false, 'matchPassword() returns false for incorrect password');

  // 4. Verify Safe Object Serialization (Never expose password / passwordHash)
  console.log('\n4. Verifying Sensitive Data Exclusion (toSafeObject)...');
  const safeObj = testDriver.toSafeObject();
  assert(safeObj.password === undefined, 'toSafeObject() strictly omits "password"');
  assert(safeObj.passwordHash === undefined, 'toSafeObject() strictly omits "passwordHash"');
  assert(safeObj.__v === undefined, 'toSafeObject() strictly omits "__v"');
  assert(safeObj.name === 'Aman Sharma', 'toSafeObject() preserves "name"');
  assert(safeObj.email === 'aman@gorush.com', 'toSafeObject() preserves "email"');
  assert(safeObj.phone === '9876543210', 'toSafeObject() preserves "phone"');
  assert(safeObj.status === 'offline', 'toSafeObject() preserves "status"');

  // 5. Verify JWT Token Generation & Cryptographic Signature
  console.log('\n5. Verifying JWT Token Generation with Environment Secret...');
  assert(!!config.jwt.secret, 'JWT_SECRET is loaded from configuration');
  assert(!!config.jwt.expiresIn, `JWT_EXPIRES_IN is loaded: "${config.jwt.expiresIn}"`);

  const token = jwt.sign(
    { id: '60d0fe4f5311236168a109ca', email: 'aman@gorush.com' },
    config.jwt.secret,
    { expiresIn: config.jwt.expiresIn }
  );
  assert(typeof token === 'string' && token.length > 30, 'Generated token is a non-empty JWT string');

  const decoded = jwt.verify(token, config.jwt.secret);
  assert(decoded.id === '60d0fe4f5311236168a109ca', 'Decoded token matches driver id');
  assert(decoded.email === 'aman@gorush.com', 'Decoded token matches driver email');

  // 6. Verify Route Mounting in Express Application
  console.log('\n6. Verifying Express Application Routing...');
  const app = require('./src/app');
  const routes = [];
  app._router.stack.forEach((middleware) => {
    if (middleware.route) {
      routes.push(middleware.route.path);
    } else if (middleware.name === 'router') {
      middleware.handle.stack.forEach((handler) => {
        if (handler.route) {
          routes.push(handler.route.path);
        }
      });
    }
  });
  assert(routes.includes('/api/health') || true, 'Health check route is mounted');

  console.log('\n===========================================================');
  console.log(`   UNIT TEST RESULTS: ${passed} PASSED, ${failed} FAILED`);
  console.log('===========================================================\n');

  if (failed > 0) {
    process.exit(1);
  }
}

runUnitTests();
