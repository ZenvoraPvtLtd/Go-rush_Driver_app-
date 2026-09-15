/**
 * GoRush Driver App - Phase 5 Core Ride & Trip Flow Backend Test Suite
 * Validates:
 * 1. Driver Authentication & JWT Token
 * 2. Go Online (PUT /api/driver/status)
 * 3. Incoming Available Ride Offer (GET /api/rides/available)
 * 4. Accept Ride (POST /api/rides/:rideId/accept)
 * 5. Mark Arrived at Pickup (POST /api/rides/:rideId/arrived)
 * 6. Start Trip with Passenger OTP (POST /api/rides/:rideId/start)
 * 7. Complete Trip & Finalize Fare (POST /api/rides/:rideId/complete)
 * 8. Driver History: Verify Completed Trip (GET /api/rides/history)
 * 9. Driver Earnings: Verify Aggregated Earnings (GET /api/rides/earnings)
 * 10. Reject Ride Flow: Reject incoming ride & verify in Cancelled History
 * 11. Go Offline (PUT /api/driver/status)
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

async function runPhase5Tests() {
  console.log('\n===========================================================');
  console.log('  GORUSH DRIVER APP — PHASE 5 BACKEND VERIFICATION');
  console.log('===========================================================\n');

  let passed = 0;
  let failed = 0;

  function assert(condition, message) {
    if (condition) {
      console.log(`  [PASS] ${message}`);
      passed++;
    } else {
      console.error(`  [FAIL] ${message}`);
      failed++;
    }
  }

  try {
    // 1. Health check
    const health = await makeRequest('GET', '/api/health');
    assert(health.statusCode === 200 && health.data.status === 'healthy', 'Health check is healthy and MongoDB connected');

    // 2. Register/Login test driver
    const uniqueSuffix = Date.now();
    const driverPhone = `9876${String(uniqueSuffix).slice(-6)}`;
    const driverEmail = `phase5_driver_${uniqueSuffix}@gorush.test`;
    const driverPassword = 'pass_phase5_1234';

    const regRes = await makeRequest('POST', '/api/auth/register', {
      name: 'Phase 5 Test Driver',
      phone: driverPhone,
      email: driverEmail,
      password: driverPassword,
    });

    const token = regRes.data?.data?.token || regRes.data?.token;
    const driver = regRes.data?.data?.driver || regRes.data?.driver;
    assert(regRes.statusCode === 201 && token, 'Driver registration succeeded with JWT token');
    const driverId = driver?._id || driver?.id;

    // 3. Go Online
    const onlineRes = await makeRequest('PUT', '/api/driver/status', { online: true }, token);
    assert(onlineRes.statusCode === 200 && onlineRes.data.data.status === 'online', 'Driver status updated to ONLINE in MongoDB');

    // 4. Fetch Available Ride
    const availableRes = await makeRequest('GET', '/api/rides/available', null, token);
    assert(
      availableRes.statusCode === 200 && availableRes.data.data && availableRes.data.data.rideId,
      `Incoming ride offer available: ${availableRes.data?.data?.rideId} (${availableRes.data?.data?.passenger?.name})`
    );
    const ride1 = availableRes.data.data;
    const rideId1 = ride1.rideId || ride1._id;

    // 5. Accept Ride
    const acceptRes = await makeRequest('POST', `/api/rides/${rideId1}/accept`, {}, token);
    assert(
      acceptRes.statusCode === 200 && acceptRes.data.data.status === 'accepted',
      `Ride accepted successfully: status='${acceptRes.data?.data?.status}', driverId associated`
    );

    // 6. Mark Arrived at Pickup
    const arrivedRes = await makeRequest('POST', `/api/rides/${rideId1}/arrived`, {}, token);
    assert(
      arrivedRes.statusCode === 200 && arrivedRes.data.data.status === 'arrived',
      `Driver marked arrived at pickup: status='${arrivedRes.data?.data?.status}'`
    );

    // 7. Start Trip with OTP
    const startRes = await makeRequest('POST', `/api/rides/${rideId1}/start`, { otp: ride1.otp || '4892' }, token);
    assert(
      startRes.statusCode === 200 && startRes.data.data.status === 'in_progress',
      `Trip started with OTP: status='${startRes.data?.data?.status}'`
    );

    // 8. Complete Trip
    const completeRes = await makeRequest('POST', `/api/rides/${rideId1}/complete`, {}, token);
    assert(
      completeRes.statusCode === 200 && completeRes.data.data.status === 'completed',
      `Trip completed successfully: status='${completeRes.data?.data?.status}', fare total=₹${completeRes.data?.data?.fare?.total}`
    );

    // 9. Verify History: Completed vs Cancelled
    const historyRes = await makeRequest('GET', '/api/rides/history', null, token);
    const completedList = historyRes.data?.data?.completed || [];
    const cancelledList = historyRes.data?.data?.cancelled || [];
    assert(
      historyRes.statusCode === 200 && completedList.some((r) => r.rideId === ride1.rideId),
      `Completed history includes completed trip (Found ${completedList.length} completed rides)`
    );
    assert(
      !cancelledList.some((r) => r.rideId === ride1.rideId),
      'Completed trip is strictly NOT present in cancelled history'
    );

    // 10. Verify Earnings Aggregation
    const earningsRes = await makeRequest('GET', '/api/rides/earnings', null, token);
    assert(
      earningsRes.statusCode === 200 && earningsRes.data.data.totalEarnings > 0 && earningsRes.data.data.completedRidesCount >= 1,
      `Driver earnings aggregated from completed ride: Total=₹${earningsRes.data?.data?.totalEarnings}, Completed Rides=${earningsRes.data?.data?.completedRidesCount}`
    );

    // 11. Test Reject Flow with second ride
    const availableRes2 = await makeRequest('GET', '/api/rides/available', null, token);
    const ride2 = availableRes2.data.data;
    const rideId2 = ride2.rideId || ride2._id;

    const rejectRes = await makeRequest('POST', `/api/rides/${rideId2}/reject`, { reason: 'Driver taking lunch break' }, token);
    assert(
      rejectRes.statusCode === 200 && rejectRes.data.data.status === 'cancelled',
      `Ride rejected successfully: status='${rejectRes.data?.data?.status}'`
    );

    // 12. Verify History has ride2 in Cancelled
    const historyRes2 = await makeRequest('GET', '/api/rides/history', null, token);
    const completedList2 = historyRes2.data?.data?.completed || [];
    const cancelledList2 = historyRes2.data?.data?.cancelled || [];

    assert(
      cancelledList2.some((r) => r.rideId === ride2.rideId),
      `Cancelled history includes rejected trip (Found ${cancelledList2.length} cancelled rides)`
    );
    assert(
      !completedList2.some((r) => r.rideId === ride2.rideId),
      'Cancelled/rejected trip is strictly NOT present in completed history'
    );

    // 13. Go Offline
    const offlineRes = await makeRequest('PUT', '/api/driver/status', { online: false }, token);
    assert(offlineRes.statusCode === 200 && offlineRes.data.data.status === 'offline', 'Driver status updated to OFFLINE in MongoDB');

    // 14. Verify while offline, getAvailable returns offline
    const availableOfflineRes = await makeRequest('GET', '/api/rides/available', null, token);
    assert(
      availableOfflineRes.statusCode === 200 && availableOfflineRes.data.data === null,
      'When offline, driver receives null ride requests (protected from receiving rides offline)'
    );

  } catch (err) {
    console.error('Test execution error:', err);
    failed++;
  }

  console.log('\n===========================================================');
  console.log(`  PHASE 5 TEST RESULTS: ${passed} PASSED, ${failed} FAILED`);
  console.log('===========================================================\n');

  process.exit(failed > 0 ? 1 : 0);
}

runPhase5Tests();
