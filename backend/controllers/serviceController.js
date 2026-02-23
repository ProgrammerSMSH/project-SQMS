const Service = require('../models/Service');

exports.getServicesByLocation = async (req, res) => {
    try {
        const { locationId } = req.params;
        const services = await Service.find({ locationId });
        res.status(200).json({ success: true, count: services.length, data: services });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};
