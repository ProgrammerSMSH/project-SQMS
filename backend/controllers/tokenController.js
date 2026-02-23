const Token = require('../models/Token');
const Service = require('../models/Service');
const Counter = require('../models/Counter');

exports.generateToken = async (req, res) => {
    try {
        const { userId, serviceId, priority } = req.body;

        // 1. Get the latest token number for this service today
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const latestToken = await Token.findOne({
            serviceId,
            createdAt: { $gte: today }
        }).sort({ tokenNumber: -1 });

        const nextNumber = latestToken ? latestToken.tokenNumber + 1 : 1;

        // 2. Calculate estimated wait time
        const service = await Service.findById(serviceId);
        const waitingTokens = await Token.countDocuments({
            serviceId,
            status: 'Waiting',
            createdAt: { $gte: today }
        });
        
        const estWaitTime = waitingTokens * (service.avgServiceTime || 10);

        // 3. Create new token
        const newToken = await Token.create({
            userId,
            serviceId,
            tokenNumber: nextNumber,
            priority: priority || false,
            estimatedWaitTime: estWaitTime
        });

        // 4. Emit real-time update via Socket.io
        const io = req.app.get('io');
        io.to(serviceId.toString()).emit('new_token', newToken);

        res.status(201).json({
            success: true,
            data: newToken
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.getLiveStatus = async (req, res) => {
    try {
        const { serviceId } = req.params;
        
        const currentServing = await Token.findOne({
            serviceId,
            status: 'Serving'
        }).sort({ updatedAt: -1 });

        const waitingCount = await Token.countDocuments({
            serviceId,
            status: 'Waiting'
        });

        res.status(200).json({
            success: true,
            currentServingNumber: currentServing ? currentServing.tokenNumber : null,
            waitingCount
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.cancelToken = async (req, res) => {
    try {
        const { tokenId } = req.params;
        const token = await Token.findByIdAndUpdate(tokenId, { status: 'Cancelled' }, { new: true });
        
        if (!token) {
            return res.status(404).json({ success: false, error: 'Token not found' });
        }

        const io = req.app.get('io');
        io.to(token.serviceId.toString()).emit('token_cancelled', tokenId);

        res.status(200).json({ success: true, data: token });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};
