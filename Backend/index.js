require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const axios = require('axios');
const cors = require('cors');
const passport = require('passport');
const session = require('express-session');
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const { OAuth2Client } = require('google-auth-library');
const { google } = require('googleapis');

const app = express();
app.use(express.json());
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true
}));

/* ---------- MODELS ---------- */
const userSchema = new mongoose.Schema({
  googleId: { type: String, required: true, unique: true },
  displayName: String,
  email: String,
  photo: String,
  accessToken: String,
  refreshToken: String,
  createdAt: { type: Date, default: Date.now }
});
const User = mongoose.model('User', userSchema);

const transactionSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  description: String,
  amount: Number,
  category: String,
  date: { type: Date, default: Date.now },
});
const Transaction = mongoose.model('Transaction', transactionSchema);

/* ---------- SESSION ---------- */
const sessionOptions = {
  secret: process.env.JWT_SECRET || 'change_this_secret',
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: process.env.NODE_ENV === 'production',
    httpOnly: true,
    sameSite: 'lax'
  }
};
app.use(session(sessionOptions));

app.use(passport.initialize());
app.use(passport.session());

/* ---------- PASSPORT ---------- */
passport.serializeUser((user, done) => {
  done(null, user._id);
});
passport.deserializeUser(async (id, done) => {
  try {
    const user = await User.findById(id).lean();
    done(null, user);
  } catch (err) {
    done(err);
  }
});

passport.use(new GoogleStrategy({
  clientID: process.env.GOOGLE_CLIENT_ID,
  clientSecret: process.env.GOOGLE_CLIENT_SECRET,
  callbackURL: process.env.GOOGLE_REDIRECT_URI
}, async (accessToken, refreshToken, profile, done) => {
  try {
    const email = profile.emails && profile.emails[0] && profile.emails[0].value;
    const update = {
      displayName: profile.displayName,
      email,
      accessToken,
      ...(refreshToken ? { refreshToken } : {})
    };
    const opts = { upsert: true, new: true, setDefaultsOnInsert: true };
    const user = await User.findOneAndUpdate({ googleId: profile.id }, update, opts);
    return done(null, user);
  } catch (err) {
    return done(err);
  }
}));

/* ---------- GOOGLE OAUTH ROUTES (WEB) ---------- */
app.get('/auth/google', passport.authenticate('google', {
  scope: ['profile', 'email', 'https://www.googleapis.com/auth/gmail.readonly'],
  accessType: 'offline',
  prompt: 'consent'
}));

app.get('/auth/google/callback',
  passport.authenticate('google', { failureRedirect: '/' }),
  (req, res) => {
    res.redirect('/profile');
  }
);

/* ---------- GOOGLE TOKEN LOGIN (MOBILE / FLUTTER) ---------- */
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);
app.post('/auth/google/token', async (req, res) => {
  try {
    const { idToken } = req.body;
    const ticket = await client.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });

    const payload = ticket.getPayload();
    const user = await User.findOneAndUpdate(
      { googleId: payload.sub },
      {
        googleId: payload.sub,
        displayName: payload.name,
        email: payload.email,
        photo: payload.picture
      },
      { new: true, upsert: true }
    );

    res.json({ success: true, user });
  } catch (err) {
    res.status(401).json({ error: 'Invalid token', details: err.message });
  }
});

/* ---------- USER ROUTES ---------- */
app.get('/profile', (req, res) => {
  if (!req.user) return res.status(401).json({ error: 'Not logged in' });
  res.json({
    id: req.user._id,
    name: req.user.displayName,
    email: req.user.email
  });
});

app.get('/logout', (req, res) => {
  req.logout(err => {
    if (err) console.error('Logout error', err);
    req.session.destroy(() => {
      res.clearCookie('connect.sid', { path: '/' });
      res.redirect('/');
    });
  });
});

/* ---------- TRANSACTION ROUTES (NOW USER-SPECIFIC) ---------- */
app.post('/api/transaction/add', async (req, res) => {
  try {
    const { description, amount, userId } = req.body;
    if (!userId) return res.status(400).json({ error: 'Missing userId' });

    const predictRes = await axios.post('http://192.168.1.10:5000/api/predict', {
      description,
    });
    const category = predictRes.data.category || 'Other';

    const newTransaction = new Transaction({
      userId,
      description,
      amount,
      category
    });
    await newTransaction.save();

    res.status(200).json({ message: '✅ Transaction saved', data: newTransaction });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/transactions', async (req, res) => {
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
});

app.get('/api/transactions/recent', async (req, res) => {
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
});

app.post('/api/transactions/voice', async (req, res) => {
  try {
    const { voiceInput } = req.body;
    if (!voiceInput) {
      return res.status(400).json({ error: 'No voice input provided' });
    }
    // Step 1: Use regex to extract amount
    const amountMatch = voiceInput.match(/(?:\₹|\$)?(\d+(?:\.\d{1,2})?)/);
    const amount = amountMatch ? parseFloat(amountMatch[1]) : null;
    // Step 2: Extract description (rough logic: remove common verbs + amount)
    const cleaned = voiceInput
      .toLowerCase()
      .replace(/(bought|added|paid|spent|for|on)/g, '')
      .replace(/₹?\d+/, '')
      .trim();
    const description = cleaned || 'misc';
    // Step 3: Predict category using your Flask API
    const predictRes = await axios.post('http://192.168.1.10:5000/api/predict', {
      description,
    });
    const category = predictRes.data?.category || 'Other';
    // Step 4: Save to DB
    const newTransaction = new Transaction({
      description,
      amount,
      category,
    });
    await newTransaction.save();
    res.status(200).json({
      message: '✅ Voice transaction saved',
      data: newTransaction,
    });
  } catch (err) {
    console.error('❌ Voice transaction error:', err.message);
    res.status(500).json({ error: 'Server error during voice transaction' });
  }
});
// Bank rules (can expand later)
// ---------- BANK RULES ----------
const bankRules = [
  { name: 'HDFC Bank', email: 'alerts@hdfcbank.net' },
  { name: 'ICICI Bank', email: 'alerts@icicibank.com' },
];

// ---------- PARSER ----------
function parseBankMessage(snippet) {
  const result = {
    amount: null,
    vendor: null,
    type: null,
    date: null,
    raw: snippet,
  };

  // Amount (handles Rs/INR)
  const amtMatch = snippet.match(/(?:Rs\.?|INR)\s*([\d,]+\.?\d*)/i);
  if (amtMatch) result.amount = parseFloat(amtMatch[1].replace(/,/g, ""));


  // Debit / Credit
  if (/debited/i.test(snippet)) result.type = "debit";
  else if (/credited/i.test(snippet)) result.type = "credit";

  // Vendor (look for "to" or "at")
  const vendorMatch = snippet.match(/to\s+([A-Za-z0-9@.\s&-]+)/i);
  if (vendorMatch) {
    result.vendor = vendorMatch[1].trim();
  } else {
    const atMatch = snippet.match(/at\s+([A-Za-z0-9\s&.-]+)/i);
    if (atMatch) result.vendor = atMatch[1].trim();
  }

  // Date (dd-mm-yy or dd/mm/yyyy)
  const dateMatch = snippet.match(/on\s+(\d{2}[-/]\d{2}[-/]\d{2,4})/);
  if (dateMatch) result.date = dateMatch[1];


  return result;
}

// ---------- FETCH EMAILS ----------
async function fetchBankEmails(accessToken, bankEmails) {
  const oauth2Client = new google.auth.OAuth2();
  oauth2Client.setCredentials({ access_token: accessToken });

  const gmail = google.gmail({ version: 'v1', auth: oauth2Client });

  const allEmails = [];

  for (const bankEmail of bankEmails) {
    const res = await gmail.users.messages.list({
      userId: 'me',
      q: `from:${bankEmail}`,
      maxResults: 20, // can adjust
    });

    const messages = res.data.messages || [];
    for (const msg of messages) {
      const fullMessage = await gmail.users.messages.get({
        userId: 'me',
        id: msg.id,
      });

      const snippet = fullMessage.data.snippet || "";
      allEmails.push({
        from: bankEmail,
        snippet,
      });
    }
  }

  return allEmails;
}

// ---------- ROUTE ----------
app.post('/api/sync-gmail', async (req, res) => {
  try {
    const { accessToken } = req.body;

    if (!accessToken) {
      return res.status(400).json({ error: "Missing access token" });
    }

    const bankEmails = bankRules.map(b => b.email);
    const emails = await fetchBankEmails(accessToken, bankEmails);

    // 🔥 parse emails into structured transactions
    const parsedEmails = emails.map(email => ({
      from: email.from,
      ...parseBankMessage(email.snippet),
    }));

    res.json({ success: true, emails: parsedEmails });
  } catch (error) {
    console.error('❌ Gmail fetch error:', error);
    res.status(500).json({ error: 'Failed to fetch Gmail messages' });
  }
});

/* ---------- SERVER ---------- */
mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.error('MongoDB connection error:', err));

const HOST = process.env.HOST || '0.0.0.0';
const PORT = process.env.PORT || 3000;
app.listen(PORT, HOST, () => {
  console.log(`🚀 Server running on http://${HOST}:${PORT}`);
});
