const express = require('express');
const router = express.Router();
const { callNext, updateCounterStatus } = require('../controllers/adminController');

router.post('/call-next', callNext);
router.patch('/counter-status/:counterId', updateCounterStatus);

module.exports = router;
