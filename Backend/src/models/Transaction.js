const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  description: { type: String, required: true },
  amount: { type: Number, required: true },
  category: { type: String, default: "Other" },
  date: { type: Date, default: Date.now },
  type: { type: String, default: "unknown" },
  vendor: String,
  source: { type: String, enum: ['manual', 'voice', 'email'], required: true },
  referenceNumber: { type: String, unique: true, sparse: true },
});

// ✅ Check if the model already exists
const Transaction = mongoose.models.Transaction || mongoose.model('Transaction', transactionSchema);

module.exports = Transaction;
