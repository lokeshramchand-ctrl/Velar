const Transaction = require('../models/Transaction');
const { publishToQueue } = require('../config/rabbitmq');
const { bankRules } = require('../utils/bankRules');
const { fetchBankEmails } = require('../services/gmailService');
const { parseBankMessage } = require('../utils/parser');

exports.addTransaction = async (req, res) => {
  try {
    const { description, amount, userId } = req.body;
    if (!userId) return res.status(400).json({ error: 'Missing userId' });

    await publishToQueue('manual-transactions', { description, amount, userId });


    res.status(200).json({ message: 'Transaction queued for processing' });
  } catch (err) {
    console.error('Manual transaction queue error:', err);
    res.status(500).json({ error: 'Failed to queue transaction' });
  }
};

exports.getTransactions = async (req, res) => {
  try {
    const { category, userId } = req.query;
    if (!userId) return res.status(400).json({ error: 'Missing userId' });

    let query = { userId };
    if (category && category !== 'All') query.category = category;

    const transactions = await Transaction.find(query).sort({ date: -1 });
    res.status(200).json({ success: true, data: transactions });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
}


exports.getRecentTransaction = async (req, res) => {
  try {
    const { userId } = req.query;
    if (!userId) return res.status(400).json({ error: 'Missing userId' });
    const transactions = await Transaction.find({ userId })
      .sort({ date: -1 })
      .limit(5);

    res.status(200).json({ success: true, data: transactions });
  } catch (err) {
    res.status(500).json({ error: err.message });

  }
}

exports.voiceTransaction = async (req, res) => {
  try {
    const { voiceInput, userId } = req.body;
    if (!voiceInput) return res.status(400).json({ error: 'No voice input provided' });
    if (!userId) return res.status(400).json({ error: 'Missing userId' });

    await publishToQueue('voice-transactions', { voiceInput, userId });

    res.status(200).json({ message: 'Voice transaction queued for processing' });
  } catch (err) {
    console.error('Voice transaction queue error:', err);
    res.status(500).json({ error: 'Failed to queue transaction' });
  }
}

exports.syncGmail = async (req, res) => {
  try {
    const { accessToken, userId } = req.body;
    if (!accessToken) return res.status(400).json({ error: "Missing access token" });
    if (!userId) return res.status(400).json({ error: "Missing userId" });

    const bankEmails = bankRules.map(b => b.email);

    let emails;
    try {
      emails = await fetchBankEmails(accessToken, bankEmails);
    } catch (err) {
      console.error('❌ Gmail fetch error:', err);
      return res.status(500).json({ error: 'Failed to fetch Gmail messages' });
    }

    if (!emails?.length) {
      return res.json({ success: true, count: 0, queued: 0 });
    }

    let queued = 0;
    let skipped = 0;

    for (const email of emails) {
      try {
        const parsed = parseBankMessage(email.snippet);
        if (!parsed.amount) continue;

        // ✅ Deduplication before enqueue
        const exists = await Transaction.exists({ referenceNumber: parsed.referenceNumber });
        if (!exists) {
          await publishToQueue('email-transactions', {
            userId,
            parsed,
            from: email.from,
          });
          queued++;
        } else {
          console.log(`⚠️ Skipped duplicate txn ref: ${parsed.referenceNumber}`);
        }
      } catch (err) {
        console.error('❌ Parse error:', err.message, 'Snippet:', email.snippet);
      }
    }


    return res.json({
      success: true,
      count: emails.length,
      queued,
      skipped
    });

  } catch (error) {
    console.error('❌ Unexpected sync error:', error);
    return res.status(500).json({ error: 'Unexpected sync error' });
  }
};
