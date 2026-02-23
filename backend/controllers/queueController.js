const Queue = require('../models/Queue');

// @desc    Get all active queues
// @route   GET /api/v1/queues
// @access  Public
const getQueues = async (req, res, next) => {
  try {
    const queues = await Queue.find({ isActive: true });
    res.json(queues);
  } catch (error) {
    next(error);
  }
};

// @desc    Create a new queue (Admin)
// @route   POST /api/v1/queues
// @access  Private/Admin
const createQueue = async (req, res, next) => {
  try {
    const { name, code, avgWaitTimePerToken } = req.body;

    const queueExists = await Queue.findOne({ code });
    if (queueExists) {
      res.status(400);
      throw new Error('Queue code already exists');
    }

    const queue = await Queue.create({
      name,
      code,
      avgWaitTimePerToken,
    });

    res.status(201).json(queue);
  } catch (error) {
    next(error);
  }
};

// @desc    Get all waiting tokens for a queue
// @route   GET /api/v1/queues/:id/waiting
// @access  Public
const getWaitingTokens = async (req, res, next) => {
  try {
    const Token = require('../models/Token');
    const tokens = await Token.find({ 
      queueId: req.params.id, 
      status: 'WAITING' 
    }).sort({ joinedAt: 1 });
    res.json(tokens);
  } catch (error) {
    next(error);
  }
};

module.exports = { getQueues, createQueue, getWaitingTokens };

