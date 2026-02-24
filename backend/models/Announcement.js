const mongoose = require('mongoose');

const announcementSchema = mongoose.Schema(
  {
    message: {
      type: String,
      required: true,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  { timestamps: true }
);

const Announcement = mongoose.model('Announcement', announcementSchema);
module.exports = Announcement;
