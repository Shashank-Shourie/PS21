const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Organization = require('../models/Organization.js');
const Member = require('../models/Members.js');
const User = require('../models/User.js');

const router = express.Router();

const nodemailer = require('nodemailer');

// Set up reusable transporter
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: PROCESS.env.EMAIL_USER, // use environment variables in production
        pass: PROCESS.env.EMAIL_PASS,    // use an App Password if using Gmail
    }
});


router.post('/userregister', async (req, res) => {
    try {
        const { _name, _email, _organization } = req.body;

        const organization = await Organization.findOne({ _organization });
        if (!organization) return res.status(404).json({ error: 'Organization not found' });

        const orgid = organization._id;
        const password = 'default';

        const hashedPassword = await bcrypt.hash(password, 10);

        const newuser = new User({
            name: _name,
            password: hashedPassword,
            email: _email,
            Organization: orgid,
        });

        await newuser.save();

        // Send email with credentials
        const mailOptions = {
            from: process.env.EMAIL_USER,
            to: _email,
            subject: 'Welcome to the Portal - Your Credentials',
            text: `Hello ${_name},\n\nYour account has been created.\n\nEmail: ${_email}\nPassword: ${password}\n\nPlease log in and change your password.\n\nThank you!`
        };

        transporter.sendMail(mailOptions, (error, info) => {
            if (error) {
                console.error('Email failed:', error);
            } else {
                console.log('Email sent: ' + info.response);
            }
        });

        res.status(201).json({ message: 'User added successfully and email sent', user: newuser });

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Server error. User not created, try again' });
    }
});

router.get('/users', async (req, res) => {
    try {
        const users = await User.find().populate('Organization');
        res.status(200).json(users);
    } catch (error) {
        console.log(error);
        res.status(500).json({ error: 'Failed to fetch users' });
    }
});


module.exports = router;
