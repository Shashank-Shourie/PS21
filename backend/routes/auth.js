const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Organization = require('../models/Organization.js');
const Member = require('../models/Members.js');

const router = express.Router();

router.post('/register', async (req, res) => {
    try {
        const { organizationName, name, email, password } = req.body;
        let organization = await Organization.findOne({ OrganizationName: organizationName });
        if (!organization) {
            organization = new Organization({ OrganizationName: organizationName, members: [] });
            await organization.save();
        }
        let existingMember = await Member.findOne({ email });
        if (existingMember) {
            return res.status(400).json({ error: 'Email already in use' });
        }
        const hashedPassword = await bcrypt.hash(password, 10);
        const newMember = new Member({
            name,
            email,
            password: hashedPassword,
            Organization: organization._id
        });
        await newMember.save();
        organization.members.push(newMember._id);
        await organization.save();
        res.status(201).json({ message: 'User registered successfully', member: newMember ,orgid: newMember.Organization});
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
        const member = await Member.findOne({ email }).populate('Organization');
        if (!member) {
            return res.status(400).json({ error: 'Invalid credentials' });
        }
        const isMatch = await bcrypt.compare(password, member.password);
        if (!isMatch) {
            return res.status(400).json({ error: 'Invalid credentials' });
        }
        // Generate token
        const token = jwt.sign(
            { id: member._id },
            'your_jwt_secret',
            { expiresIn: '1h' }
        );
        res.status(200).json({ 
            message: 'Login successful',
            token,
            org: member.Organization.OrganizationName,
            orgid: member.Organization
        });
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
