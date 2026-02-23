const express = require('express');
const router = express.Router();
const { generateToken, getActiveTokens, getTokenHistory, cancelToken } = require('../controllers/tokenController');
const { protect } = require('../middlewares/authMiddleware');

router.post('/generate', protect, generateToken);
router.get('/active', protect, getActiveTokens);
router.get('/history', protect, getTokenHistory);
router.post('/:id/cancel', protect, cancelToken);

module.exports = router;
