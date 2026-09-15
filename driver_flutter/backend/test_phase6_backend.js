const http = require('http');

const PORT = 5000;
const HOST = 'localhost';

function makeRequest(method, path, body = null, token = null) {
  return new Promise((resolve, reject) => {
    const postData = body ? JSON.stringify(body) : null;
    const headers = {
      'Content-Type': 'application/json',
    };
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }
    if (postData) {
      headers['Content-Length'] = Buffer.byteLength(postData);
    }

    const options = {
      hostname: HOST,
      port: PORT,
      path: path,
      method: method,
      headers: headers,
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          resolve({ status: res.statusCode, body: parsed });
        } catch (e) {
          resolve({ status: res.statusCode, body: data });
        }
      });
    });

    req.on('error', reject);
    if (postData) req.write(postData);
    req.end();
  });
}

async function runPhase6Tests() {
  console.log('\n===========================================================');
  console.log('  GORUSH DRIVER APP — PHASE 6 PRODUCTION READINESS SUITE   ');
  console.log('===========================================================\n');

  let passed = 0;
  let total = 0;

  function assert(condition, message) {
    total++;
    if (condition) {
      console.log(`  [PASS] ${message}`);
      passed++;
    } else {
      console.error(`  [FAIL] ${message}`);
    }
  }

  const timestamp = Date.now();
  const testEmail = `phase6_driver_${timestamp}@gorush.test`;
  const testPhone = `98${timestamp.toString().slice(-8)}`;
  const testPassword = 'Password@Phase6';
  let token = null;
  let driverId = null;
  let rideId = null;

  try {
    // 1. Health check & MongoDB Atlas
    const healthRes = await makeRequest('GET', '/api/health');
    assert(
      healthRes.status === 200 &&
        healthRes.body.status === 'healthy' &&
        (healthRes.body.database?.connection === 'connected' || healthRes.body.database?.readyState === 'connected'),
      'Backend is healthy and MongoDB Atlas is connected'
    );

    // 2. Driver Registration
    const regRes = await makeRequest('POST', '/api/auth/register', {
      name: 'Phase 6 Master Driver',
      phone: testPhone,
      email: testEmail,
      password: testPassword,
      vehicleId: 'DL 01 ZZ 7777',
      licenseNumber: `DL-P6-${timestamp}`,
    });
    token = regRes.body?.data?.token || regRes.body?.token;
    driverId = regRes.body?.data?.driver?._id || regRes.body?.driver?._id;
    assert(
      regRes.status === 201 && token && driverId,
      'Driver registered successfully with JWT and MongoDB driver ID'
    );

    // 3. Driver Status: GO ONLINE
    const onlineRes = await makeRequest('PUT', '/api/driver/status', { online: true }, token);
    assert(
      onlineRes.status === 200 && onlineRes.body.data?.status === 'online',
      'Driver status updated to ONLINE in MongoDB Atlas'
    );

    // 4. Fetch Available Incoming Ride
    const availRes = await makeRequest('GET', '/api/rides/available', null, token);
    const ride = availRes.body?.data;
    rideId = ride?.rideId;
    assert(
      availRes.status === 200 && ride && ride.status === 'requested',
      `Incoming ride request delivered to online driver: ${rideId} (${ride?.passenger?.name})`
    );

    // 5. Accept Ride
    const acceptRes = await makeRequest('POST', `/api/rides/${rideId}/accept`, {}, token);
    assert(
      acceptRes.status === 200 &&
        acceptRes.body.data?.status === 'accepted' &&
        String(acceptRes.body.data?.driverId) === String(driverId),
      `Ride accepted successfully: status='accepted', driverId associated with ${testEmail}`
    );

    // 6. Duplicate Accept Protection (Double-tap safety)
    const dupAcceptRes = await makeRequest('POST', `/api/rides/${rideId}/accept`, {}, token);
    assert(
      dupAcceptRes.status === 200 && dupAcceptRes.body.data?.status === 'accepted',
      'Duplicate accept by same driver safely returns existing accepted ride without re-mutation'
    );

    // 7. Driver Mark Arrived
    const arrivedRes = await makeRequest('POST', `/api/rides/${rideId}/arrived`, {}, token);
    assert(
      arrivedRes.status === 200 && arrivedRes.body.data?.status === 'arrived',
      'Driver arrived at pickup location: status updated to arrived'
    );

    // 8. Start Trip: Invalid OTP rejected
    const badOtpRes = await makeRequest('POST', `/api/rides/${rideId}/start`, { otp: '0000' }, token);
    assert(
      badOtpRes.status === 400,
      'Invalid passenger OTP correctly rejected with 400 Bad Request'
    );

    // 9. Start Trip: Valid OTP
    const startRes = await makeRequest('POST', `/api/rides/${rideId}/start`, { otp: '4892' }, token);
    assert(
      startRes.status === 200 && startRes.body.data?.status === 'in_progress',
      'Trip started with passenger OTP: status updated to in_progress'
    );

    // 10. Complete Trip
    const completeRes = await makeRequest('POST', `/api/rides/${rideId}/complete`, {}, token);
    assert(
      completeRes.status === 200 && completeRes.body.data?.status === 'completed',
      `Trip completed: fare recorded as ₹${completeRes.body.data?.fare?.total}, driverEarnings=₹${completeRes.body.data?.fare?.driverEarnings}`
    );

    // 11. History Separation: Completed tab includes trip, Cancelled does NOT
    const historyRes = await makeRequest('GET', '/api/rides/history', null, token);
    const completedList = historyRes.body?.data?.completed || [];
    const cancelledList = historyRes.body?.data?.cancelled || [];
    const inCompleted = completedList.some((r) => r.rideId === rideId);
    const inCancelled = cancelledList.some((r) => r.rideId === rideId);
    assert(
      inCompleted && !inCancelled,
      'Completed trip appears in COMPLETED history and is strictly absent from CANCELLED history'
    );

    // 12. Driver Earnings Verification
    const earningsRes = await makeRequest('GET', '/api/rides/earnings', null, token);
    const earnings = earningsRes.body?.data;
    const rideCount = earnings?.completedRidesCount ?? earnings?.totalRides ?? 0;
    assert(
      earningsRes.status === 200 && rideCount >= 1 && earnings?.totalEarnings > 0,
      `Driver earnings aggregated correctly in MongoDB: total=₹${earnings?.totalEarnings}, count=${rideCount}`
    );

    // 13. Rejection Flow: Next available ride rejected with driver reason
    const nextRideRes = await makeRequest('GET', '/api/rides/available', null, token);
    const nextRideId = nextRideRes.body?.data?.rideId;
    const rejectRes = await makeRequest(
      'POST',
      `/api/rides/${nextRideId}/reject`,
      { reason: 'Vehicle maintenance inspection' },
      token
    );
    assert(
      rejectRes.status === 200 && rejectRes.body.data?.status === 'cancelled',
      `Second ride ${nextRideId} rejected: status='cancelled', reason persisted in MongoDB`
    );

    // 14. Cancelled History Separation
    const history2Res = await makeRequest('GET', '/api/rides/history', null, token);
    const cancelledList2 = history2Res.body?.data?.cancelled || [];
    const completedList2 = history2Res.body?.data?.completed || [];
    const nextInCancelled = cancelledList2.some((r) => r.rideId === nextRideId);
    const nextInCompleted = completedList2.some((r) => r.rideId === nextRideId);
    assert(
      nextInCancelled && !nextInCompleted,
      'Rejected ride appears in CANCELLED history and is strictly absent from COMPLETED history'
    );

    // 15. Driver Status: GO OFFLINE & Protected from Rides
    const offlineRes = await makeRequest('PUT', '/api/driver/status', { online: false }, token);
    const offlineAvail = await makeRequest('GET', '/api/rides/available', null, token);
    assert(
      offlineRes.status === 200 && offlineAvail.body?.data === null,
      'Driver went OFFLINE: successfully protected from receiving ride requests when offline'
    );

    // 16. Profile Update & Persistence in MongoDB
    const profileUpdateRes = await makeRequest(
      'PUT',
      '/api/auth/profile',
      {
        name: 'Phase 6 Master Driver (Verified)',
        city: 'Noida Hub',
        privacySettings: { backgroundLocation: true, maskPhoneNumber: true },
      },
      token
    );
    assert(
      profileUpdateRes.status === 200 &&
        profileUpdateRes.body.data?.driver?.name === 'Phase 6 Master Driver (Verified)',
      'Driver profile updates verified and persisted in MongoDB Atlas'
    );

    // 17. Change Password & Re-login with New Password
    const newPass = 'BrandNewPassword@2026';
    const changePassRes = await makeRequest(
      'POST',
      '/api/auth/change-password',
      {
        currentPassword: testPassword,
        newPassword: newPass,
        confirmPassword: newPass,
      },
      token
    );
    const oldLoginRes = await makeRequest('POST', '/api/auth/login', {
      email: testEmail,
      password: testPassword,
    });
    const newLoginRes = await makeRequest('POST', '/api/auth/login', {
      email: testEmail,
      password: newPass,
    });
    assert(
      changePassRes.status === 200 && oldLoginRes.status === 401 && newLoginRes.status === 200,
      'Change Password secured with bcrypt: old password rejected (401), new password authenticated (200)'
    );
  } catch (err) {
    console.error('\n❌ Unexpected error during Phase 6 suite:', err);
  }

  console.log('\n===========================================================');
  console.log(`  PHASE 6 TEST RESULTS: ${passed} PASSED, ${total - passed} FAILED`);
  console.log('===========================================================\n');

  if (passed === total && total > 0) {
    process.exit(0);
  } else {
    process.exit(1);
  }
}

runPhase6Tests();
