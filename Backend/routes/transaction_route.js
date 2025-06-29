// routes/transactionroutes.js

const express = require('express');
const router = express.Router();
const axios = require('axios');
const Transaction = require('./models/transaction'); // ✅ lowercase filename

// Add transaction
router.post('/add', async (req, res) => {
  try {
    const { description, amount } = req.body;
    const predictRes = await axios.post('http://192.168.1.9:5000/api/predict', { description });
    const category = predictRes.data.category || 'Other';

    const newTransaction = new Transaction({ description, amount, category });
    await newTransaction.save();

    res.status(200).json({
      message: '✅ Transaction saved with category',
      data: newTransaction,
    });
  } catch (err) {
    console.error('❌ Error adding transaction:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// Update budget
router.post('/update', async (req, res) => {
  try {
    const { budget } = req.body;
    await BudgetModel.updateOne({}, { amount: budget }, { upsert: true });
    res.status(200).json({ success: true });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update budget' });
  }
});

// Get transactions
router.get('/', async (req, res) => {
  try {
    const category = req.query.category;
    let query = {};

    if (category && category !== 'All') {
      query.category = category;
    }

    const transactions = await Transaction.find(query).sort({ date: -1 });

    res.status(200).json({
      success: true,
      data: transactions.map(tx => ({
        id: tx._id,
        description: tx.description,
        amount: tx.amount,
        category: tx.category,
        date: tx.date,
      })),
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
