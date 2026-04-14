require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const axios = require('axios');
const cors = require('cors');

const app = express();
app.use(express.json());

app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true
}));

/* ---------- MODELS ---------- */
const userSchema = new mongoose.Schema({
  name: String,
  email: String,
  createdAt: { type: Date, default: Date.now }
});
const User = mongoose.model('User', userSchema);

const transactionSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  description: { type: String, required: true },
  amount: { type: Number, required: true },
  category: { type: String, default: "Other" },
  date: { type: Date, default: Date.now },
  type: { type: String, default: "unknown" },
  vendor: String,
  source: { type: String, enum: ['manual', 'voice', 'email'], required: true },
  referenceNumber: { type: String, unique: true, sparse: true },
});
const Transaction = mongoose.model('Transaction', transactionSchema);

/* ---------- DEV AUTH (NO OAUTH) ---------- */
app.use((req, res, next) => {
  req.user = {
    _id: "devuserid123",
    name: "Dev User",
    email: "dev@test.com"
  };
  next();
});

/* ---------- USER ROUTES ---------- */
app.get('/profile', (req, res) => {
  res.json({
    id: req.user._id,
    name: req.user.name,
    email: req.user.email
  });
});

/* ---------- TRANSACTION ROUTES ---------- */
app.post('/api/transaction/add', async (req, res) => {
  try {
    const userId = req.user._id;
    const { description, amount } = req.body;

    const predictRes = await axios.post(`http://${process.env.PREDICT_API_HOST}/api/predict`, {
      description,
    });

    const category = predictRes.data.category || 'Other';

    const newTransaction = new Transaction({
      userId,
      description,
      amount,
      category,
      source: 'manual',
    });

    await newTransaction.save();

    res.json({ message: 'Transaction saved', data: newTransaction });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/transactions', async (req, res) => {
  try {
    const userId = req.user._id;
    const { category } = req.query;

    let query = { userId };
    if (category && category !== 'All') query.category = category;

    const transactions = await Transaction.find(query).sort({ date: -1 });

    res.json({ success: true, data: transactions });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/transactions/recent', async (req, res) => {
  try {
    const userId = req.user._id;

    const transactions = await Transaction.find({ userId })
      .sort({ date: -1 })
      .limit(5);

    res.json({ success: true, data: transactions });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/* ---------- VOICE ---------- */
app.post('/api/transactions/voice', async (req, res) => {
  try {
    const userId = req.user._id;
    const { voiceInput } = req.body;

    const amountMatch = voiceInput.match(/(?:₹|\$)?(\d+(?:\.\d{1,2})?)/);
    const amount = amountMatch ? parseFloat(amountMatch[1]) : null;

    const cleaned = voiceInput
      .toLowerCase()
      .replace(/(bought|added|paid|spent|for|on)/g, '')
      .replace(/₹?\d+/, '')
      .trim();

    const description = cleaned || 'misc';

    const predictRes = await axios.post(`http://${process.env.PREDICT_API_HOST}/api/predict`, {
      description,
    });

    const category = predictRes.data?.category || 'Other';

    const newTransaction = new Transaction({
      userId,
      description,
      amount,
      category,
      source: 'voice'
    });

    await newTransaction.save();

    res.json({ message: 'Voice transaction saved', data: newTransaction });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/* ---------- SERVER ---------- */
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.error(err));

const HOST = process.env.HOST || '0.0.0.0';
const PORT = process.env.PORT || 3000;

app.listen(PORT, HOST, () => {
  console.log(`Server running at http://${HOST}:${PORT}`);
});