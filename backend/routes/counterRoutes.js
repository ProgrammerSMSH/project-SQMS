const express = require('express');
const router = express.Router();
const { getCounters, createCounter, updateCounterStatus, callNextToken, completeToken, setNoShowToken, updateCounter, deleteCounter } = require('../controllers/counterController');
const { protect, admin, adminOrStaff } = require('../middlewares/authMiddleware');

router.route('/')
  .get(protect, adminOrStaff, getCounters)
  .post(protect, admin, createCounter);

router.put('/:id/status', protect, adminOrStaff, updateCounterStatus);
router.post('/:id/call-next', protect, adminOrStaff, callNextToken);
router.post('/:id/complete', protect, adminOrStaff, completeToken);
router.post('/:id/no-show', protect, adminOrStaff, setNoShowToken);

router.route('/:id')
  .put(protect, admin, updateCounter)
  .delete(protect, admin, deleteCounter);

module.exports = router;
