const User = require('../models/User');
const generateToken = require('../utils/generateToken');

// @desc    Register a new user
// @route   POST /api/v1/user/auth/register
// @access  Public
const registerUser = async (req, res, next) => {
  try {
    const { name, email, password, phone } = req.body;

    const userExists = await User.findOne({ email });

    if (userExists) {
      res.status(400);
      throw new Error('User already exists');
    }

    const user = await User.create({
      name,
      email,
      password,
      phone,
    });

    if (user) {
      res.status(201).json({
        _id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        token: generateToken(user._id),
      });
    } else {
      res.status(400);
      throw new Error('Invalid user data');
    }
  } catch (error) {
    next(error);
  }
};

// @desc    Auth user / Login
// @route   POST /api/v1/user/auth/login
// @access  Public
const authUser = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });

    if (user && (await user.matchPassword(password))) {
      res.json({
        _id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        token: generateToken(user._id),
      });
    } else {
      res.status(401);
      throw new Error('Invalid email or password');
    }
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
      const { email, password } = req.body;
  
      const user = await User.findOne({ email, role: 'ADMIN' });
  
      if (user && (await user.matchPassword(password))) {
        res.json({
          _id: user._id,
          name: user.name,
          email: user.email,
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

module.exports = { registerUser, authUser, registerFcmToken, authAdmin };
