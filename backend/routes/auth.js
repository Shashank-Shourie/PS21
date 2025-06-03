const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Organization = require('../models/Organization.js');
const Member = require('../models/Members.js');
const User = require('../models/User.js');

const router = express.Router();

router.post('/register', async (req, res) => {
    try {
        const { organizationName, name, email, password } = req.body;
        let organization = await Organization.findOne({ OrganizationName: organizationName });
        if (!organization) {
            organization = new Organization({ OrganizationName: organizationName, members: [] });
            await organization.save();
        }else{
            return res.status(400).json({error:'Organization already exists, contact them to get access'});
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

router.post('/slogin', async (req, res) => {
    try {
        const { email, password } = req.body;
        const member = await User.findOne({ email }).populate('Organization');
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

router.post('/registerorg',async(req,res)=>{
    try{
        const { organizationName, name, email,deafault_password } = req.body;
        let organization = await Organization.findOne({ OrganizationName: organizationName });
        const hashedPassword = bcrypt.hash(deafault_password,10);
        const newMember = new Member({
            name,
            email,
            password: hashedPassword,
            Organization: organization._id
        });
        await newMember.save();
        res.status(200).json({message:"New account added successfully",newMember});
    }catch(err){
        console.log(err);
        res.status(500).json({error:'server error'})
    }
})

router.post('/add', async (req, res) => {
    try {
        const { name, email, organizationId } = req.body;

        // Validate required fields
        if (!name || !email || !organizationId) {
            return res.status(400).json({
                success: false,
                message: 'Name, email, and organization ID are required'
            });
        }

        // Validate email format
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            return res.status(400).json({
                success: false,
                message: 'Please provide a valid email address'
            });
        }

        // Check if organization exists
        const organization = await Organization.findById(organizationId);
        if (!organization) {
            return res.status(404).json({
                success: false,
                message: 'Organization not found'
            });
        }

        // Check if email already exists
        const existingMember = await Member.findOne({ email: email.toLowerCase() });
        if (existingMember) {
            return res.status(409).json({
                success: false,
                message: 'A member with this email address already exists'
            });
        }
        const hashedPassword = await bcrypt.hash('default', 10);
        // Create new member with default password
        const newMember = new Member({
            name: name.trim(),
            email: email.toLowerCase().trim(),
            Organization: organizationId,
            password: hashedPassword // Set default password as requested
        });

        // Save the member
        const savedMember = await newMember.save();

        // Add member to organization's members array
        await Organization.findByIdAndUpdate(
            organizationId,
            { $push: { members: savedMember._id } },
            { new: true }
        );

        // Return success response (exclude password from response)
        const memberResponse = {
            _id: savedMember._id,
            name: savedMember.name,
            email: savedMember.email,
            Organization: savedMember.Organization
        };

        res.status(201).json({
            success: true,
            message: 'Member added successfully',
            member: memberResponse
        });

    } catch (error) {
        console.error('Error adding member:', error);
        
        // Handle mongoose validation errors
        if (error.name === 'ValidationError') {
            const errors = Object.values(error.errors).map(err => err.message);
            return res.status(400).json({
                success: false,
                message: 'Validation error',
                errors: errors
            });
        }

        // Handle duplicate key error (in case email uniqueness is enforced at DB level)
        if (error.code === 11000) {
            return res.status(409).json({
                success: false,
                message: 'A member with this email address already exists'
            });
        }

        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// GET /api/members/organization/:orgId - Get all members of an organization
router.get('/organization/:orgId', async (req, res) => {
    try {
        const { orgId } = req.params;

        // Check if organization exists
        const organization = await Organization.findById(orgId);
        if (!organization) {
            return res.status(404).json({
                success: false,
                message: 'Organization not found'
            });
        }

        // Get all members of the organization (exclude passwords)
        const members = await Member.find({ Organization: orgId })
            .select('-password')
            .populate('Organization', 'OrganizationName');

        res.status(200).json({
            success: true,
            members: members,
            organizationName: organization.OrganizationName
        });

    } catch (error) {
        console.error('Error fetching members:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// DELETE /api/members/:memberId - Delete a member
router.delete('/:memberId', async (req, res) => {
    try {
        const { memberId } = req.params;

        // Find the member
        const member = await Member.findById(memberId);
        if (!member) {
            return res.status(404).json({
                success: false,
                message: 'Member not found'
            });
        }

        // Remove member from organization's members array
        await Organization.findByIdAndUpdate(
            member.Organization,
            { $pull: { members: memberId } }
        );

        // Delete the member
        await Member.findByIdAndDelete(memberId);

        res.status(200).json({
            success: true,
            message: 'Member deleted successfully'
        });

    } catch (error) {
        console.error('Error deleting member:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

module.exports = router;
