const express = require('express');
const router = express.Router();
const { registerUser, authUser, registerFcmToken, authAdmin } = require('../controllers/authController');
const { protect } = require('../middlewares/authMiddleware');

// User Auth Routes
router.post('/user/auth/register', registerUser);
router.post('/user/auth/login', authUser);
router.post('/user/auth/fcm-token', protect, registerFcmToken);

// Admin Auth Routes
router.post('/admin/auth/login', authAdmin);

module.exports = router;
