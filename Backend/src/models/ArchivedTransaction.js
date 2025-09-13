const mongoose = require('mongoose');

const archivedTransactionSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  description: String,
  amount: Number,
  category: String,
  date: Date,
  type: String,
  vendor: String,
  source: String,
  referenceNumber: String,
  archivedAt: { type: Date, default: Date.now }, // when archived
});

module.exports = mongoose.model('ArchivedTransaction', archivedTransactionSchema);
