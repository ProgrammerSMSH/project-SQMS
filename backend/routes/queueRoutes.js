const express = require('express');
const router = express.Router();
const { getQueues, createQueue } = require('../controllers/queueController');
const { protect, admin } = require('../middlewares/authMiddleware');

router.route('/')
  .get(getQueues)
  .post(protect, admin, createQueue);

module.exports = router;
