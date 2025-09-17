const { bankRules } = require('../utils/bankRules');
const { fetchBankEmails } = require('../services/gmailService');
const { parseBankMessage } = require('../utils/parser');
const { publishToQueue } = require('../config/rabbitmq'); 

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

        if (!parsed?.amount) {
          console.warn('⚠️ Skipping email without amount:', email.snippet);
          skipped++;
          continue;
        }

        // ✅ push to RabbitMQ using publishToQueue helper
        await publishToQueue("email-transactions", {
          userId,
          parsed,
          from: email.from
        });

        queued++;
      } catch (err) {
        console.error('❌ Parse/Queue error:', err.message);
        skipped++;
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
