/**
 * End-to-End Test Suite: Registered Driver Details Must Appear in Profile
 * 
 * Tests the real flow:
 * 1. Register a NEW driver with actual unique information (Name, Phone, Email, License, Vehicle).
 * 2. Confirm registration succeeds (201 Created) and JWT is issued.
 * 3. Verify driver document exists in MongoDB Atlas with exact fields.
 * 4. Login using that driver's credentials.
 * 5. Verify Login returns 200 OK + valid JWT + exact driver details.
 * 6. Call GET /api/auth/me (and /api/auth/profile) using the authenticated JWT.
 * 7. Confirm Profile returns EXACTLY the registered information.
 * 8. Call PUT /api/auth/profile to update a supported field (e.g., address & city).
 * 9. Confirm the backend update succeeds (200 OK).
 * 10. Verify MongoDB Atlas document is actually updated with new field values.
 * 11. Fetch Profile again with JWT and verify updated information is returned.
 * 12. Regression test: Verify registration still works for another new driver.
 */

const http = require('http');
const mongoose = require('mongoose');
const dns = require('dns');
try {
  dns.setServers(['8.8.8.8', '1.1.1.1']);
} catch (e) {}

const BASE_URL = 'http://localhost:5000';
const MONGO_URI = 'mongodb+srv://ira_09:ira%4012345@cluster0.6pfn8y0.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0';

const makeRequest = (path, method, body, token) => {
  return new Promise((resolve, reject) => {
    const url = new URL(path, BASE_URL);
    const postData = body ? JSON.stringify(body) : '';
    const headers = {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(postData),
    };
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    const req = http.request(
      {
        hostname: url.hostname,
        port: url.port,
        path: url.pathname,
        method: method,
        headers: headers,
        timeout: 8000,
      },
      (res) => {
        let responseBody = '';
        res.on('data', (chunk) => (responseBody += chunk));
        res.on('end', () => {
          try {
            const parsed = JSON.parse(responseBody);
            resolve({ statusCode: res.statusCode, body: parsed });
          } catch (e) {
            resolve({ statusCode: res.statusCode, body: responseBody });
          }
        });
      }
    );

    req.on('error', reject);
    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Request timeout'));
    });

    if (postData) req.write(postData);
    req.end();
  });
};

async function runTests() {
  console.log('\n===========================================================');
  console.log('   TEST SUITE: REGISTERED DRIVER DETAILS APPEAR IN PROFILE   ');
  console.log('===========================================================\n');

  let passed = 0;
  let total = 0;

  function assert(condition, message) {
    total++;
    if (condition) {
      console.log(`✅ TEST ${total} PASSED: ${message}`);
      passed++;
    } else {
      console.error(`❌ TEST ${total} FAILED: ${message}`);
    }
  }

  // Generate unique test driver details
  const timestamp = Date.now();
  const testDriver = {
    name: 'Aarav Sharma',
    phone: `98${Math.floor(10000000 + Math.random() * 90000000)}`,
    email: `aarav.sharma.${timestamp}@gmail.com`,
    password: 'SecurePassword@2026',
    licenseNumber: 'DL-04-2026-987654',
    vehicleId: 'DL 01 AB 7788',
  };

  try {
    // 1. Register a NEW driver using actual information
    console.log(`[Step 1] Registering Driver: ${testDriver.name} (${testDriver.email})...`);
    const regRes = await makeRequest('/api/auth/register', 'POST', testDriver);
    assert(
      regRes.statusCode === 201 && regRes.body.success === true,
      `Driver registration returned 201 Created (Token received: ${!!regRes.body.data?.token})`
    );

    const initialToken = regRes.body.data?.token;
    const initialDriver = regRes.body.data?.driver;
    assert(
      initialDriver && initialDriver.name === testDriver.name && initialDriver.licenseNumber === testDriver.licenseNumber,
      `Registration response contains exact driver details (Name: "${initialDriver?.name}", License: "${initialDriver?.licenseNumber}")`
    );

    // 2. Direct MongoDB Atlas verification
    console.log('\n[Step 2] Connecting directly to MongoDB Atlas driver_db.drivers collection...');
    const conn = await mongoose.connect(MONGO_URI, { dbName: 'driver_db', serverSelectionTimeoutMS: 5000 });
    const DriverModel = conn.model('DriverTest', new mongoose.Schema({}, { strict: false, collection: 'drivers' }));
    
    const dbDriver = await DriverModel.findOne({ email: testDriver.email });
    assert(
      dbDriver != null,
      `Driver exists in MongoDB Atlas 'drivers' collection (ID: ${dbDriver?._id})`
    );
    assert(
      dbDriver?.name === testDriver.name &&
      dbDriver?.phone === testDriver.phone &&
      dbDriver?.licenseNumber === testDriver.licenseNumber &&
      dbDriver?.vehicleId === testDriver.vehicleId,
      `MongoDB Atlas contains exact registered details: Phone=${dbDriver?.phone}, License=${dbDriver?.licenseNumber}, Vehicle=${dbDriver?.vehicleId}`
    );

    // 3. Login using that driver
    console.log('\n[Step 3] Logging in with the newly registered credentials...');
    const loginRes = await makeRequest('/api/auth/login', 'POST', {
      email: testDriver.email,
      password: testDriver.password,
    });
    assert(
      loginRes.statusCode === 200 && loginRes.body.success === true,
      `Driver login returned 200 OK with message "${loginRes.body.message}"`
    );

    const loginToken = loginRes.body.data?.token;
    const loggedInDriver = loginRes.body.data?.driver;
    assert(
      loginToken && loggedInDriver?.email === testDriver.email,
      `Login issued JWT token associated with Driver ID: ${loggedInDriver?._id}`
    );

    // 4. Fetch Profile using the authenticated JWT (GET /api/auth/me and GET /api/auth/profile)
    console.log('\n[Step 4] Fetching authenticated profile via GET /api/auth/me...');
    const profileMeRes = await makeRequest('/api/auth/me', 'GET', null, loginToken);
    assert(
      profileMeRes.statusCode === 200 && profileMeRes.body.success === true,
      `GET /api/auth/me returned 200 OK`
    );
    const profileDriver = profileMeRes.body.data?.driver;
    assert(
      profileDriver?.name === testDriver.name &&
      profileDriver?.phone === testDriver.phone &&
      profileDriver?.email === testDriver.email &&
      profileDriver?.licenseNumber === testDriver.licenseNumber,
      `Profile displays EXACT registered driver info: Name="${profileDriver?.name}", Phone="${profileDriver?.phone}", Email="${profileDriver?.email}", License="${profileDriver?.licenseNumber}"`
    );

    // 5. Test alias GET /api/auth/profile
    const profileRes = await makeRequest('/api/auth/profile', 'GET', null, loginToken);
    assert(
      profileRes.statusCode === 200 && profileRes.body.data?.driver?.name === testDriver.name,
      `GET /api/auth/profile alias returned same registered driver details`
    );

    // 6. Open Edit Profile -> Update fields (Address & City)
    console.log('\n[Step 5] Updating profile via PUT /api/auth/profile (Edit Profile)...');
    const updatePayload = {
      name: 'Aarav Sharma (Senior Partner)',
      city: 'Gurugram Cyber City',
      address: 'Tower B, Cyber Hub, Gurugram, Haryana - 122002',
    };
    const updateRes = await makeRequest('/api/auth/profile', 'PUT', updatePayload, loginToken);
    assert(
      updateRes.statusCode === 200 && updateRes.body.success === true,
      `PUT /api/auth/profile returned 200 OK: "${updateRes.body.message}"`
    );

    // 7. Verify MongoDB update
    const updatedDbDriver = await DriverModel.findById(dbDriver._id);
    assert(
      updatedDbDriver?.name === updatePayload.name &&
      updatedDbDriver?.city === updatePayload.city &&
      updatedDbDriver?.address === updatePayload.address,
      `MongoDB Atlas document was updated with new values: Name="${updatedDbDriver?.name}", City="${updatedDbDriver?.city}"`
    );

    // 8. Re-fetch Profile and verify updated information appears
    console.log('\n[Step 6] Re-fetching profile to verify updated information is returned...');
    const refreshedProfileRes = await makeRequest('/api/auth/me', 'GET', null, loginToken);
    const refreshedDriver = refreshedProfileRes.body.data?.driver;
    assert(
      refreshedDriver?.name === updatePayload.name &&
      refreshedDriver?.city === updatePayload.city &&
      refreshedDriver?.address === updatePayload.address &&
      refreshedDriver?.licenseNumber === testDriver.licenseNumber,
      `Re-fetched Profile displays updated Name: "${refreshedDriver?.name}", City: "${refreshedDriver?.city}", Address: "${refreshedDriver?.address}"`
    );

    // 9. Regression Test: Verify registration still works for another new driver
    console.log('\n[Step 7] Regression Test: Registering second distinct driver...');
    const reg2Res = await makeRequest('/api/auth/register', 'POST', {
      name: 'Priya Patel',
      phone: `98${Math.floor(10000000 + Math.random() * 90000000)}`,
      email: `priya.patel.${Date.now()}@gmail.com`,
      password: 'AnotherPassword@456',
      licenseNumber: 'GJ-01-2026-112233',
      vehicleId: 'GJ 01 CD 5566',
    });
    assert(
      reg2Res.statusCode === 201 && reg2Res.body.data?.driver?.name === 'Priya Patel',
      `Registration remains 100% operational for new drivers (Priya Patel registered successfully)`
    );

    await mongoose.disconnect();

    console.log('\n-----------------------------------------------------------');
    console.log(`  Driver Profile Flow Summary: ${passed} / ${total} Passed (${Math.round((passed / total) * 100)}%)`);
    console.log('-----------------------------------------------------------\n');

    if (passed === total) {
      console.log('🎉 REGISTRATION -> LOGIN -> PROFILE DATA BINDING VERIFIED 100% IN MONGODB & BACKEND!\n');
      process.exit(0);
    } else {
      process.exit(1);
    }
  } catch (error) {
    console.error('Fatal Test Runner Error:', error);
    process.exit(1);
  }
}

runTests();
