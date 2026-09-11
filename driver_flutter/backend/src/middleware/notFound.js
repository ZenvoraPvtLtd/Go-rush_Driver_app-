/**
 * 404 Route Not Found Middleware
 */
const notFound = (req, res, next) => {
  const error = new Error(`Route Not Found - ${req.method} ${req.originalUrl}`);
  res.status(404).json({
    success: false,
    error: {
      message: error.message,
      statusCode: 404,
    },
    timestamp: new Date().toISOString(),
  });
};

module.exports = notFound;
