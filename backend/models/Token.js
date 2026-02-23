const mongoose = require('mongoose');

const TokenSchema = new mongoose.Schema({
    userId: { type: String, required: true }, // Firebase UID
    serviceId: { type: mongoose.Schema.Types.ObjectId, ref: 'Service', required: true },
    counterId: { type: mongoose.Schema.Types.ObjectId, ref: 'Counter' },
    tokenNumber: { type: Number, required: true },
    status: { 
        type: String, 
        enum: ['Waiting', 'Serving', 'Completed', 'Cancelled'], 
        default: 'Waiting' 
    },
    priority: { type: Boolean, default: false },
    estimatedWaitTime: { type: Number }, // in minutes
    calledAt: { type: Date },
    completedAt: { type: Date }
}, { timestamps: true });

module.exports = mongoose.model('Token', TokenSchema);
