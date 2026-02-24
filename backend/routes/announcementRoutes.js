const express = require('express');
const router = express.Router();
const {
  getAnnouncements,
  getActiveAnnouncements,
  createAnnouncement,
  updateAnnouncement,
  deleteAnnouncement,
} = require('../controllers/announcementController');
const { protect, admin } = require('../middlewares/authMiddleware');

router.route('/')
  .get(getAnnouncements)
  .post(protect, admin, createAnnouncement);

router.get('/active', getActiveAnnouncements);

router.route('/:id')
  .put(protect, admin, updateAnnouncement)
  .delete(protect, admin, deleteAnnouncement);

module.exports = router;
