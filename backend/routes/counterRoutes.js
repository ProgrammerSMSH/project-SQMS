const express = require('express');
const router = express.Router();
const { getCounters, createCounter, updateCounterStatus, callNextToken, completeToken, setNoShowToken, updateCounter, deleteCounter } = require('../controllers/counterController');
const { protect, admin } = require('../middlewares/authMiddleware');

router.route('/')
  .get(protect, admin, getCounters)
  .post(protect, admin, createCounter);

router.put('/:id/status', protect, admin, updateCounterStatus);
router.post('/:id/call-next', protect, admin, callNextToken);
router.post('/:id/complete', protect, admin, completeToken);
router.post('/:id/no-show', protect, admin, setNoShowToken);

router.route('/:id')
  .put(protect, admin, updateCounter)
  .delete(protect, admin, deleteCounter);

module.exports = router;
