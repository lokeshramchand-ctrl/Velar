require('dotenv').config({ 
  path: require('path').resolve(__dirname, '../.env') 
});

const cron = require('node-cron');
const connectDB = require('../config/db'); // ✅ central DB logic
const { archiveOldTransactions } = require('../database/archiveService');

(async () => {
  try {
    // Debug log to confirm .env is loading correctly
    console.log('[ArchiveJob] Loaded MONGO_URI:',process.env.MONGO_URI || '❌ Not found');

    if (!process.env.MONGO_URI) {
      throw new Error('❌ MONGO_URI not found in .env file');
    }

    // Connect once
    await connectDB();
    console.log('[ArchiveJob] Connected to MongoDB ✅');

    // Schedule: every 1st of month at 2 AM
    cron.schedule('0 2 1 * *', async () => {
      console.log('[ArchiveJob] Running monthly archive...');
      try {
        await archiveOldTransactions();
        console.log('[ArchiveJob] Archive completed successfully ✅');
      } catch (err) {
        console.error('[ArchiveJob] Archive failed ❌', err);
      }
    });

    console.log('[ArchiveJob] Cron job scheduled (runs 1st of month @ 2AM)');
  } catch (err) {
    console.error('[ArchiveJob] Startup Error ❌:', err.message);
    process.exit(1);
  }
})();
