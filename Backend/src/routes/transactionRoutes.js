const express = require('express');
const Transaction = require('../models/Transaction');
const { publishToQueue } = require('../config/rabbitmq'); 

const router = express.Router();

router.post('/add', async (req, res) => {
  try {
    const { description, amount, userId } = req.body;
    if (!userId) return res.status(400).json({ error: 'Missing userId' });
    await publishToQueue('manual-transactions', { description, amount, userId });


    res.status(200).json({ message: 'Transaction queued for processing' });
  } catch (err) {
    console.error('Manual transaction queue error:', err);
    res.status(500).json({ error: 'Failed to queue transaction' });
  }
}
);

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

    await publishToQueue('voice-transactions', { voiceInput, userId });

    res.status(200).json({ message: 'Voice transaction saved', data: newTransaction });
  } catch (err) {
    console.error('Voice transaction error:', err);
    res.status(500).json({ error: 'Server error during voice transaction' });
  }
});

module.exports = router;
