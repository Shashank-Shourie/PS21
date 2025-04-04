const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Organization = require('../models/Organization.js');
const Member = require('../models/Members.js');

const router = express.Router();

// Register Route
router.post('/register', async (req, res) => {
    try {
        const { organizationName, name, email, password } = req.body;

        // Check if organization exists
        let organization = await Organization.findOne({ OrganizationName: organizationName });

        if (!organization) {
            // Create new organization
            organization = new Organization({ OrganizationName: organizationName, members: [] });
            await organization.save();
        }

        // Check if member already exists
        let existingMember = await Member.findOne({ email });
        if (existingMember) {
            return res.status(400).json({ error: 'Email already in use' });
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Create new member
        const newMember = new Member({
            name,
            email,
            password: hashedPassword,
            Organization: organization._id
        });

        await newMember.save();

        // Add member to organization
        organization.members.push(newMember._id);
        await organization.save();

        res.status(201).json({ message: 'User registered successfully', member: newMember });
        console.log(newMember);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Login Route
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        // Find member by email
        const member = await Member.findOne({ email });
        if (!member) {
            return res.status(400).json({ error: 'Invalid credentials' });
        }

        // Compare password
        const isMatch = await bcrypt.compare(password, member.password);
        if (!isMatch) {
            return res.status(400).json({ error: 'Invalid credentials' });
        }

        // Generate token
        const token = jwt.sign({ id: member._id }, 'your_jwt_secret', { expiresIn: '1h' });

        res.status(200).json({ message: 'Login successful', token });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Logout Route (Frontend should just remove token)
router.post('/logout', (req, res) => {
    res.status(200).json({ message: 'Logout successful' });
});

module.exports = router;
