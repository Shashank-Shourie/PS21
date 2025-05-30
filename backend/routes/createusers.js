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
        user: process.env.EMAIL_USER, // use environment variables in production
        pass: process.env.EMAIL_PASS,
        // use an App Password if using Gmail
    }
});

router.post('/login',async(req,res)=>{
    try{
        const {email,password} = req.body;
        const user = await User.findOne({email:email});
        if (!user){
          return res.status(400).json({ error: 'Invalid credentials' });
        }
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ error: 'Invalid credentials' });
        }
        const token = jwt.sign(
            { id: user._id },
            'your_jwt_secret',
            { expiresIn: '1h' }
        );
        res.status(200).json({ 
            message: 'Login successful',
            token,
            userid:user._id
        });
    }catch (error) {
        console.error(error);
        res.status(500).json({ error: error });
    }
});

router.post('/userregister', async (req, res) => {
    try {
        const { name, email, organizationId } = req.body;
        const organization = await Organization.findOne({ _id: organizationId });
        if (!organization) return res.status(404).json({ error: 'Organization not found' });
        const password = 'default';

        const hashedPassword = await bcrypt.hash(password, 10);

        const newuser = new User({
            name,
            password: hashedPassword,
            email,
            Organization: organization._id,
        });
        await newuser.save();

        // Send email with credentials
        const mailOptions = {
            from: process.env.EMAIL_USER,
            to: email,
            subject: 'Welcome to the Portal - Your Credentials',
            text: `Hello ${name},\n\nYour account has been created.\n\nEmail: ${email}\nPassword: ${password}\n\nPlease log in and change your password.\n\nThank you!`
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
        res.status(500).json({ error: error });
    }
});

router.post('/userslist', async (req, res) => {
    try {
        const { organizationId } = req.body;
        const users = await User.find({Organization:organizationId});
        console.log(users);
        res.status(200).json(users);
    } catch (error) {
        console.log(error);
        res.status(500).json({ error: error.message });
    }
});


module.exports = router;
