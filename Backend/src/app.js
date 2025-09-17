const express = require('express');
const cors = require('cors');
const passport = require('passport');
require('dotenv').config();

const authRoutes = require('./routes/authRoutes');
const transactionRoutes = require('./routes/transactionRoutes');
const { connectRabbit } = require('./config/rabbitmq');
const app = express();

app.use(express.json());
app.use(cors({ origin: process.env.CORS_ORIGIN || '*', credentials: true }));
app.use(passport.initialize());
(async () => {
  try {
    await connectRabbit();
    console.log('🐇 RabbitMQ ready for publishing');
  } catch (err) {
    console.error('❌ Failed to init RabbitMQ in app.js:', err.message);
  }
})();

app.use('/auth', authRoutes);
app.use('/api/transactions', transactionRoutes);

module.exports = app;
