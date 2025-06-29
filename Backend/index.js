
const express = require('express');
const mongoose = require('mongoose');
const axios = require('axios');

const app = express();
app.use(express.json()); // to parse JSON

// Prediction route
const predictRoute = require('./predict');
app.use('/api/predict', predictRoute);

// MongoDB connection
mongoose.connect('mongodb://localhost:27017/chat', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Define schema and model
const transactionSchema = new mongoose.Schema({
  description: String,
  amount: Number,

  category: String,
  date: { type: Date, default: Date.now },
});

const Transaction = mongoose.model('Transaction', transactionSchema);

// POST endpoint to add transaction with auto-categorization
app.post('/api/transaction/add', async (req, res) => {
  try {
    const { description, amount } = req.body;

    // Call your AI prediction endpoint
    const predictRes = await axios.post('http://192.168.1.9:5000/api/predict', {
      description,
    });

    const category = predictRes.data.category || 'Other';

    const newTransaction = new Transaction({
      description,
      amount,
      category,
    });

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
app.post('/api/transaction/update', async (req, res) => {
  try {
    const { budget } = req.body;
    // Save to database or wherever you store budgets
    await BudgetModel.updateOne({}, { amount: budget }, { upsert: true });
    res.status(200).json({ success: true });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update budget' });
  }
});
// GET transactions by category
app.get('/api/transactions', async (req, res) => {
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

// Start server
app.listen(3000, () => {
  console.log('🚀 Server running on port 3000');
});
