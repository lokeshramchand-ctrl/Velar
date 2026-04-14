const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema({
  text: { type: String, required: true },        // raw input (VERY important)

  amount: { type: Number },
  merchant: { type: String },

  category: { type: String, default: "Other" },
  confidence: { type: Number },

  source: {
    type: String,
    enum: ['manual', 'voice'],
    required: true
  },

  date: { type: Date, default: Date.now }

}, { timestamps: true });

module.exports = mongoose.model('Transaction', transactionSchema);
