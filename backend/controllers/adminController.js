const Token = require('../models/Token');
const Counter = require('../models/Counter');

exports.callNext = async (req, res) => {
    try {
        const { counterId, serviceId } = req.body;

        // 1. Current ticket in this counter should be marked as completed if it exists
        const counter = await Counter.findById(counterId);
        if (counter.currentTicketId) {
            await Token.findByIdAndUpdate(counter.currentTicketId, { 
                status: 'Completed',
                completedAt: new Date()
            });
        }

        // 2. Find the next waiting token (Priority first, then FIFO)
        let nextTicket = await Token.findOne({
            serviceId,
            status: 'Waiting',
            priority: true
        }).sort({ createdAt: 1 });

        if (!nextTicket) {
            nextTicket = await Token.findOne({
                serviceId,
                status: 'Waiting',
                priority: false
            }).sort({ createdAt: 1 });
        }

        if (!nextTicket) {
            counter.currentTicketId = null;
            await counter.save();
            return res.status(200).json({ success: true, message: 'No more tickets in queue' });
        }

        // 3. Update ticket and counter
        nextTicket.status = 'Serving';
        nextTicket.counterId = counterId;
        nextTicket.calledAt = new Date();
        await nextTicket.save();

        counter.currentTicketId = nextTicket._id;
        counter.status = 'Active';
        await counter.save();

        // 4. Broadcast to everyone in the room
        const io = req.app.get('io');
        io.to(serviceId.toString()).emit('next_called', {
            counterNumber: counter.counterNumber,
            tokenNumber: nextTicket.tokenNumber,
            tokenId: nextTicket._id
        });

        res.status(200).json({
            success: true,
            data: nextTicket
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.updateCounterStatus = async (req, res) => {
    try {
        const { counterId } = req.params;
        const { status } = req.body;

        const counter = await Counter.findByIdAndUpdate(counterId, { status }, { new: true });
        res.status(200).json({ success: true, data: counter });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};
