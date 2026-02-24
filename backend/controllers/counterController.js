const Counter = require('../models/Counter');
const Token = require('../models/Token');
const { sendPushNotification } = require('../utils/fcmService');

// Internal Helper: Check if user can manage this counter
const checkCounterAccess = (user, counter) => {
    if (user.role === 'ADMIN') return true;
    if (user.role === 'STAFF' && counter.assignedStaffId && counter.assignedStaffId.toString() === user._id.toString()) return true;
    return false;
};

// @desc    Get all counters
// @route   GET /api/v1/counters
// @access  Private/Admin
const getCounters = async (req, res, next) => {
  try {
    const counters = await Counter.find({}).populate('servingTokenId').populate('assignedStaffId', 'name email');
    res.json(counters);
  } catch (error) {
    next(error);
  }
};

// @desc    Create a new counter
// @route   POST /api/v1/counters
// @access  Private/Admin
const createCounter = async (req, res, next) => {
  try {
    const { name, assignedStaffId } = req.body;
    const counter = await Counter.create({ name, assignedStaffId });
    res.status(201).json(counter);
  } catch (error) {
    next(error);
  }
};

// @desc    Update counter status (ACTIVE, PAUSED, CLOSED)
// @route   PUT /api/v1/counters/:id/status
// @access  Private/Admin
const updateCounterStatus = async (req, res, next) => {
  try {
    const { status } = req.body;
    const counter = await Counter.findById(req.params.id);

    if (!counter) {
      res.status(404);
      throw new Error('Counter not found');
    }

    if (!['ACTIVE', 'PAUSED', 'CLOSED'].includes(status)) {
        res.status(400);
        throw new Error('Invalid status');
    }

    counter.status = status;
    // If activating, assign this admin
    if (status === 'ACTIVE') {
        counter.assignedAdminId = req.user._id;
    } else if (status === 'CLOSED') {
        counter.assignedAdminId = null;
    }

    await counter.save();
    res.json(counter);
  } catch (error) {
    next(error);
  }
};

// @desc    Call next token in priority order
// @route   POST /api/v1/counters/:id/call-next
// @access  Private/Admin
const callNextToken = async (req, res, next) => {
  try {
    const { queueId } = req.body;

    const counter = await Counter.findById(req.params.id);
    if (!counter || counter.status !== 'ACTIVE') {
      res.status(400);
      throw new Error('Counter not active or not found');
    }

    if (!checkCounterAccess(req.user, counter)) {
        res.status(401);
        throw new Error('Unauthorized to manage this counter');
    }

    // Previous token logic: if serving, ensure it's completed or no_show'd first.
    // For simplicity, we just forcefully clear it here, or require admin to hit complete.
    // We'll assume admin hit complete/no-show before calling next.

    // Priority loop
    const priorities = ['EMERGENCY', 'SENIOR', 'GENERAL', 'NORMAL'];
    let nextToken = null;

    for (let p of priorities) {
      let query = { status: 'WAITING', priority: p };
      if (queueId) query.queueId = queueId; // Filter by queue if specified in req

      nextToken = await Token.findOne(query).sort({ joinedAt: 1 }).populate('userId');
      if (nextToken) break;
    }

    if (!nextToken) {
      res.status(404);
      throw new Error('No tokens waiting in queue');
    }

    // Mark Token as SERVING
    nextToken.status = 'SERVING';
    nextToken.servedAt = Date.now();
    nextToken.counterId = counter._id;
    await nextToken.save();

    // Update Counter
    counter.servingTokenId = nextToken._id;
    await counter.save();

    // 2. FCM & Socket: Notify the person who is CALLED
    if (nextToken.userId.fcmTokens && nextToken.userId.fcmTokens.length > 0) {
      await sendPushNotification(
        nextToken.userId.fcmTokens,
        "It's your turn! ✅",
        `Token ${nextToken.tokenNumber}. Please proceed to ${counter.name} immediately.`
      );
    }
    
    // 3. FCM: Notify the person at Position #4 (3 people ahead)
    const upcomingTokens = await Token.find({ queueId: nextToken.queueId, status: 'WAITING' })
      .sort({ joinedAt: 1 })
      .limit(4)
      .populate('userId');

    if (upcomingTokens.length === 4) {
      const targetUser = upcomingTokens[3].userId; // Intentionally 0-indexed, 4th person
      if (targetUser.fcmTokens && targetUser.fcmTokens.length > 0) {
         await sendPushNotification(
           targetUser.fcmTokens,
           "Your turn is approaching! 🔔",
           "There are only 3 people ahead of you. Please head towards the waiting area."
         );
      }
    }

    res.json(nextToken);
  } catch (error) {
    next(error);
  }
};

// @desc    Mark current token as COMPLETED
// @route   POST /api/v1/counters/:id/complete
// @access  Private/Admin
const completeToken = async (req, res, next) => {
  try {
    const counter = await Counter.findById(req.params.id);
    if (!counter || !counter.servingTokenId) {
      res.status(400);
      throw new Error('Counter is not serving any token');
    }

    if (!checkCounterAccess(req.user, counter)) {
        res.status(401);
        throw new Error('Unauthorized to manage this counter');
    }

    const token = await Token.findById(counter.servingTokenId);
    if (token) {
        token.status = 'COMPLETED';
        token.completedAt = Date.now();
        await token.save();
    }

    counter.servingTokenId = null;
    await counter.save();

    res.json({ message: 'Token completed', token });
  } catch (error) {
    next(error);
  }
};

// @desc    Mark current token as NO_SHOW
// @route   POST /api/v1/counters/:id/no-show
// @access  Private/Admin
const setNoShowToken = async (req, res, next) => {
    try {
      const counter = await Counter.findById(req.params.id);
      if (!counter || !counter.servingTokenId) {
        res.status(400);
        throw new Error('Counter is not serving any token');
      }

      if (!checkCounterAccess(req.user, counter)) {
        res.status(401);
        throw new Error('Unauthorized to manage this counter');
      }
  
      const token = await Token.findById(counter.servingTokenId);
      if (token) {
          token.status = 'NO_SHOW';
          await token.save();
      }
  
      counter.servingTokenId = null;
      await counter.save();
  
      res.json({ message: 'Token marked as No Show', token });
    } catch (error) {
      next(error);
    }
  };

// @desc    Update a counter (Admin)
// @route   PUT /api/v1/counters/:id
// @access  Private/Admin
const updateCounter = async (req, res, next) => {
  try {
    const { name, status, assignedStaffId } = req.body;
    const counter = await Counter.findById(req.params.id);

    if (!counter) {
      res.status(404);
      throw new Error('Counter not found');
    }

    if (name) counter.name = name;
    if (assignedStaffId !== undefined) counter.assignedStaffId = assignedStaffId;
    if (status) {
      if (!['ACTIVE', 'PAUSED', 'CLOSED', 'INACTIVE'].includes(status)) {
        res.status(400);
        throw new Error('Invalid status');
      }
      counter.status = status;
    }

    const updatedCounter = await counter.save();
    res.json(updatedCounter);
  } catch (error) {
    next(error);
  }
};

// @desc    Delete a counter (Admin)
// @route   DELETE /api/v1/counters/:id
// @access  Private/Admin
const deleteCounter = async (req, res, next) => {
  try {
    const counter = await Counter.findById(req.params.id);

    if (!counter) {
      res.status(404);
      throw new Error('Counter not found');
    }

    await counter.deleteOne();
    res.json({ message: 'Counter removed' });
  } catch (error) {
    next(error);
  }
};

module.exports = { getCounters, createCounter, updateCounterStatus, callNextToken, completeToken, setNoShowToken, updateCounter, deleteCounter };
