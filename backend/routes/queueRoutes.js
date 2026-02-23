const express = require('express');
const router = express.Router();
const { getQueues, createQueue, getWaitingTokens } = require('../controllers/queueController');
const { protect, admin } = require('../middlewares/authMiddleware');

router.route('/')
  .get(getQueues)
  .post(protect, admin, createQueue);

router.get('/:id/waiting', getWaitingTokens);

module.exports = router;
