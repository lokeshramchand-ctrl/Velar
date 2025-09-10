const Transaction = require('../models/Transaction');
const nlpService = require('../services/nlpService');

exports.addTransaction = async (req, res) => {
  try {
    const { description, amount, userId } = req.body;
    if (!userId) return res.status(400).json({ error: 'Missing userId' });

    const category = await nlpService.predictCategory(description);

    const newTransaction = new Transaction({
      userId,
      description,
      amount,
      category,
      source: 'manual',
    });

    await newTransaction.save();
    res.status(200).json({ message: 'Transaction saved', data: newTransaction });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
