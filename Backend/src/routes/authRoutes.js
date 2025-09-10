const express = require('express');
const { googleTokenLogin } = require('../controllers/authController');

const router = express.Router();

// Mobile-only Google token login
router.post('/google/token', googleTokenLogin);

// Optional: simple logout endpoint for mobile (stateless)
router.post('/logout', (req, res) => {
  // Mobile logout is stateless, just let the app delete token locally
  res.json({ success: true, message: 'Logged out' });
});

module.exports = router;
