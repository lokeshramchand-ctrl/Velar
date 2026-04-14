
const Transaction = require('../models/Transaction');
const axios = require('axios');

/* ---------- SERVICE ---------- */
async function predict(text) {
  const res = await axios.post(
    `http://${process.env.PREDICT_API_HOST}/api/predict`,
    { text }
  );
  return res.data;
}



exports.createTransaction = async (req, res) => {
  try {
    const { text, source = 'manual' } = req.body;

    if (!text) {
      return res.status(400).json({ error: 'Text is required' });
    }

    const prediction = await predict(text);

    const transaction = new Transaction({
      text,
      amount: prediction.amount,
      merchant: prediction.merchant,
      category: prediction.category || 'Other',
      confidence: prediction.confidence,
      source
    });

    await transaction.save();

    res.json({ success: true, data: transaction });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/**
 * Get all transactions (dataset view)
 */
exports.getTransactions = async (req, res) => {
  try {
    const data = await Transaction.find().sort({ date: -1 });
    res.json({ success: true, data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/**
 * Predict only (no DB write)
 */
exports.predictOnly = async (req, res) => {
  try {
    const { text } = req.body;

    if (!text) {
      return res.status(400).json({ error: 'Text is required' });
    }

    const result = await predict(text);
    res.json(result);

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/**
 * Export dataset (for training/evaluation)
 */
exports.exportDataset = async (req, res) => {
  try {
    const data = await Transaction.find();
    res.json({ count: data.length, data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
