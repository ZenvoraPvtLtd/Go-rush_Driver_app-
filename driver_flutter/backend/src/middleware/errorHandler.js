/**
 * Centralized Error Handling Middleware
 * Ensures consistent JSON response structure:
 * {
 *   "success": false,
 *   "message": "Human readable error message"
 * }
 */
const errorHandler = (err, req, res, next) => {
  let statusCode = err.statusCode || (res.statusCode === 200 ? 500 : res.statusCode);
  let message = err.message || 'Internal Server Error';

  // Handle Mongoose Bad ObjectId (CastError)
  if (err.name === 'CastError') {
    statusCode = 400;
    message = `Resource not found with id: ${err.value}`;
  }

  // Handle Mongoose Duplicate Key Error (E11000)
  if (err.code === 11000) {
    statusCode = 409;
    const field = Object.keys(err.keyValue || {})[0] || 'field';
    const fieldLabel = field === 'email' ? 'Email' : field === 'phone' ? 'Phone number' : field;
    message = `${fieldLabel} is already registered`;
  }

  // Handle Mongoose Validation Error
  if (err.name === 'ValidationError') {
    statusCode = 400;
    message = Object.values(err.errors)[0]?.message || 'Validation Error';
  }

  // Handle JWT Errors
  if (err.name === 'JsonWebTokenError') {
    statusCode = 401;
    message = 'Invalid authentication token';
  }

  if (err.name === 'TokenExpiredError') {
    statusCode = 401;
    message = 'Authentication token expired';
  }

  // Log server errors (5xx)
  if (statusCode >= 500) {
    console.error(`[Unhandled Error] ${req.method} ${req.originalUrl}:`, err);
    message = 'Internal server error';
  }

  return res.status(statusCode).json({
    success: false,
    message,
  });
};

module.exports = errorHandler;
