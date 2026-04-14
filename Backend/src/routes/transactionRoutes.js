const express = require('express');
const transactionController = require('../controllers/transactionController');

const router = express.Router();

router.post('/add', transactionController.addTransaction);

router.get('/', transactionController.getTransactions);

router.get('/recent', transactionController.getRecentTransaction);

router.post('/voice', transactionController.voiceTransaction);


module.exports = router;
