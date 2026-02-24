const Queue = require('../models/Queue');
const Token = require('../models/Token');
const Counter = require('../models/Counter');

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
    let tokens = await Token.find({ 
      queueId: req.params.id, 
      status: 'WAITING' 
    });

    const priorityMap = { 'EMERGENCY': 1, 'SENIOR': 2, 'GENERAL': 3, 'NORMAL': 3 };
    tokens.sort((a, b) => {
        const pA = priorityMap[a.priority] || 4;
        const pB = priorityMap[b.priority] || 4;
        if (pA !== pB) return pA - pB;
        return new Date(a.joinedAt) - new Date(b.joinedAt);
    });
    res.json(tokens);
  } catch (error) {
    next(error);
  }
};

// @desc    Get comprehensive active status for a queue (waiting tokens + serving counters)
// @route   GET /api/v1/queues/:id/active-status
// @access  Public (or protected depending on requirement, usually public for TV)
const getActiveStatus = async (req, res, next) => {
  try {
    const queueId = req.params.id;

    // 1. Get Waiting Tokens
    let waitingTokens = await Token.find({ queueId, status: 'WAITING' })
      .select('tokenNumber priority joinedAt'); // Need joinedAt for secondary sort

    // Sort by priority then by joinedAt
    const priorityMap = { 'EMERGENCY': 1, 'SENIOR': 2, 'GENERAL': 3, 'NORMAL': 3 };
    waitingTokens.sort((a, b) => {
        const pA = priorityMap[a.priority] || 4;
        const pB = priorityMap[b.priority] || 4;
        if (pA !== pB) return pA - pB;
        return new Date(a.joinedAt) - new Date(b.joinedAt);
    });

    // 2. Get Counters actively serving tokens from this queue
    // We populate the servingTokenId to get its tokenNumber
    const activeCounters = await Counter.find({ status: 'ACTIVE' })
        .populate({
            path: 'servingTokenId',
            match: { queueId: queueId },
            select: 'tokenNumber'
        })
        .select('name servingTokenId');
    
    // Filter out counters that aren't serving this queue or aren't serving anyone
    const servingData = activeCounters
        .filter(c => c.servingTokenId !== null)
        .map(c => ({
            counterName: c.name,
            tokenNumber: c.servingTokenId.tokenNumber
        }));

    res.json({
        waiting: waitingTokens,
        serving: servingData
    });
  } catch (error) {
    next(error);
  }
};

module.exports = { getQueues, createQueue, getWaitingTokens, getActiveStatus };

