const express = require('express');
const router = express.Router();
const User = require('../models/User');
const { sendSMS } = require('../services/smsService');

// Admin creates student account
router.post('/create', async (req, res) => {
  const { name, email, phone, admissionType } = req.body;
  const tempPassword = Math.random().toString(36).slice(-8); // Random 8-char password

  try {
    const user = new User({
      name,
      email,
      phone,
      password: tempPassword,
      role: 'student',
      admissionType
    });
    await user.save();

    // Send SMS (implement in services/smsService.js)
    await sendSMS(phone, `Your login: ${email}, Password: ${tempPassword}`);

    res.json({ message: 'Student created successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;