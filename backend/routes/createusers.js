const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Organization = require('../models/Organization.js');
const Member = require('../models/Members.js');
const User = require('../models/User.js');

const router = express.Router();

router.post('/userregister',async(req,res)=>{
    try {
        const {_name,_email,_organization} = req.body;
        const organization = await Organization.findOne({_organization});
        const orgid = organization._id;
        const password = 'default';
        const hashedPassword = bcrypt.hash(password,10);
        const newuser = new User({
            name:_name,
            password:hashedPassword,
            email:_email,
            Organization:orgid,
        });
        await newuser.save();
        res.status(201).json({message:'User added successfully',user:newuser});
        console.log(newuser);
    } catch (error) {
        console.log(error);
        res.status(500).json({error:'Server error. User not creater try again'});
    }
})

module.exports = router;
