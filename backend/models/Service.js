const mongoose = require('mongoose');

const ServiceSchema = new mongoose.Schema({
    locationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Location', required: true },
    name: { type: String, required: true },
    description: { type: String },
    counterPrefix: { type: String, default: 'A' },
    avgServiceTime: { type: Number, default: 10 }, // in minutes
    isActive: { type: Boolean, default: true }
}, { timestamps: true });

module.exports = mongoose.model('Service', ServiceSchema);
