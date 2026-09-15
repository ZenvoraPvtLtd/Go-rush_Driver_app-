/**
 * GoRush Driver App - Phase 3 Backend Verification
 * Tests Authenticated Endpoints, JWT Bearer Token Middleware, and Auth Protection
 */
const http = require('http');
const jwt = require('jsonwebtoken');
const config = require('./src/config/env');
const Driver = require('./src/models/driver.model');

const BASE_URL = `http://localhost:${config.port}`;

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
            headers: res.headers,
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
  console.log('       PHASE 3: AUTHENTICATED REQUESTS & BACKEND TESTS     ');
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

  // 1. Test GET /api/health
  console.log('1. Verifying Live Server Status & Endpoints...');
  const healthRes = await makeRequest('GET', '/api/health');
  assert(healthRes.statusCode === 200, `Health check returned HTTP 200 (Got: ${healthRes.statusCode})`);
  assert(healthRes.data?.success === true, 'Health check response contains success: true');

  // 2. Test GET /api/auth/me without token (Must be rejected with 401)
  console.log('\n2. Verifying Protected Route Authentication Enforcement...');
  const noTokenRes = await makeRequest('GET', '/api/auth/me');
  assert(noTokenRes.statusCode === 401, `Accessing protected /api/auth/me without token returns 401 (Got: ${noTokenRes.statusCode})`);
  assert(noTokenRes.data?.success === false, 'Error response has success: false');

  // 3. Test GET /api/auth/me with invalid token (Must be rejected with 401)
  const badTokenRes = await makeRequest('GET', '/api/auth/me', null, 'invalid_random_jwt_token');
  assert(badTokenRes.statusCode === 401, `Accessing with invalid token returns 401 (Got: ${badTokenRes.statusCode})`);
  assert(badTokenRes.data?.message?.includes('Invalid') || badTokenRes.data?.message?.includes('Not authorized'), 'Safe invalid token message returned');

  // 4. Test GET /api/auth/me with expired token
  const expiredToken = jwt.sign({ id: 'dummy_id' }, config.jwt.secret, { expiresIn: '0s' });
  const expiredRes = await makeRequest('GET', '/api/auth/me', null, expiredToken);
  assert(expiredRes.statusCode === 401, `Expired token returns 401 (Got: ${expiredRes.statusCode})`);
  assert(expiredRes.data?.message?.includes('expired') || expiredRes.data?.message?.includes('Not authorized'), 'Safe expired token message returned');

  // 5. Test Valid Token Generation & Structure
  console.log('\n3. Verifying JWT Token Generation with Environment Secret...');
  const validToken = jwt.sign(
    { id: '60d0fe4f5311236168a109ca', email: 'driver@gorush.com' },
    config.jwt.secret,
    { expiresIn: config.jwt.expiresIn || '7d' }
  );
  assert(typeof validToken === 'string' && validToken.length > 30, 'Signed JWT token generated successfully');

  console.log('\n===========================================================');
  console.log(`   TEST RESULTS: ${passed} PASSED, ${failed} FAILED`);
  console.log('===========================================================\n');

  if (failed > 0) {
    process.exit(1);
  }
}

runTests();
