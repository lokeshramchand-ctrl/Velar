const express = require('express');
const router = express.Router();
const { exec } = require('child_process');

router.post('/', (req, res) => {
  const description = req.body.description;

  exec(`python predict.py "${description}"`, (error, stdout, stderr) => {
    if (error) {
      console.error(`Error: ${error.message}`);
      return res.status(500).send('Prediction failed');
    }
    if (stderr) {
      console.error(`Stderr: ${stderr}`);
      return res.status(500).send('Python error');
    }

    const prediction = stdout.trim();
    res.json({ category: prediction });
  });
});

module.exports = router;
