const express = require('express');
const { addTransaction } = require('../controllers/transactionController');
const Transaction = require('../models/Transaction');
const nlpService = require('../services/nlpService');

const router = express.Router();

router.post('/add', addTransaction);

router.get('/', async (req, res) => {
  try {
    const { category, userId } = req.query;
    if (!userId) return res.status(400).json({ error: 'Missing userId' });

    let query = { userId };
    if (category && category !== 'All') query.category = category;

    const transactions = await Transaction.find(query).sort({ date: -1 });
    res.status(200).json({ success: true, data: transactions });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/recent', async (req, res) => {
  try {
    const { userId } = req.query;
    if (!userId) return res.status(400).json({ error: 'Missing userId' });

    const transactions = await Transaction.find({ userId })
      .sort({ date: -1 })
      .limit(5);

    res.status(200).json({ success: true, data: transactions });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
//VOICE
router.post('/voice', async (req, res) => {
  try {
    const { voiceInput, userId } = req.body;
    if (!voiceInput) return res.status(400).json({ error: 'No voice input provided' });
    if (!userId) return res.status(400).json({ error: 'Missing userId' });

    // Extract amount
    const amountMatch = voiceInput.match(/(?:\₹|\$)?(\d+(?:\.\d{1,2})?)/);
    const amount = amountMatch ? parseFloat(amountMatch[1]) : null;
    if (amount === null) return res.status(400).json({ error: 'Could not extract amount' });

    // Extract description
    const cleaned = voiceInput
      .toLowerCase()
      .replace(/(bought|added|paid|spent|for|on)/g, '')
      .replace(/₹?\d+/, '')
      .trim();
    const description = cleaned ? cleaned.charAt(0).toUpperCase() + cleaned.slice(1) : 'Misc';

    // Predict category
    let category = 'Other';
    try {
      category = await nlpService.predictCategory(description);
    } catch (err) {
      console.warn('NLP prediction failed, defaulting category to "Other"');
    }

    // Save transaction
    const newTransaction = new Transaction({
      userId,
      description,
      amount,
      category,
      source: 'voice',
    });
    await newTransaction.save();

    res.status(200).json({ message: 'Voice transaction saved', data: newTransaction });
  } catch (err) {
    console.error('Voice transaction error:', err);
    res.status(500).json({ error: 'Server error during voice transaction' });
  }
});

module.exports = router;
