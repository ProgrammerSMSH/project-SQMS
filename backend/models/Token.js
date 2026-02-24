const mongoose = require('mongoose');

const tokenSchema = mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    queueId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Queue',
      required: true,
    },
    tokenNumber: {
      type: String, // e.g., "GN-105"
      required: true,
    },
    status: {
      type: String,
      enum: ['WAITING', 'SERVING', 'COMPLETED', 'CANCELLED', 'NO_SHOW'],
      default: 'WAITING',
    },
    priority: {
      type: String,
      enum: ['GENERAL', 'SENIOR', 'EMERGENCY', 'NORMAL'],
      default: 'GENERAL',
    },
    counterId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Counter',
      default: null, // assigned when SERVING
    },
    joinedAt: {
      type: Date,
      default: Date.now,
    },
    servedAt: {
      type: Date,
      default: null,
    },
    completedAt: {
      type: Date,
      default: null,
    },
    estimatedWaitTime: {
      type: Number,
      required: true,
      default: 0, // In minutes at generation
    },
  },
  { timestamps: true }
);

const Token = mongoose.model('Token', tokenSchema);
module.exports = Token;
