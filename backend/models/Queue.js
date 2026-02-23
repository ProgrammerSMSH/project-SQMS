const mongoose = require('mongoose');

const queueSchema = mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
    },
    code: {
      type: String,
      required: true,
      unique: true,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    avgWaitTimePerToken: {
      type: Number,
      required: true,
      default: 5, // in minutes
    },
  },
  { timestamps: true }
);

const Queue = mongoose.model('Queue', queueSchema);
module.exports = Queue;
