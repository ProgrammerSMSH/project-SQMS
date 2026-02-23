const User = require('../models/User');
const generateToken = require('../utils/generateToken');

// @desc    Auth user / Login (Mocked OTP validation for now)
// @route   POST /api/v1/user/auth/login
// @access  Public
const authUser = async (req, res, next) => {
  try {
    const { phone, name } = req.body;

    if (!phone) {
      res.status(400);
      throw new Error('Please provide phone number');
    }

    // In a real app, verify OTP here. We are mocking OTP success and auto-registering if not exists.
    let user = await User.findOne({ phone });

    if (!user) {
      user = await User.create({
        phone,
        name: name || 'Guest User',
      });
    }

    res.json({
      _id: user._id,
      name: user.name,
      phone: user.phone,
      role: user.role,
      token: generateToken(user._id),
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Register device FCM token
// @route   POST /api/v1/user/auth/fcm-token
// @access  Private
const registerFcmToken = async (req, res, next) => {
  try {
    const { fcmToken } = req.body;
    
    if (!fcmToken) {
        res.status(400);
        throw new Error('FCM token is required');
    }

    const user = await User.findById(req.user._id);
    
    if (user) {
        if (!user.fcmTokens.includes(fcmToken)) {
            user.fcmTokens.push(fcmToken);
            await user.save();
        }
        res.json({ message: 'FCM Token registered successfully' });
    } else {
        res.status(404);
        throw new Error('User not found');
    }
  } catch (error) {
    next(error);
  }
};

// @desc    Admin Login setup 
// @route   POST /api/v1/admin/auth/login
// @access  Public
const authAdmin = async (req, res, next) => {
    try {
      const { phone } = req.body;
  
      const user = await User.findOne({ phone, role: 'ADMIN' });
  
      if (user) {
        res.json({
          _id: user._id,
          name: user.name,
          phone: user.phone,
          role: user.role,
          token: generateToken(user._id),
        });
      } else {
        res.status(401);
        throw new Error('Invalid Admin credentials');
      }
    } catch (error) {
      next(error);
    }
};

module.exports = { authUser, registerFcmToken, authAdmin };
