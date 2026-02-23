const express = require('express');
const router = express.Router();
const { getQueues, createQueue, getWaitingTokens, getActiveStatus } = require('../controllers/queueController');
const { protect, admin } = require('../middlewares/authMiddleware');

router.route('/')
  .get(getQueues)
  .post(protect, admin, createQueue);

router.get('/:id/waiting', getWaitingTokens);
router.get('/:id/active-status', getActiveStatus); // New unified polling endpoint

module.exports = router;
