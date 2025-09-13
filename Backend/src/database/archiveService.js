const Transaction = require('../models/Transaction');
const ArchivedTransaction = require('../models/ArchivedTransaction');

exports.archiveOldTransactions = async () => {
  try {
    const cutoffDate = new Date();
    cutoffDate.setFullYear(cutoffDate.getFullYear() - 2); // >2 years old

    const oldTransactions = await Transaction.find({ date: { $lt: cutoffDate } });

    if (!oldTransactions.length) {
      console.log('[ArchiveService] No old transactions found.');
      return;
    }

    // Insert into archive collection
    await ArchivedTransaction.insertMany(oldTransactions);

    // Delete from active collection
    await Transaction.deleteMany({ date: { $lt: cutoffDate } });

    console.log(`[ArchiveService] Archived ${oldTransactions.length} transactions.`);
  } catch (err) {
    console.error('[ArchiveService] Error archiving transactions:', err);
  }
};
