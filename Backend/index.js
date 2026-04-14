// Import required modules
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

// Initialize Express app
const app = express();
app.use(express.json());
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true
}));

/* ---------- MODELS ---------- */
// User schema and model
defineUserSchema();
// Transaction schema and model
defineTransactionSchema();

/* ---------- SESSION ---------- */
const sessionOptions = {
  secret: process.env.JWT_SECRET ,
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
if (process.env.NODE_ENV === "development") {
  console.log("Running in development mode (OAuth disabled)");

  app.use((req, res, next) => {
    req.user = {
      _id: "devuserid123",
      displayName: "Dev User",
      email: "dev@test.com"
    };
    next();
  });
}
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

// passport.use(new GoogleStrategy({
//   clientID: process.env.GOOGLE_CLIENT_ID,
//   clientSecret: process.env.GOOGLE_CLIENT_SECRET,
//   callbackURL: process.env.GOOGLE_REDIRECT_URI
// }, async (accessToken, refreshToken, profile, done) => {
//   try {
//     const email = profile.emails && profile.emails[0] && profile.emails[0].value;
//     const update = {
//       displayName: profile.displayName,
//       email,
//       accessToken,
//       ...(refreshToken ? { refreshToken } : {})
//     };
//     const opts = { upsert: true, new: true, setDefaultsOnInsert: true };
//     const user = await User.findOneAndUpdate({ googleId: profile.id }, update, opts);
//     return done(null, user);
//   } catch (err) {
//     return done(err);
//   }
// }));

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

    // Call the prediction API to get the category
    const predictRes = await axios.post(`http://${process.env.PREDICT_API_HOST}/api/predict`, {
      description,
    });
    const category = predictRes.data.category || 'Other';

    // Save the transaction to the database
    const newTransaction = new Transaction({
      userId,
      description,
      amount,
      category,
      source: 'manual',
    });
    await newTransaction.save();

    console.log('Transaction successfully saved:', newTransaction);
    res.status(200).json({ message: 'Transaction saved successfully', data: newTransaction });
  } catch (err) {
    console.error('Error saving transaction:', err.message);
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/transactions', async (req, res) => {
  try {
    const { category, userId } = req.query;
    if (!userId) return res.status(400).json({ error: 'Missing userId' });

    // Build query based on user input
    let query = { userId };
    if (category && category !== 'All') query.category = category;

    // Fetch transactions from the database
    const transactions = await Transaction.find(query).sort({ date: -1 });
    console.log('Transactions fetched successfully for user:', userId);
    res.status(200).json({ success: true, data: transactions });
  } catch (err) {
    console.error('Error fetching transactions:', err.message);
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/transactions/recent', async (req, res) => {
  try {
    const { userId } = req.query;
    if (!userId) return res.status(400).json({ error: 'Missing userId' });

    // Fetch recent transactions for the user
    const transactions = await Transaction.find({ userId })
      .sort({ date: -1 })
      .limit(5);

    console.log('Recent transactions fetched successfully for user:', userId);
    res.status(200).json({ success: true, data: transactions });
  } catch (err) {
    console.error('Error fetching recent transactions:', err.message);
    res.status(500).json({ error: err.message });
  }
});

//VOICE
app.post('/api/transactions/voice', async (req, res) => {
  try {
    const { voiceInput, userId } = req.body;
    if (!voiceInput) {
      return res.status(400).json({ error: 'No voice input provided' });
    }
    if (!userId) {
      return res.status(400).json({ error: 'Missing userId' });
    }

    // Extract amount from voice input
    const amountMatch = voiceInput.match(/(?:\₹|\$)?(\d+(?:\.\d{1,2})?)/);
    const amount = amountMatch ? parseFloat(amountMatch[1]) : null;

    // Extract description from voice input
    const cleaned = voiceInput
      .toLowerCase()
      .replace(/(bought|added|paid|spent|for|on)/g, '')
      .replace(/₹?\d+/, '')
      .trim();
    const description = cleaned || 'misc';

    // Call the prediction API to get the category
    const predictRes = await axios.post(`http://${process.env.PREDICT_API_HOST}/api/predict`, {
      description,
    });
    const category = predictRes.data?.category || 'Other';

    // Save the voice transaction to the database
    const newTransaction = new Transaction({
      userId,
      description,
      amount,
      category,
      source: 'voice'
    });

    await newTransaction.save();

    console.log('Voice transaction successfully saved:', newTransaction);
    res.status(200).json({ message: 'Voice transaction saved successfully', data: newTransaction });
  } catch (err) {
    console.error('Error saving voice transaction:', err.message);
    res.status(500).json({ error: 'Server error during voice transaction' });
  }
});

/* ---------- SERVER ---------- */
// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
  .then(() => console.log('MongoDB connected successfully'))
  .catch(err => console.error('Error connecting to MongoDB:', err.message));

// Start the server
const HOST = process.env.HOST || '0.0.0.0';
const PORT = process.env.PORT || 3000;
app.listen(PORT, HOST, () => {
  console.log(`Server is running at http://${HOST}:${PORT}`);
});
