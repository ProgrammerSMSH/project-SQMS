const Token = require('../models/Token');
const Queue = require('../models/Queue');

// @desc    Generate a new token
// @route   POST /api/v1/tokens/generate
// @access  Private
const generateToken = async (req, res, next) => {
  try {
    const { queueId, priority } = req.body;
    const userId = req.user._id;

    const queue = await Queue.findById(queueId);
    if (!queue) {
      res.status(404);
      throw new Error('Queue not found');
    }

    // Check if user already has an active token in this queue
    const activeToken = await Token.findOne({
      userId,
      queueId,
      status: { $in: ['WAITING', 'SERVING'] },
    });

    if (activeToken) {
      res.status(400);
      throw new Error('You already have an active token in this queue');
    }

    // Count currently waiting tokens to calculate estimated time and token number
    const waitingTokensCount = await Token.countDocuments({
      queueId,
      status: 'WAITING',
    });

    const tokenNumber = `${queue.code}-${Date.now().toString().slice(-4)}`;
    
    // Simple estimation: waiting users * avg time
    const estimatedWaitTime = waitingTokensCount * queue.avgWaitTimePerToken;

    const token = await Token.create({
      userId,
      queueId,
      tokenNumber,
      priority: priority || 'NORMAL',
      estimatedWaitTime,
    });

    res.status(201).json(token);
  } catch (error) {
    next(error);
  }
};

// @desc    Get user's active tokens
// @route   GET /api/v1/tokens/active
// @access  Private
const getActiveTokens = async (req, res, next) => {
  try {
    const tokens = await Token.find({
      userId: req.user._id,
      status: { $in: ['WAITING', 'SERVING'] },
    }).populate('queueId', 'name code').populate('counterId', 'name');

    res.json(tokens);
  } catch (error) {
    next(error);
  }
};

// @desc    Get user's token history
// @route   GET /api/v1/tokens/history
// @access  Private
const getTokenHistory = async (req, res, next) => {
  try {
    const tokens = await Token.find({
      userId: req.user._id,
      status: { $in: ['COMPLETED', 'CANCELLED', 'NO_SHOW'] },
    }).sort({ createdAt: -1 }).populate('queueId', 'name');

    res.json(tokens);
  } catch (error) {
    next(error);
  }
};

// @desc    Cancel a token
// @route   POST /api/v1/tokens/:id/cancel
// @access  Private
const cancelToken = async (req, res, next) => {
  try {
    const token = await Token.findOne({ _id: req.params.id, userId: req.user._id });

    if (!token) {
      res.status(404);
      throw new Error('Token not found');
    }

    if (token.status !== 'WAITING') {
      res.status(400);
      throw new Error('Can only cancel waiting tokens');
    }

    token.status = 'CANCELLED';
    await token.save();

    res.json({ message: 'Token cancelled successfully' });
  } catch (error) {
    next(error);
  }
};


module.exports = { generateToken, getActiveTokens, getTokenHistory, cancelToken };
