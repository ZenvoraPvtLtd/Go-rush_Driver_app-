const Driver = require('../models/driver.model');

/**
 * PUT /api/driver/status
 * Update driver online/offline status in MongoDB Atlas
 */
exports.updateStatus = async (req, res) => {
  try {
    const driverId = req.driver ? req.driver._id : (req.body.driverId || null);

    if (!driverId) {
      return res.status(401).json({
        success: false,
        message: 'Unauthorized: Driver authentication required',
      });
    }

    const { status, online } = req.body;
    let targetStatus = status;

    if (online !== undefined) {
      targetStatus = online ? 'online' : 'offline';
    }

    if (!targetStatus || !['online', 'offline', 'busy'].includes(targetStatus)) {
      return res.status(400).json({
        success: false,
        message: "Invalid status. Must be 'online', 'offline', or 'busy'.",
      });
    }

    const driver = await Driver.findByIdAndUpdate(
      driverId,
      { status: targetStatus },
      { new: true }
    );

    if (!driver) {
      return res.status(404).json({
        success: false,
        message: 'Driver not found',
      });
    }

    return res.status(200).json({
      success: true,
      message: `Driver status updated to ${targetStatus}`,
      data: {
        driverId: driver._id,
        status: driver.status,
        online: driver.status === 'online',
      },
    });
  } catch (err) {
    console.error('updateStatus error:', err);
    return res.status(500).json({
      success: false,
      message: 'Server error updating driver status',
      error: err.message,
    });
  }
};

/**
 * GET /api/driver/status
 * Get current driver online/offline status
 */
exports.getStatus = async (req, res) => {
  try {
    const driverId = req.driver ? req.driver._id : null;

    if (!driverId) {
      return res.status(401).json({
        success: false,
        message: 'Unauthorized',
      });
    }

    const driver = await Driver.findById(driverId);
    if (!driver) {
      return res.status(404).json({ success: false, message: 'Driver not found' });
    }

    return res.status(200).json({
      success: true,
      data: {
        driverId: driver._id,
        status: driver.status,
        online: driver.status === 'online',
      },
    });
  } catch (err) {
    console.error('getStatus error:', err);
    return res.status(500).json({
      success: false,
      message: 'Server error getting driver status',
      error: err.message,
    });
  }
};
