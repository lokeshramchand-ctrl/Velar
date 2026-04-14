const express = require('express');
const cors = require('cors');
require('dotenv').config();

const transactionRoutes = require('./routes/transactionRoutes');

const app = express();

/* ---------- MIDDLEWARE ---------- */
app.use(express.json());
app.use(cors({ origin: '*' }));

/* ---------- ROUTES ---------- */
app.use('/api/transactions', transactionRoutes);

module.exports = app;
