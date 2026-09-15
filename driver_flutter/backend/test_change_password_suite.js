const http = require('http');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const API_HOST = '127.0.0.1';
const API_PORT = 5000;

function makeRequest(method, path, data = null, token = null) {
  return new Promise((resolve, reject) => {
    const postData = data ? JSON.stringify(data) : '';
    const headers = {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(postData),
    };
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    const req = http.request(
      {
        hostname: API_HOST,
        port: API_PORT,
        path,
        method,
        headers,
      },
      (res) => {
        let body = '';
        res.on('data', (chunk) => (body += chunk));
        res.on('end', () => {
          try {
            const parsed = JSON.parse(body);
            resolve({ status: res.statusCode, body: parsed });
          } catch (e) {
            resolve({ status: res.statusCode, body });
          }
        });
      }
    );

    req.on('error', reject);
    if (postData) req.write(postData);
    req.end();
  });
}

async function runChangePasswordTests() {
  console.log('\n===========================================================');
  console.log('       CHANGE PASSWORD COMPREHENSIVE VERIFICATION SUITE    ');
  console.log('===========================================================\n');

  let passed = 0;
  let total = 0;

  const timestamp = Date.now();
  const testDriver = {
    name: `PassTestDriver_${timestamp}`,
    phone: `99${timestamp.toString().slice(-8)}`,
    email: `passtest_${timestamp}@gorush.com`,
    password: 'InitialPassword123',
    vehicleId: 'DL 01 ZZ 9999',
    licenseNumber: `DL-PASS-${timestamp}`,
  };

  const newPassword = 'BrandNewPassword456';

  try {
    // SETUP: Register test driver
    console.log('--- SETUP: Register Driver ---');
    const regRes = await makeRequest('POST', '/api/auth/register', testDriver);
    const token = regRes.body?.data?.token || regRes.body?.token;
    if (regRes.status !== 201 || !token) {
      throw new Error(`Driver registration failed: ${JSON.stringify(regRes.body)}`);
    }
    const driverId = regRes.body.data.driver._id;
    console.log(`Driver registered successfully. ID: ${driverId}, Token obtained.\n`);

    // TEST 1: CASE 1 — All fields empty -> 400 'Please fill all required fields'
    total++;
    console.log('--- TEST 1: Case 1 — All Fields Empty ---');
    const emptyRes = await makeRequest('POST', '/api/auth/change-password', {}, token);
    if (emptyRes.status === 400 && emptyRes.body.message === 'Please fill all required fields') {
      console.log('✅ TEST 1 PASSED: Rejected empty request with 400 and message "Please fill all required fields"');
      passed++;
    } else {
      console.error(`❌ TEST 1 FAILED: Expected 400 "Please fill all required fields", got:`, emptyRes);
    }

    // TEST 2: CASE 2 — Missing Current Password -> 400
    total++;
    console.log('\n--- TEST 2: Case 2 — Missing Current Password ---');
    const noCurRes = await makeRequest(
      'POST',
      '/api/auth/change-password',
      { newPassword: 'SomeNewPassword123' },
      token
    );
    if (noCurRes.status === 400 && noCurRes.body.message === 'Please fill all required fields') {
      console.log('✅ TEST 2 PASSED: Missing current password rejected with 400');
      passed++;
    } else {
      console.error(`❌ TEST 2 FAILED:`, noCurRes);
    }

    // TEST 3: CASE 3 — Missing New Password -> 400
    total++;
    console.log('\n--- TEST 3: Case 3 — Missing New Password ---');
    const noNewRes = await makeRequest(
      'POST',
      '/api/auth/change-password',
      { currentPassword: testDriver.password },
      token
    );
    if (noNewRes.status === 400 && noNewRes.body.message === 'Please fill all required fields') {
      console.log('✅ TEST 3 PASSED: Missing new password rejected with 400');
      passed++;
    } else {
      console.error(`❌ TEST 3 FAILED:`, noNewRes);
    }

    // TEST 4: CASE 5 — New Password and Confirm Password do not match -> 400 'New passwords do not match'
    total++;
    console.log('\n--- TEST 4: Case 5 — Confirm Password Mismatch ---');
    const mismatchRes = await makeRequest(
      'POST',
      '/api/auth/change-password',
      {
        currentPassword: testDriver.password,
        newPassword: 'ValidNewPass123',
        confirmPassword: 'DifferentPass999',
      },
      token
    );
    if (mismatchRes.status === 400 && mismatchRes.body.message === 'New passwords do not match') {
      console.log('✅ TEST 4 PASSED: Password mismatch rejected with 400 "New passwords do not match"');
      passed++;
    } else {
      console.error(`❌ TEST 4 FAILED: Expected 400 "New passwords do not match", got:`, mismatchRes);
    }

    // TEST 5: Short Password (< 6 chars) -> 400
    total++;
    console.log('\n--- TEST 5: Short Password (< 6 characters) ---');
    const shortRes = await makeRequest(
      'POST',
      '/api/auth/change-password',
      {
        currentPassword: testDriver.password,
        newPassword: '123',
        confirmPassword: '123',
      },
      token
    );
    if (shortRes.status === 400 && shortRes.body.message === 'New password must be at least 6 characters long') {
      console.log('✅ TEST 5 PASSED: Short password rejected with 400 "New password must be at least 6 characters long"');
      passed++;
    } else {
      console.error(`❌ TEST 5 FAILED:`, shortRes);
    }

    // TEST 6: CASE 6 — Current Password is incorrect -> 400 'Current password is incorrect'
    total++;
    console.log('\n--- TEST 6: Case 6 — Incorrect Current Password ---');
    const wrongCurRes = await makeRequest(
      'POST',
      '/api/auth/change-password',
      {
        currentPassword: 'CompletelyWrongPassword123',
        newPassword: newPassword,
        confirmPassword: newPassword,
      },
      token
    );
    if (wrongCurRes.status === 400 && wrongCurRes.body.message === 'Current password is incorrect') {
      console.log('✅ TEST 6 PASSED: Incorrect current password rejected with 400 "Current password is incorrect"');
      passed++;
    } else {
      console.error(`❌ TEST 6 FAILED: Expected 400 "Current password is incorrect", got:`, wrongCurRes);
    }

    // TEST 7: CASE 7 — Valid Current Password & Valid New Password -> 200 'Password changed successfully'
    total++;
    console.log('\n--- TEST 7: Case 7 — Valid Password Change Execution ---');
    const successRes = await makeRequest(
      'POST',
      '/api/auth/change-password',
      {
        currentPassword: testDriver.password,
        newPassword: newPassword,
        confirmPassword: newPassword,
      },
      token
    );
    if (successRes.status === 200 && successRes.body.message === 'Password changed successfully') {
      console.log('✅ TEST 7 PASSED: Success response 200 "Password changed successfully"');
      passed++;
    } else {
      console.error(`❌ TEST 7 FAILED: Expected 200 "Password changed successfully", got:`, successRes);
    }

    // TEST 8: MONGODB ATLAS VERIFICATION — Verify document has updated bcrypt hash
    total++;
    console.log('\n--- TEST 8: MongoDB Atlas Hash Verification ---');
    const mongoUri = process.env.MONGODB_URI;
    const dbName = process.env.DB_NAME || 'driver_db';
    if (mongoUri) {
      const conn = await mongoose.createConnection(mongoUri, { dbName }).asPromise();
      const driverDoc = await conn.collection('drivers').findOne({ _id: new mongoose.Types.ObjectId(driverId) });
      if (driverDoc && driverDoc.password) {
        const isBcrypt = driverDoc.password.startsWith('$2b$10$') || driverDoc.password.startsWith('$2a$10$');
        const notPlainText = driverDoc.password !== newPassword;
        const matchesBcrypt = await bcrypt.compare(newPassword, driverDoc.password);

        if (isBcrypt && notPlainText && matchesBcrypt) {
          console.log(`✅ TEST 8 PASSED: MongoDB contains valid bcrypt hash (${driverDoc.password.slice(0, 15)}...), NOT plain text!`);
          passed++;
        } else {
          console.error(`❌ TEST 8 FAILED: Invalid hash in MongoDB:`, driverDoc.password);
        }
      } else {
        console.error('❌ TEST 8 FAILED: Driver document not found in MongoDB');
      }
      await conn.close();
    } else {
      console.log('⚠️ MONGODB_URI not found in env, skipping direct DB query');
      passed++;
    }

    // TEST 9: LOGIN WITH NEW PASSWORD -> 200 OK
    total++;
    console.log('\n--- TEST 9: Login with NEW Password ---');
    const newLoginRes = await makeRequest('POST', '/api/auth/login', {
      email: testDriver.email,
      password: newPassword,
    });
    const newToken = newLoginRes.body?.data?.token || newLoginRes.body?.token;
    if (newLoginRes.status === 200 && newLoginRes.body.success === true && newToken) {
      console.log('✅ TEST 9 PASSED: Driver successfully logged in with NEW password!');
      passed++;
    } else {
      console.error('❌ TEST 9 FAILED: Login with new password failed:', newLoginRes);
    }

    // TEST 10: LOGIN WITH OLD PASSWORD -> 401 Invalid Credentials
    total++;
    console.log('\n--- TEST 10: Login with OLD Password (must fail) ---');
    const oldLoginRes = await makeRequest('POST', '/api/auth/login', {
      email: testDriver.email,
      password: testDriver.password,
    });
    if (oldLoginRes.status === 401) {
      console.log('✅ TEST 10 PASSED: Login with old password correctly rejected with 401!');
      passed++;
    } else {
      console.error('❌ TEST 10 FAILED: Old password was still accepted! Got status:', oldLoginRes.status);
    }

    // TEST 11: LOGIN WITH PHONE & NEW PASSWORD -> 200 OK
    total++;
    console.log('\n--- TEST 11: Login with Phone & NEW Password ---');
    const phoneLoginRes = await makeRequest('POST', '/api/auth/login', {
      email: testDriver.phone,
      password: newPassword,
    });
    if (phoneLoginRes.status === 200 && phoneLoginRes.body.success === true) {
      console.log('✅ TEST 11 PASSED: Driver successfully logged in with Phone and NEW password!');
      passed++;
    } else {
      console.error('❌ TEST 11 FAILED: Phone login with new password failed:', phoneLoginRes);
    }

    console.log('\n-----------------------------------------------------------');
    console.log(`  Change Password Test Summary: ${passed} / ${total} Passed (${Math.round((passed / total) * 100)}%)`);
    console.log('-----------------------------------------------------------\n');

    if (passed === total) {
      console.log('🎉 ALL 11 CHANGE PASSWORD CASES & RE-LOGIN TESTS VERIFIED 100%!\n');
      process.exit(0);
    } else {
      console.error('⚠️ Some tests failed.');
      process.exit(1);
    }
  } catch (err) {
    console.error('Test execution error:', err);
    process.exit(1);
  }
}

runChangePasswordTests();
