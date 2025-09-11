const express = require('express');
const { googleTokenLogin } = require('../controllers/authController');

const router = express.Router();

router.post('/google/token', googleTokenLogin);

router.post('/logout', (req, res) => {
  res.json({ success: true, message: 'Logged out' });
});

module.exports = router;
