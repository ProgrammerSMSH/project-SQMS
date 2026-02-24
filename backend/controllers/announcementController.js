const Announcement = require('../models/Announcement');

// @desc    Get all announcements
// @route   GET /api/v1/announcements
// @access  Public
const getAnnouncements = async (req, res, next) => {
  try {
    const announcements = await Announcement.find({}).sort({ createdAt: -1 });
    res.json(announcements);
  } catch (error) {
    next(error);
  }
};

// @desc    Get active announcements
// @route   GET /api/v1/announcements/active
// @access  Public
const getActiveAnnouncements = async (req, res, next) => {
  try {
    const announcements = await Announcement.find({ isActive: true }).sort({ createdAt: -1 });
    res.json(announcements);
  } catch (error) {
    next(error);
  }
};

// @desc    Create a new announcement
// @route   POST /api/v1/announcements
// @access  Private/Admin
const createAnnouncement = async (req, res, next) => {
  try {
    const { message, isActive } = req.body;
    const announcement = await Announcement.create({ message, isActive });
    res.status(201).json(announcement);
  } catch (error) {
    next(error);
  }
};

// @desc    Update an announcement
// @route   PUT /api/v1/announcements/:id
// @access  Private/Admin
const updateAnnouncement = async (req, res, next) => {
  try {
    const { message, isActive } = req.body;
    const announcement = await Announcement.findById(req.params.id);

    if (!announcement) {
      res.status(404);
      throw new Error('Announcement not found');
    }

    if (message !== undefined) announcement.message = message;
    if (isActive !== undefined) announcement.isActive = isActive;

    const updatedAnnouncement = await announcement.save();
    res.json(updatedAnnouncement);
  } catch (error) {
    next(error);
  }
};

// @desc    Delete an announcement
// @route   DELETE /api/v1/announcements/:id
// @access  Private/Admin
const deleteAnnouncement = async (req, res, next) => {
  try {
    const announcement = await Announcement.findById(req.params.id);

    if (!announcement) {
      res.status(404);
      throw new Error('Announcement not found');
    }

    await announcement.deleteOne();
    res.json({ message: 'Announcement removed' });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAnnouncements,
  getActiveAnnouncements,
  createAnnouncement,
  updateAnnouncement,
  deleteAnnouncement,
};
