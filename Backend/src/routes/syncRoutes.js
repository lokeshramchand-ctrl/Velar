const express = require('express');
const { syncGmail } = require('../controllers/syncController');

const router = express.Router();

router.post('/', syncGmail);

module.exports = router;
