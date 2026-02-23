const express = require('express');
const router = express.Router();
const { generateToken, getLiveStatus, cancelToken } = require('../controllers/tokenController');

router.post('/generate', generateToken);
router.get('/live/:serviceId', getLiveStatus);
router.patch('/cancel/:tokenId', cancelToken);

module.exports = router;
