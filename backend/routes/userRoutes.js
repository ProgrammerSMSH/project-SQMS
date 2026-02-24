const express = require('express');
const router = express.Router();
const { getStaffMembers, createStaffMember, deleteStaffMember } = require('../controllers/userController');
const { protect, admin } = require('../middlewares/authMiddleware');

router.route('/staff')
  .get(protect, admin, getStaffMembers)
  .post(protect, admin, createStaffMember);

router.route('/staff/:id')
  .delete(protect, admin, deleteStaffMember);

module.exports = router;
