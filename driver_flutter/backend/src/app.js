const express = require('express');
const cors = require('cors');
const path = require('path');
const config = require('./config/env');
const apiRoutes = require('./routes');
const notFound = require('./middleware/notFound');
const errorHandler = require('./middleware/errorHandler');

const app = express();

// 1. CORS Configuration for Flutter (Web, Android Emulator, iOS, Desktop)
const corsOptions = {
  origin: (origin, callback) => {
    // Allow mobile apps, curl, postman (which have no origin header)
    if (!origin) return callback(null, true);

    if (config.cors.origin === '*' || config.cors.origin === origin) {
      return callback(null, true);
    }

    // Allow localhost & local emulator patterns
    if (/^http:\/\/(localhost|127\.0\.0\.1|10\.0\.2\.2)(:\d+)?$/.test(origin)) {
      return callback(null, true);
    }

    return callback(null, true); // Permissive in dev mode for smooth Flutter pairing
  },
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept'],
  credentials: true,
};

app.use(cors(corsOptions));
app.options('*', cors(corsOptions));

// 2. Request Parsing Middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// 3. Lightweight Request Logger with File Output
const fs = require('fs');
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    const logLine = `${new Date().toISOString()} [HTTP] ${req.method} ${req.originalUrl} ${res.statusCode} - ${duration}ms body=${JSON.stringify(req.body)}\n`;
    console.log(logLine.trim());
    try {
      fs.appendFileSync(path.resolve(__dirname, '../requests.log'), logLine);
    } catch (_) {}
  });
  next();
});

// 4. API Routes
app.use('/api', apiRoutes);

// Root route
app.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    service: 'GoRush Driver Partner Backend',
    status: 'online',
    healthCheck: '/api/health',
  });
});

// 5. 404 Not Found Handler
app.use(notFound);

// 6. Centralized Error Handler
app.use(errorHandler);

module.exports = app;
