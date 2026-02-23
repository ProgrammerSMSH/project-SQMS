const mongoose = require('mongoose');

const CounterSchema = new mongoose.Schema({
    serviceId: { type: mongoose.Schema.Types.ObjectId, ref: 'Service', required: true },
    counterNumber: { type: Number, required: true },
    staffId: { type: String }, // Placeholder for staff/admin user
    status: { 
        type: String, 
        enum: ['Active', 'Paused', 'Inactive'], 
        default: 'Inactive' 
    },
    currentTicketId: { type: mongoose.Schema.Types.ObjectId, ref: 'Token' }
}, { timestamps: true });

module.exports = mongoose.model('Counter', CounterSchema);
