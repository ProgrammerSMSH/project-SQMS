const express = require('express');
const router = express.Router();
const { registerUser, authUser, registerFcmToken, authAdmin } = require('../controllers/authController');
const { protect } = require('../middlewares/authMiddleware');

// User Auth Routes
router.post('/register', registerUser);
router.post('/login', authUser);
router.post('/fcm-token', protect, registerFcmToken);

// Admin Auth Routes
router.post('/admin-login', authAdmin);

module.exports = router;
