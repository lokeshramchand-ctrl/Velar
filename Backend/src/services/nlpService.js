const axios = require('axios');

exports.predictCategory = async (description) => {
  try {
   //cd const res = await axios.post('http://192.168.1.100:5000/api/predict', { description });
    const res = await axios.post('http://nlpservice:5000/api/predict', { description });
    return res.data.category || 'Other';
  } catch (err) {
    console.error('NLP Service Error:', err.message);
    return 'Other';
  }
};
