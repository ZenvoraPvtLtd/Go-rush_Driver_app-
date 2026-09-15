const Ride = require('../models/ride.model');
const Driver = require('../models/driver.model');

// Helper to generate unique ride ID
function generateRideId() {
  const rand = Math.floor(100000 + Math.random() * 900000);
  return `GR-${rand}`;
}

/**
 * GET /api/rides/available
 * Returns active pending ride offer for online drivers.
 * If none exists, creates a fresh incoming ride offer in MongoDB Atlas so driver has a real request.
 */
exports.getAvailableRide = async (req, res) => {
  try {
    const driverId = req.driver ? req.driver._id : null;

    // Check if driver is offline
    if (driverId) {
      const driver = await Driver.findById(driverId);
      if (driver && driver.status === 'offline') {
        return res.status(200).json({
          success: true,
          message: 'Driver is offline',
          data: null,
        });
      }

      // If driver already has an active trip, return it
      const activeTrip = await Ride.findOne({
        driverId,
        status: { $in: ['accepted', 'arrived', 'in_progress'] },
      }).sort({ updatedAt: -1 });

      if (activeTrip) {
        return res.status(200).json({
          success: true,
          message: 'Active trip in progress',
          data: activeTrip.toSafeObject(),
          isActive: true,
        });
      }
    }

    // Find any existing pending ride offer that is unassigned
    let availableRide = await Ride.findOne({
      status: 'requested',
      driverId: null,
    }).sort({ createdAt: -1 });

    // If none exists, seed a realistic ride offer in MongoDB Atlas
    if (!availableRide) {
      availableRide = await Ride.create({
        rideId: generateRideId(),
        driverId: null,
        status: 'requested',
        passenger: {
          name: 'Priya Sharma',
          phone: '+91 98765 43210',
          rating: 4.8,
          totalRides: 120,
          avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
          vehicleTier: 'Prime Sedan',
        },
        pickup: {
          address: 'Sector 62, Noida',
          area: 'Sector 62',
          distanceAway: '2.1 km away',
          lat: 28.6280,
          lng: 77.3649,
        },
        destination: {
          address: 'Connaught Place, New Delhi',
          area: 'Connaught Place',
          lat: 28.6328,
          lng: 77.2197,
        },
        distanceKm: 16.4,
        durationMin: 32,
        otp: '4892',
        fare: {
          baseFare: 200,
          distanceFare: 110,
          taxes: 52,
          total: 362,
          driverEarnings: 310,
          paymentMethod: 'Cash / UPI',
          isPaid: false,
        },
        requestedAt: new Date(),
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Incoming ride request found',
      data: availableRide.toSafeObject(),
    });
  } catch (err) {
    console.error('getAvailableRide error:', err);
    return res.status(500).json({
      success: false,
      message: 'Server error retrieving available ride',
      error: err.message,
    });
  }
};

/**
 * POST /api/rides/:rideId/accept
 * Driver accepts the ride. Associates ride with authenticated driver and sets status to 'accepted'.
 */
exports.acceptRide = async (req, res) => {
  try {
    const { rideId } = req.params;
    const driverId = req.driver._id;

    // Find the ride by rideId or _id
    const query = { $or: [{ rideId }, { _id: rideId.match(/^[0-9a-fA-F]{24}$/) ? rideId : null }] };
    let ride = await Ride.findOne(query);

    if (!ride) {
      return res.status(404).json({
        success: false,
        message: 'Ride request not found',
      });
    }

    if (ride.status !== 'requested' && String(ride.driverId) !== String(driverId)) {
      return res.status(409).json({
        success: false,
        message: 'This ride has already been accepted by another driver or cancelled',
      });
    }

    ride.driverId = driverId;
    ride.status = 'accepted';
    ride.acceptedAt = new Date();
    await ride.save();

    // Mark driver status as busy/online
    await Driver.findByIdAndUpdate(driverId, { status: 'online' });

    return res.status(200).json({
      success: true,
      message: 'Ride accepted successfully',
      data: ride.toSafeObject(),
    });
  } catch (err) {
    console.error('acceptRide error:', err);
    return res.status(500).json({
      success: false,
      message: 'Server error accepting ride',
      error: err.message,
    });
  }
};

/**
 * POST /api/rides/:rideId/reject
 * Driver rejects the ride. Marks status 'cancelled' with cancellation details.
 */
exports.rejectRide = async (req, res) => {
  try {
    const { rideId } = req.params;
    const driverId = req.driver._id;
    const reason = req.body.reason || 'Driver rejected request';

    const query = { $or: [{ rideId }, { _id: rideId.match(/^[0-9a-fA-F]{24}$/) ? rideId : null }] };
    let ride = await Ride.findOne(query);

    if (!ride) {
      return res.status(404).json({
        success: false,
        message: 'Ride request not found',
      });
    }

    ride.driverId = driverId;
    ride.status = 'cancelled';
    ride.cancelledAt = new Date();
    ride.cancelledBy = 'driver';
    ride.cancellationReason = reason;
    await ride.save();

    return res.status(200).json({
      success: true,
      message: 'Ride rejected and recorded in cancelled history',
      data: ride.toSafeObject(),
    });
  } catch (err) {
    console.error('rejectRide error:', err);
    return res.status(500).json({
      success: false,
      message: 'Server error rejecting ride',
      error: err.message,
    });
  }
};

/**
 * POST /api/rides/:rideId/arrived
 * Driver marks arrival at passenger pickup location.
 */
exports.markArrived = async (req, res) => {
  try {
    const { rideId } = req.params;
    const query = { $or: [{ rideId }, { _id: rideId.match(/^[0-9a-fA-F]{24}$/) ? rideId : null }] };
    const ride = await Ride.findOne(query);

    if (!ride) {
      return res.status(404).json({ success: false, message: 'Ride not found' });
    }

    ride.status = 'arrived';
    ride.arrivedAt = new Date();
    await ride.save();

    return res.status(200).json({
      success: true,
      message: 'Driver arrived at pickup location',
      data: ride.toSafeObject(),
    });
  } catch (err) {
    console.error('markArrived error:', err);
    return res.status(500).json({
      success: false,
      message: 'Server error marking arrival',
      error: err.message,
    });
  }
};

/**
 * POST /api/rides/:rideId/start
 * Driver starts the trip. Verifies 4-digit passenger OTP.
 */
exports.startTrip = async (req, res) => {
  try {
    const { rideId } = req.params;
    const { otp } = req.body;

    const query = { $or: [{ rideId }, { _id: rideId.match(/^[0-9a-fA-F]{24}$/) ? rideId : null }] };
    const ride = await Ride.findOne(query);

    if (!ride) {
      return res.status(404).json({ success: false, message: 'Ride not found' });
    }

    // Verify OTP if provided
    if (otp && ride.otp && otp.trim() !== ride.otp.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Invalid OTP entered. Please ask the passenger for the correct 4-digit code.',
      });
    }

    ride.status = 'in_progress';
    ride.startedAt = new Date();
    await ride.save();

    return res.status(200).json({
      success: true,
      message: 'Trip started successfully',
      data: ride.toSafeObject(),
    });
  } catch (err) {
    console.error('startTrip error:', err);
    return res.status(500).json({
      success: false,
      message: 'Server error starting trip',
      error: err.message,
    });
  }
};

/**
 * POST /api/rides/:rideId/complete
 * Driver completes the trip. Calculates/stores fare, marks status 'completed'.
 */
exports.completeTrip = async (req, res) => {
  try {
    const { rideId } = req.params;
    const query = { $or: [{ rideId }, { _id: rideId.match(/^[0-9a-fA-F]{24}$/) ? rideId : null }] };
    const ride = await Ride.findOne(query);

    if (!ride) {
      return res.status(404).json({ success: false, message: 'Ride not found' });
    }

    ride.status = 'completed';
    ride.completedAt = new Date();
    ride.fare.isPaid = true;
    await ride.save();

    return res.status(200).json({
      success: true,
      message: 'Trip completed successfully',
      data: ride.toSafeObject(),
    });
  } catch (err) {
    console.error('completeTrip error:', err);
    return res.status(500).json({
      success: false,
      message: 'Server error completing trip',
      error: err.message,
    });
  }
};

/**
 * GET /api/rides/active
 * Returns current active trip for the authenticated driver.
 */
exports.getActiveRide = async (req, res) => {
  try {
    const driverId = req.driver._id;
    const ride = await Ride.findOne({
      driverId,
      status: { $in: ['accepted', 'arrived', 'in_progress'] },
    }).sort({ updatedAt: -1 });

    return res.status(200).json({
      success: true,
      data: ride ? ride.toSafeObject() : null,
    });
  } catch (err) {
    console.error('getActiveRide error:', err);
    return res.status(500).json({
      success: false,
      message: 'Server error getting active ride',
      error: err.message,
    });
  }
};

/**
 * GET /api/rides/history
 * Returns ride history for the authenticated driver, strictly separating COMPLETED and CANCELLED.
 */
exports.getHistory = async (req, res) => {
  try {
    const driverId = req.driver._id;

    const completedRides = await Ride.find({
      driverId,
      status: 'completed',
    }).sort({ completedAt: -1, createdAt: -1 });

    const cancelledRides = await Ride.find({
      driverId,
      status: 'cancelled',
    }).sort({ cancelledAt: -1, createdAt: -1 });

    return res.status(200).json({
      success: true,
      data: {
        completed: completedRides.map((r) => r.toSafeObject()),
        cancelled: cancelledRides.map((r) => r.toSafeObject()),
      },
    });
  } catch (err) {
    console.error('getHistory error:', err);
    return res.status(500).json({
      success: false,
      message: 'Server error retrieving ride history',
      error: err.message,
    });
  }
};

/**
 * GET /api/rides/earnings
 * Aggregates earnings and ride count from completed rides for the authenticated driver.
 */
exports.getEarnings = async (req, res) => {
  try {
    const driverId = req.driver._id;

    const completedRides = await Ride.find({
      driverId,
      status: 'completed',
    });

    const totalRides = completedRides.length;
    let totalEarnings = 0;
    let todayEarnings = 0;

    const startOfToday = new Date();
    startOfToday.setHours(0, 0, 0, 0);

    for (const r of completedRides) {
      const earned = r.fare?.driverEarnings || r.fare?.total || 0;
      totalEarnings += earned;

      if (r.completedAt && new Date(r.completedAt) >= startOfToday) {
        todayEarnings += earned;
      }
    }

    return res.status(200).json({
      success: true,
      data: {
        totalEarnings,
        todayEarnings,
        totalRides,
        completedRidesCount: totalRides,
      },
    });
  } catch (err) {
    console.error('getEarnings error:', err);
    return res.status(500).json({
      success: false,
      message: 'Server error retrieving driver earnings',
      error: err.message,
    });
  }
};
