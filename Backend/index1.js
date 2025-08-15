require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const axios = require('axios');
const cors = require('cors');
const passport = require('passport');
const session = require('express-session');
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const { OAuth2Client } = require('google-auth-library');
const app = express();
app.use(express.json());
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*'
}));
/* ---------- BEGIN: Replace OAuth / Passport / Session block with this ---------- */
const userSchema = new mongoose.Schema({
  googleId: { type: String, required: true, unique: true },
  displayName: String,
  email: String,
  photo: String,
  accessToken: String,
  refreshToken: String,
  createdAt: { type: Date, default: Date.now }
});

const sessionOptions = {
  secret: process.env.JWT_SECRET || 'change_this_secret',
  resave: false,
  saveUninitialized: false,        // fixed spelling
  cookie: {
    secure: process.env.NODE_ENV === 'production', // set true only on HTTPS in prod
    httpOnly: true,
    sameSite: 'lax'
  }
};
app.use(session(sessionOptions));

app.use(passport.initialize());
app.use(passport.session());

/* Passport user serialization (store minimal info in session) */
passport.serializeUser((user, done) => {
  // store only user id (or email) in session
  done(null, user._id || user.id || user);
});
passport.deserializeUser(async (id, done) => {
  try {
    // adapt to your user model - this assumes a Users collection/model exists
    const Users = mongoose.model('User'); // ensure User model is defined somewhere else in your code
    const user = await Users.findById(id).lean();
    done(null, user || id);
  } catch (err) {
    done(err);
  }
});

/* Google OAuth strategy — capture tokens (access + refresh). */
passport.use(new GoogleStrategy({
  clientID: process.env.GOOGLE_CLIENT_ID,
  clientSecret: process.env.GOOGLE_CLIENT_SECRET,
  callbackURL: process.env.GOOGLE_REDIRECT_URI // must match GCP console entry
},
  async (accessToken, refreshToken, profile, done) => {
    try {
      // Here we either create or update a user record in DB and save tokens.
      // Adjust schema fields to your Users collection.
      const Users = mongoose.model('User' , userSchema);
      const email = profile.emails && profile.emails[0] && profile.emails[0].value;

      const update = {
        name: profile.displayName || profile.username,
        email,
        'gmail.accessToken': accessToken,
        // only store refreshToken if provided. Google provides refreshToken on first consent or when prompt=consent
        ...(refreshToken ? { 'gmail.refreshToken': refreshToken } : {}),
        'gmail.tokenSavedAt': new Date()
      };

      // Upsert user by email (or however you identify users)
      const opts = { upsert: true, new: true, setDefaultsOnInsert: true };
      const user = await Users.findOneAndUpdate({ email }, update, opts);

      // Return the user to passport
      return done(null, user);
    } catch (err) {
      return done(err);
    }
  }
));

/* OAuth start: request Gmail readonly scope + offline access for refreshToken */
app.get('/auth/google', passport.authenticate('google', {
  scope: [
    'profile',
    'email',
    'https://www.googleapis.com/auth/gmail.readonly'
  ],
  accessType: 'offline', // request refresh token
  prompt: 'consent'      // forces refresh token to be returned (on first consent)
}));

/* OAuth callback */
app.get('/auth/google/callback',
  passport.authenticate('google', { failureRedirect: '/' }),
  (req, res) => {
    // success — redirect to profile or SPA route
    res.redirect('/profile');
  }
);

/* Profile route (example) */
app.get('/profile', (req, res) => {
  if (!req.user) return res.redirect('/');
  // send sanitized user object
  const safeUser = {
    id: req.user._id || req.user.id,
    name: req.user.name || req.user.displayName,
    email: req.user.email
  };
  res.send(`Welcome ${safeUser.name} (${safeUser.email})`);
});

/* Logout route */
app.get('/logout', (req, res) => {
  req.logout(err => {
    // in newer passport versions, logout takes a callback
    if (err) console.error('Logout error', err);
    req.session.destroy(() => {
      res.clearCookie('connect.sid', { path: '/' });
      res.redirect('/');
    });
  });
});
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
        photo: payload.picture,
      },
      { new: true, upsert: true }
    );

    res.json({ success: true, user });
  } catch (err) {
    res.status(401).json({ error: 'Invalid token', details: err.message });
  }
});
/* ---------- END: Replace OAuth / Passport / Session block ---------- */


// Prediction route
const predictRoute = require('./predict');
app.use('/api/predict', predictRoute);

mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.error('MongoDB connection error:', err));

// models/User.js
// const mongoose = require('mongoose');

// const userSchema = new mongoose.Schema({
//   googleId: { type: String, required: true, unique: true },
//   displayName: String,
//   email: String,
//   photo: String,
//   accessToken: String,
//   refreshToken: String,
//   createdAt: { type: Date, default: Date.now }
// });

// module.exports = mongoose.model('User', userSchema);


// Define schema and model
const transactionSchema = new mongoose.Schema({
  description: String,
  amount: Number,

  category: String,
  date: { type: Date, default: Date.now },
});

const Transaction = mongoose.model('Transaction', transactionSchema);



// POST endpoint to add transaction with auto-categorization
app.post('/api/transaction/add', async (req, res) => {
  try {
    const { description, amount } = req.body;

    // Call your AI prediction endpoint
    const predictRes = await axios.post('http://192.168.1.10:5000/api/predict', {
      description,
    });

    const category = predictRes.data.category || 'Other';

    const newTransaction = new Transaction({
      description,
      amount,
      category,
    });

    await newTransaction.save();

    res.status(200).json({
      message: '✅ Transaction saved with category',
      data: newTransaction,
    });
  } catch (err) {
    console.error('❌ Error adding transaction:', err.message);
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/transaction/update', async (req, res) => {
  try {
    const { budget } = req.body;
    // Save to database or wherever you store budgets
    await BudgetModel.updateOne({}, { amount: budget }, { upsert: true });
    res.status(200).json({ success: true });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update budget' });
  }
});
// GET transactions by category
app.get('/api/transactions', async (req, res) => {
  try {
    const category = req.query.category;

    let query = {};
    if (category && category !== 'All') {
      query.category = category;
    }

    const transactions = await Transaction.find(query).sort({ date: -1 });

    res.status(200).json({
      success: true,
      data: transactions.map(tx => ({
        id: tx._id,
        description: tx.description,
        amount: tx.amount,
        category: tx.category,
        date: tx.date,
      })),
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
// Get 5 most recent transactions
app.get('/api/transactions/recent', async (req, res) => {
  try {
    const transactions = await Transaction.find({})
      .sort({ date: -1 })
      .limit(5); // 👈 limit to 5

    res.status(200).json({
      success: true,
      data: transactions.map(tx => ({
        id: tx._id,
        description: tx.description,
        amount: tx.amount,
        category: tx.category,
        date: tx.date,
      })),
    });
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


//server
const HOST = process.env.HOST || '0.0.0.0';  // listen on all interfaces
const PORT = process.env.PORT || 3000;
app.listen(PORT, HOST, () => {
  console.log(`🚀 Server running on http://${HOST}:${PORT}`);
});

