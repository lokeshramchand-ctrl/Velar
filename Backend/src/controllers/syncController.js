const Transaction = require('../models/Transaction');
const { bankRules } = require('../utils/bankRules');
const { fetchBankEmails } = require('../services/gmailService');
const { parseBankMessage } = require('../utils/parser');
const nlpService = require('../services/nlpService');

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
      console.error('❌ Error fetching bank emails:', err);
      return res.status(500).json({ error: 'Failed to fetch bank emails' });
    }

    if (!emails?.length) {
      console.warn('⚠️ No bank emails found');
      return res.json({ success: true, count: 0, transactions: [] });
    }

    const savedTxns = [];
    let skipped = 0;

    for (const email of emails) {
      let parsed;
      try {
        parsed = parseBankMessage(email.snippet);
      } catch (err) {
        console.error('❌ Parse error:', err.message, 'Snippet:', email.snippet);
        skipped++;
        continue;
      }

      if (!parsed.amount) {
        console.warn('⚠️ Missing amount, skipping:', parsed);
        skipped++;
        continue;
      }

      // Category via NLP
      let category = 'Other';
      try {
        category = await nlpService.predictCategory(parsed.vendor || "Unknown");
      } catch (err) {
        console.error('❌ NLP error:', err.message);
      }

      // Parse date
      const parseDateString = (dateStr) => {
        if (!dateStr) return null;
        const parts = dateStr.split('-');
        if (parts.length === 3) {
          const [day, month, yearSuffix] = parts;
          const year = 2000 + parseInt(yearSuffix, 10);
          return new Date(year, parseInt(month, 10) - 1, parseInt(day, 10));
        }
        return new Date(dateStr); // fallback
      };
      const dateValue = parseDateString(parsed.date) || new Date();

      try {
        if (parsed.referenceNumber) {
          const updatedTxn = await Transaction.findOneAndUpdate(
            { referenceNumber: parsed.referenceNumber },
            {
              userId,
              description: parsed.vendor || "Unknown Vendor",
              amount: parsed.amount,
              type: parsed.type || "unknown",
              date: dateValue,
              vendor: parsed.vendor,
              category,
              source: "email",
              bank: email.from,
              referenceNumber: parsed.referenceNumber,
            },
            { upsert: true, new: true, setDefaultsOnInsert: true, runValidators: true }
          );
          savedTxns.push(updatedTxn);
        } else {
          const newTxn = new Transaction({
            userId,
            description: parsed.vendor || "Unknown Vendor",
            amount: parsed.amount,
            type: parsed.type || "unknown",
            date: dateValue,
            vendor: parsed.vendor,
            category,
            source: "email",
            bank: email.from,
          });
          await newTxn.save();
          savedTxns.push(newTxn);
        }
      } catch (err) {
        console.error('❌ DB save error:', err.message);
      }
    }

    return res.json({
      success: true,
      count: savedTxns.length,
      skipped,
      transactions: savedTxns,
    });

  } catch (error) {
    console.error('❌ Unexpected error in /api/sync-gmail:', error);
    return res.status(500).json({ error: 'Failed to fetch and save Gmail messages' });
  }
};
