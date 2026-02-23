const express = require('express');
const router = express.Router();
const serviceController = require('../controllers/serviceController');

router.get('/location/:locationId', serviceController.getServicesByLocation);

module.exports = router;
