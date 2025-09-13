const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  amount: { type: Number, required: true },
  category: { type: String, default: "Other" },
  date: { type: Date, default: Date.now },
  source: { 
    type: String, 
    enum: ['manual', 'voice', 'email'], 
    required: true 
  },

  // Optional fields
  description: { type: String }, 
  type: { type: String, enum: ['debit', 'credit', 'unknown'], default: "unknown" },
  vendor: { type: String },
  referenceNumber: { type: String, unique: true, sparse: true }, // prevents dup emails

  // Flexible extension
  metadata: { type: Object }, // catch-all for future use
}, { timestamps: true });

module.exports = mongoose.model('Transaction', transactionSchema);
