const mongoose = require('mongoose');

const LocationSchema = new mongoose.Schema({
    name: { type: String, required: true },
    type: { 
        type: String, 
        enum: ['Hospital', 'Bank', 'Office', 'Restaurant', 'Other'], 
        required: true 
    },
    address: { type: String, required: true },
    coordinates: {
        lat: { type: Number },
        lng: { type: Number }
    },
    imageUrl: { type: String },
    isActive: { type: Boolean, default: true }
}, { timestamps: true });

module.exports = mongoose.model('Location', LocationSchema);
