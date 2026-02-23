const Location = require('../models/Location');

exports.getAllLocations = async (req, res) => {
    try {
        const locations = await Location.find();
        res.status(200).json({ success: true, count: locations.length, data: locations });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};
