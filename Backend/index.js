require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const axios = require('axios');
const cors = require('cors');

const app = express();

/* ---------- MIDDLEWARE ---------- */
app.use(express.json());
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*'
}));

/* ---------- DATABASE ---------- */
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.error(err));

/* ---------- MODEL ---------- */
const transactionSchema = new mongoose.Schema({
  text: { type: String, required: true },          // raw input (important for ML)
  amount: Number,
  merchant: String,
  category: { type: String, default: 'Other' },
  confidence: Number,
  date: { type: Date, default: Date.now },
  source: { type: String, enum: ['manual', 'voice'], required: true }
});

const Transaction = mongoose.model('Transaction', transactionSchema);

/* ---------- SERVICES ---------- */
async function predict(text) {
  const res = await axios.post(
    `http://${process.env.PREDICT_API_HOST}/api/predict`,
    { text }
  );

  return res.data; // expected: { amount, merchant, category, confidence }
}

/* ---------- ROUTES ---------- */

/**
 * Add transaction (manual input)
 */
app.post('/api/transaction', async (req, res) => {
  try {
    const { text } = req.body;

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
      source: 'manual'
    });

    await transaction.save();

    res.json({ success: true, data: transaction });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * Voice input (same pipeline, just labeled differently)
 */
app.post('/api/transaction/voice', async (req, res) => {
  try {
    const { voiceInput } = req.body;

    if (!voiceInput) {
      return res.status(400).json({ error: 'Voice input is required' });
    }

    const prediction = await predict(voiceInput);

    const transaction = new Transaction({
      text: voiceInput,
      amount: prediction.amount,
      merchant: prediction.merchant,
      category: prediction.category || 'Other',
      confidence: prediction.confidence,
      source: 'voice'
    });

    await transaction.save();

    res.json({ success: true, data: transaction });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * Get all transactions
 */
app.get('/api/transactions', async (req, res) => {
  try {
    const data = await Transaction.find().sort({ date: -1 });
    res.json({ success: true, data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * Direct prediction endpoint (for experiments)
 */
app.post('/api/predict', async (req, res) => {
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
});

/**
 * Dataset export (VERY IMPORTANT for research)
 */
app.get('/api/dataset', async (req, res) => {
  try {
    const data = await Transaction.find();
    res.json({ count: data.length, data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/* ---------- SERVER ---------- */
const HOST = process.env.HOST || '0.0.0.0';
const PORT = process.env.PORT || 3000;

app.listen(PORT, HOST, () => {
  console.log(`Server running at http://${HOST}:${PORT}`);
});

