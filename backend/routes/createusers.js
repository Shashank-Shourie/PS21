const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Organization = require('../models/Organization.js');
const Member = require('../models/Members.js');
const User = require('../models/User.js');

const router = express.Router();

const nodemailer = require('nodemailer');

// Middleware to verify JWT token
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
        return res.status(401).json({ error: 'Access token required' });
    }

    jwt.verify(token, 'your_jwt_secret', (err, user) => {
        if (err) {
            return res.status(403).json({ error: 'Invalid or expired token' });
        }
        req.user = user;
        next();
    });
};

// Set up reusable transporter
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
    }
});

// Enhanced login route with full user data
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        
        // Validate input
        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password are required' });
        }

        // Find user and populate organization
        const user = await User.findOne({ email: email }).populate('Organization');
        if (!user) {
            return res.status(400).json({ error: 'Invalid credentials' });
        }

        // Check password
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ error: 'Invalid credentials' });
        }

        // Generate JWT token
        const token = jwt.sign(
            { 
                id: user._id,
                email: user.email,
                organizationId: user.Organization?._id 
            },
            'your_jwt_secret',
            { expiresIn: '24h' } // Extended expiry
        );

        // Return comprehensive user data
        res.status(200).json({
            message: 'Login successful',
            token,
            userid: user._id,
            email: user.email,
            name: user.name,
            submitted: user.submitted,
            percentage_matched: user.percentage_matched,
            organizationId: user.Organization?._id,
            organizationName: user.Organization?.name || 'YourOrg Pvt Ltd'
        });

    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Get user details by ID (protected route)
router.get('/details/:userId', authenticateToken, async (req, res) => {
    try {
        const { userId } = req.params;
        
        // Ensure user can only access their own data or admin access
        if (req.user.id !== userId) {
            return res.status(403).json({ error: 'Access denied' });
        }

        const user = await User.findById(userId).populate('Organization');
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        res.status(200).json({
            id: user._id,
            name: user.name,
            email: user.email,
            submitted: user.submitted,
            percentage_matched: user.percentage_matched,
            organizationId: user.Organization?._id,
            organizationName: user.Organization?.name || 'YourOrg Pvt Ltd'
        });

    } catch (error) {
        console.error('Get user details error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Update user profile (protected route)
router.put('/profile/:userId', authenticateToken, async (req, res) => {
    try {
        const { userId } = req.params;
        const { name, email } = req.body;
        
        // Ensure user can only update their own profile
        if (req.user.id !== userId) {
            return res.status(403).json({ error: 'Access denied' });
        }

        const updateData = {};
        if (name) updateData.name = name;
        if (email) updateData.email = email;

        const user = await User.findByIdAndUpdate(
            userId,
            updateData,
            { new: true, runValidators: true }
        ).populate('Organization');

        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        res.status(200).json({
            message: 'Profile updated successfully',
            user: {
                id: user._id,
                name: user.name,
                email: user.email,
                submitted: user.submitted,
                percentage_matched: user.percentage_matched,
                organizationId: user.Organization?._id,
                organizationName: user.Organization?.name
            }
        });

    } catch (error) {
        console.error('Update profile error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Change password (protected route)
router.put('/change-password/:userId', authenticateToken, async (req, res) => {
    try {
        const { userId } = req.params;
        const { oldPassword, newPassword } = req.body;
        
        // Ensure user can only change their own password
        if (req.user.id !== userId) {
            return res.status(403).json({ error: 'Access denied' });
        }

        if (!oldPassword || !newPassword) {
            return res.status(400).json({ error: 'Old password and new password are required' });
        }

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        // Verify old password
        const isMatch = await bcrypt.compare(oldPassword, user.password);
        if (!isMatch) {
            return res.status(400).json({ error: 'Current password is incorrect' });
        }

        // Hash new password
        const hashedNewPassword = await bcrypt.hash(newPassword, 10);
        
        // Update password
        await User.findByIdAndUpdate(userId, { password: hashedNewPassword });

        res.status(200).json({ message: 'Password changed successfully' });

    } catch (error) {
        console.error('Change password error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Get organization details (protected route)
router.get('/organization/:orgId', authenticateToken, async (req, res) => {
    try {
        const { orgId } = req.params;
        
        const organization = await Organization.findById(orgId);
        if (!organization) {
            return res.status(404).json({ error: 'Organization not found' });
        }

        res.status(200).json({
            id: organization._id,
            name: organization.name,
            // Add other organization fields as needed
        });

    } catch (error) {
        console.error('Get organization error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// User registration route (existing)
router.post('/userregister', async (req, res) => {
    try {
        const { name, email, organizationId } = req.body;
        
        // Validate input
        if (!name || !email || !organizationId) {
            return res.status(400).json({ error: 'Name, email, and organization ID are required' });
        }

        const organization = await Organization.findById(organizationId);
        if (!organization) {
            return res.status(404).json({ error: 'Organization not found' });
        }

        // Check if user already exists
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ error: 'User with this email already exists' });
        }

        const password = 'default';
        const hashedPassword = await bcrypt.hash(password, 10);

        const newUser = new User({
            name,
            password: hashedPassword,
            email,
            Organization: organization._id,
        });

        await newUser.save();

        // Send email with credentials
        const mailOptions = {
            from: process.env.EMAIL_USER,
            to: email,
            subject: 'Welcome to the Portal - Your Credentials',
            html: `
                <h2>Welcome to ${organization.name}</h2>
                <p>Hello ${name},</p>
                <p>Your account has been created successfully.</p>
                <div style="background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0;">
                    <p><strong>Email:</strong> ${email}</p>
                    <p><strong>Password:</strong> ${password}</p>
                </div>
                <p><strong style="color: #d32f2f;">Important:</strong> Please log in and change your password immediately for security purposes.</p>
                <p>Thank you!</p>
            `
        };

        transporter.sendMail(mailOptions, (error, info) => {
            if (error) {
                console.error('Email failed:', error);
            } else {
                console.log('Email sent: ' + info.response);
            }
        });

        res.status(201).json({
            message: 'User created successfully and email sent',
            user: {
                id: newUser._id,
                name: newUser.name,
                email: newUser.email,
                organizationId: newUser.Organization
            }
        });

    } catch (error) {
        console.error('User registration error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Get users list by organization (existing)
router.post('/userslist', async (req, res) => {
    try {
        const { organizationId } = req.body;
        
        if (!organizationId) {
            return res.status(400).json({ error: 'Organization ID is required' });
        }

        const users = await User.find({ Organization: organizationId })
            .populate('Organization', 'name')
            .select('-password'); // Exclude password from response

        res.status(200).json(users);
    } catch (error) {
        console.error('Get users list error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Verify token route (for auto-login)
router.get('/verify-token', authenticateToken, async (req, res) => {
    try {
        const user = await User.findById(req.user.id).populate('Organization');
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        res.status(200).json({
            valid: true,
            user: {
                id: user._id,
                name: user.name,
                email: user.email,
                submitted: user.submitted,
                percentage_matched: user.percentage_matched,
                organizationId: user.Organization?._id,
                organizationName: user.Organization?.name
            }
        });
    } catch (error) {
        console.error('Token verification error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

module.exports = router;