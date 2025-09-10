const express = require('express');
const cors = require('cors');
const passport = require('passport');
require('dotenv').config();

const authRoutes = require('./routes/authRoutes');
const transactionRoutes = require('./routes/transactionRoutes');
const syncRoutes = require('./routes/syncRoutes');

const app = express();

// Middleware
app.use(express.json());
app.use(cors({ origin: process.env.CORS_ORIGIN || '*', credentials: true }));


app.use(passport.initialize());

// Routes
app.use('/auth', authRoutes);
app.use('/api/transactions', transactionRoutes);
app.use('/api/sync-gmail', syncRoutes);

module.exports = app;
