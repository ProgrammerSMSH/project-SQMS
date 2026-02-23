const mongoose = require('mongoose');

const counterSchema = mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
    },
    status: {
      type: String,
      enum: ['ACTIVE', 'PAUSED', 'CLOSED'],
      default: 'CLOSED',
    },
    assignedAdminId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null,
    },
    servingTokenId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Token',
      default: null,
    },
  },
  { timestamps: true }
);

const Counter = mongoose.model('Counter', counterSchema);
module.exports = Counter;
