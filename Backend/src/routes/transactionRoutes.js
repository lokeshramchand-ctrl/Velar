const express = require('express');
const transactionController = require('../controllers/transactionController');

const router = express.Router();

/**
 * Create transaction (manual / voice unified)
 */
router.post('/', transactionController.createTransaction);


 // Get all transactions (dataset view)

router.get('/', transactionController.getTransactions);

 //Direct prediction (no DB write) - for experiments

router.post('/predict', transactionController.predictOnly);


 //Export dataset (for training / evaluation)

router.get('/dataset', transactionController.exportDataset);

module.exports = router;
