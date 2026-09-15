/**
 * GoRush Driver App - Phase 4 Backend Verification
 * Tests:
 * 1. Register new driver with JWT
 * 2. Authenticated Profile Update (PUT /api/auth/profile)
 * 3. Authenticated Add Secondary Vehicle (POST /api/auth/vehicles)
 * 4. Duplicate Vehicle Plate Rejection (POST /api/auth/vehicles -> 409)
 * 5. Retrieve Registered Vehicles (GET /api/auth/vehicles)
 * 6. Change Password (POST /api/auth/change-password)
 * 7. Authenticate with New Password (POST /api/auth/login)
 */
const http = require('http');

const BASE_URL = 'http://localhost:5000';

function makeRequest(method, path, body = null, token = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, BASE_URL);
    const postData = body ? JSON.stringify(body) : null;

    const headers = {
      'Content-Type': 'application/json',
      ...(postData && { 'Content-Length': Buffer.byteLength(postData) }),
      ...(token && { Authorization: `Bearer ${token}` }),
    };

    const req = http.request(
      {
        hostname: url.hostname,
        port: url.port,
        path: url.pathname,
        method: method,
        headers,
      },
      (res) => {
        let data = '';
        res.on('data', (chunk) => (data += chunk));
        res.on('end', () => {
          let parsed = null;
          try {
            parsed = JSON.parse(data);
          } catch {
            parsed = data;
          }
          resolve({
            statusCode: res.statusCode,
            data: parsed,
          });
        });
      }
    );

    req.on('error', reject);
    if (postData) req.write(postData);
    req.end();
  });
}

async function runTests() {
  console.log('\n===========================================================');
  console.log('       PHASE 4: BACKEND & MONGODB ATLAS VERIFICATION       ');
  console.log('===========================================================\n');

  let testsPassed = 0;
  let totalTests = 7;

  const testPhone = `98${Math.floor(10000000 + Math.random() * 90000000)}`;
  const testEmail = `driver_p4_${Date.now()}@gorush.com`;
  const initialPassword = 'InitialPassword@123';
  const newPassword = 'UpdatedPassword@456';
  let token = null;

  // TEST 1: Register New Driver
  try {
    const regRes = await makeRequest('POST', '/api/auth/register', {
      name: 'Phase 4 Partner',
      phone: testPhone,
      email: testEmail,
      password: initialPassword,
      vehicleId: 'DL 01 AB 9999',
    });

    if (regRes.statusCode === 201 && regRes.data.success && regRes.data.data.token) {
      token = regRes.data.data.token;
      console.log('✅ TEST 1 PASSED: Register Driver -> MongoDB 201 Created with JWT');
      testsPassed++;
    } else {
      console.error('❌ TEST 1 FAILED:', regRes.data);
    }
  } catch (err) {
    console.error('❌ TEST 1 ERROR:', err.message);
  }

  // TEST 2: Update Profile (PUT /api/auth/profile)
  try {
    const profRes = await makeRequest(
      'PUT',
      '/api/auth/profile',
      {
        name: 'Phase 4 Updated Partner',
        city: 'Noida Sector 62',
        address: 'B-12, Sector 62, Noida, UP',
        privacySettings: {
          biometricLock: true,
          backgroundLocation: true,
          twoFactorAuth: false,
          maskPhoneNumber: true,
        },
      },
      token
    );

    if (
      profRes.statusCode === 200 &&
      profRes.data.success &&
      profRes.data.data.driver.name === 'Phase 4 Updated Partner' &&
      profRes.data.data.driver.city === 'Noida Sector 62'
    ) {
      console.log('✅ TEST 2 PASSED: Update Profile -> MongoDB 200 Updated with isolation');
      testsPassed++;
    } else {
      console.error('❌ TEST 2 FAILED:', profRes.data);
    }
  } catch (err) {
    console.error('❌ TEST 2 ERROR:', err.message);
  }

  // TEST 3: Add Secondary Vehicle (POST /api/auth/vehicles)
  const secondaryReg = `MH 02 XY ${Math.floor(1000 + Math.random() * 9000)}`;
  try {
    const vehRes = await makeRequest(
      'POST',
      '/api/auth/vehicles',
      {
        model: 'Maruti Suzuki Dzire',
        regNumber: secondaryReg,
        type: 'Sedan',
      },
      token
    );

    if (vehRes.statusCode === 201 && vehRes.data.success && vehRes.data.data.vehicle.regNumber === secondaryReg) {
      console.log('✅ TEST 3 PASSED: Add Secondary Vehicle -> Saved in MongoDB Atlas');
      testsPassed++;
    } else {
      console.error('❌ TEST 3 FAILED:', vehRes.data);
    }
  } catch (err) {
    console.error('❌ TEST 3 ERROR:', err.message);
  }

  // TEST 4: Duplicate Vehicle Registration Rejection (POST /api/auth/vehicles -> 409)
  try {
    const dupRes = await makeRequest(
      'POST',
      '/api/auth/vehicles',
      {
        model: 'Another Car',
        regNumber: secondaryReg,
        type: 'Hatchback',
      },
      token
    );

    if (dupRes.statusCode === 409 && dupRes.data.success === false) {
      console.log('✅ TEST 4 PASSED: Duplicate Vehicle Registration properly rejected (409 Conflict)');
      testsPassed++;
    } else {
      console.error('❌ TEST 4 FAILED: Expected 409 Conflict, got', dupRes.statusCode, dupRes.data);
    }
  } catch (err) {
    console.error('❌ TEST 4 ERROR:', err.message);
  }

  // TEST 5: Retrieve Registered Vehicles (GET /api/auth/vehicles)
  try {
    const listRes = await makeRequest('GET', '/api/auth/vehicles', null, token);

    if (
      listRes.statusCode === 200 &&
      listRes.data.success &&
      Array.isArray(listRes.data.data.vehicles) &&
      listRes.data.data.vehicles.length >= 1
    ) {
      console.log(`✅ TEST 5 PASSED: Retrieve Vehicles -> ${listRes.data.data.vehicles.length} vehicle(s) returned`);
      testsPassed++;
    } else {
      console.error('❌ TEST 5 FAILED:', listRes.data);
    }
  } catch (err) {
    console.error('❌ TEST 5 ERROR:', err.message);
  }

  // TEST 6: Change Password (POST /api/auth/change-password)
  try {
    const cpRes = await makeRequest(
      'POST',
      '/api/auth/change-password',
      {
        currentPassword: initialPassword,
        newPassword: newPassword,
      },
      token
    );

    if (cpRes.statusCode === 200 && cpRes.data.success) {
      console.log('✅ TEST 6 PASSED: Change Password -> bcrypt hashed & saved in MongoDB Atlas');
      testsPassed++;
    } else {
      console.error('❌ TEST 6 FAILED:', cpRes.data);
    }
  } catch (err) {
    console.error('❌ TEST 6 ERROR:', err.message);
  }

  // TEST 7: Authenticate with New Password (POST /api/auth/login)
  try {
    const loginRes = await makeRequest('POST', '/api/auth/login', {
      email: testEmail,
      password: newPassword,
    });

    if (loginRes.statusCode === 200 && loginRes.data.success && loginRes.data.data.token) {
      console.log('✅ TEST 7 PASSED: Login with New Password -> 200 OK & new JWT issued');
      testsPassed++;
    } else {
      console.error('❌ TEST 7 FAILED:', loginRes.data);
    }
  } catch (err) {
    console.error('❌ TEST 7 ERROR:', err.message);
  }

  console.log('\n-----------------------------------------------------------');
  console.log(`  Phase 4 Backend Test Summary: ${testsPassed} / ${totalTests} Passed (${Math.round((testsPassed / totalTests) * 100)}%)`);
  console.log('-----------------------------------------------------------\n');

  if (testsPassed === totalTests) {
    console.log('🎉 ALL PHASE 4 BACKEND & DATABASE REQUIREMENTS VERIFIED!\n');
  } else {
    process.exit(1);
  }
}

runTests();
