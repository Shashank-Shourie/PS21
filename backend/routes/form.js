const express = require('express');
const router = express.Router();
const Form = require('../models/Form'); // Adjust path as needed

// Validation middleware
const validateFormData = (req, res, next) => {
  const {
    fullName,
    fatherName,
    dateOfBirth,
    gender,
    aadharNumber,
    mobileNumber,
    pincode,
    tenthMarks,
    interMarks,
    category,
    extractedText
  } = req.body;

  // Required field validation
  const requiredFields = {
    fullName,
    fatherName,
    dateOfBirth,
    gender,
    aadharNumber,
    mobileNumber,
    pincode,
    tenthMarks,
    interMarks,
    category,
    extractedText
  };

  const missingFields = Object.entries(requiredFields)
    .filter(([key, value]) => !value || (typeof value === 'string' && value.trim() === ''))
    .map(([key]) => key);

  if (missingFields.length > 0) {
    return res.status(400).json({
      success: false,
      message: 'Missing required fields',
      missingFields
    });
  }

  // Validate Aadhar number format
  const aadharRegex = /^\d{4}\s?\d{4}\s?\d{4}$/;
  if (!aadharRegex.test(aadharNumber)) {
    return res.status(400).json({
      success: false,
      message: 'Invalid Aadhar number format'
    });
  }

  // Validate mobile number format
  const mobileRegex = /^\d{10}$/;
  if (!mobileRegex.test(mobileNumber)) {
    return res.status(400).json({
      success: false,
      message: 'Invalid mobile number format'
    });
  }

  // Validate pincode format
  const pincodeRegex = /^\d{6}$/;
  if (!pincodeRegex.test(pincode)) {
    return res.status(400).json({
      success: false,
      message: 'Invalid pincode format'
    });
  }

  // Validate gender
  const validGenders = ['Male', 'Female', 'Other'];
  if (!validGenders.includes(gender)) {
    return res.status(400).json({
      success: false,
      message: 'Invalid gender value'
    });
  }

  // Validate category
  const validCategories = ['GENERAL', 'OC', 'SC', 'ST', 'EWS', 'OBC'];
  if (!validCategories.includes(category.toUpperCase())) {
    return res.status(400).json({
      success: false,
      message: 'Invalid category value'
    });
  }

  // Validate marks
  if (tenthMarks < 0 || tenthMarks > 100) {
    return res.status(400).json({
      success: false,
      message: '10th marks must be between 0 and 100'
    });
  }

  if (interMarks < 0 || interMarks > 100) {
    return res.status(400).json({
      success: false,
      message: 'Inter marks must be between 0 and 100'
    });
  }

  next();
};

// POST /form - Create new form submission
router.post('/form', validateFormData, async (req, res) => {
  try {
    const {
      fullName,
      fatherName,
      motherName,
      dateOfBirth,
      gender,
      aadharNumber,
      mobileNumber,
      email,
      pincode,
      tenthMarks,
      interMarks,
      eamcetRank,
      category,
      income,
      extractedText,
      matchPercentage
    } = req.body;

    // Check if user already has a form submission
    const existingForm = await Form.findOne({ userId: req.user.id });
    if (existingForm) {
      return res.status(409).json({
        success: false,
        message: 'Form already submitted for this user',
        existingFormId: existingForm._id
      });
    }

    // Check if Aadhar number already exists
    const existingAadhar = await Form.findOne({ 
      aadharNumber: aadharNumber.replace(/\s/g, '') 
    });
    if (existingAadhar) {
      return res.status(409).json({
        success: false,
        message: 'Aadhar number already registered'
      });
    }

    // Create new form
    const newForm = new Form({
      userId: req.user.id,
      fullName: fullName.trim(),
      fatherName: fatherName.trim(),
      motherName: motherName?.trim(),
      dateOfBirth: dateOfBirth.trim(),
      gender,
      aadharNumber,
      mobileNumber,
      email: email?.trim().toLowerCase(),
      pincode,
      tenthMarks: parseFloat(tenthMarks),
      interMarks: parseFloat(interMarks),
      eamcetRank: eamcetRank ? parseInt(eamcetRank) : undefined,
      category: category.toUpperCase(),
      income: income ? parseFloat(income) : undefined,
      extractedText,
      matchPercentage: matchPercentage || 0,
      isVerified: matchPercentage >= 50,
      verificationStatus: matchPercentage >= 80 ? 'verified' : 'pending'
    });

    const savedForm = await newForm.save();

    res.status(201).json({
      success: true,
      message: 'Form submitted successfully',
      data: {
        formId: savedForm._id,
        matchPercentage: savedForm.matchPercentage,
        verificationStatus: savedForm.verificationStatus,
        isVerified: savedForm.isVerified,
        submittedAt: savedForm.submittedAt
      }
    });

  } catch (error) {
    console.error('Error creating form:', error);
    
    // Handle mongoose validation errors
    if (error.name === 'ValidationError') {
      const validationErrors = Object.values(error.errors).map(err => ({
        field: err.path,
        message: err.message
      }));
      
      return res.status(400).json({
        success: false,
        message: 'Validation error',
        errors: validationErrors
      });
    }

    // Handle duplicate key errors
    if (error.code === 11000) {
      const field = Object.keys(error.keyPattern)[0];
      return res.status(409).json({
        success: false,
        message: `${field} already exists`
      });
    }

    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// GET /form/:userId - Get form by user ID
router.get('/form/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    
    // Check if user is requesting their own form or has admin privileges
    if (req.user.id !== userId && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Access denied'
      });
    }

    const form = await Form.findOne({ userId }).populate('userId', 'name email');
    
    if (!form) {
      return res.status(404).json({
        success: false,
        message: 'Form not found'
      });
    }

    res.json({
      success: true,
      data: form
    });

  } catch (error) {
    console.error('Error fetching form:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// PUT /form/:formId - Update form
router.put('/form/:formId', validateFormData, async (req, res) => {
  try {
    const { formId } = req.params;
    
    const form = await Form.findById(formId);
    if (!form) {
      return res.status(404).json({
        success: false,
        message: 'Form not found'
      });
    }

    // Check if user owns the form
    if (form.userId.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Access denied'
      });
    }

    // Don't allow updates to verified forms
    if (form.verificationStatus === 'verified') {
      return res.status(400).json({
        success: false,
        message: 'Cannot update verified form'
      });
    }

    // Update form fields
    const updateFields = [
      'fullName', 'fatherName', 'motherName', 'dateOfBirth', 'gender',
      'aadharNumber', 'mobileNumber', 'email', 'pincode', 'tenthMarks',
      'interMarks', 'eamcetRank', 'category', 'income', 'extractedText',
      'matchPercentage'
    ];

    updateFields.forEach(field => {
      if (req.body[field] !== undefined) {
        form[field] = req.body[field];
      }
    });

    // Update verification status based on match percentage
    if (req.body.matchPercentage !== undefined) {
      form.isVerified = req.body.matchPercentage >= 50;
      form.verificationStatus = req.body.matchPercentage >= 80 ? 'verified' : 'pending';
    }

    const updatedForm = await form.save();

    res.json({
      success: true,
      message: 'Form updated successfully',
      data: updatedForm.getFormSummary()
    });

  } catch (error) {
    console.error('Error updating form:', error);
    
    if (error.name === 'ValidationError') {
      const validationErrors = Object.values(error.errors).map(err => ({
        field: err.path,
        message: err.message
      }));
      
      return res.status(400).json({
        success: false,
        message: 'Validation error',
        errors: validationErrors
      });
    }

    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// GET /forms - Get all forms (admin only)
router.get('/forms', async (req, res) => {
  try {
    // Check admin privileges
    if (req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Admin access required'
      });
    }

    const { status, page = 1, limit = 10 } = req.query;
    const query = {};
    
    if (status) {
      query.verificationStatus = status;
    }

    const forms = await Form.find(query)
      .populate('userId', 'name email')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await Form.countDocuments(query);

    res.json({
      success: true,
      data: forms,
      pagination: {
        currentPage: page,
        totalPages: Math.ceil(total / limit),
        totalItems: total,
        itemsPerPage: limit
      }
    });

  } catch (error) {
    console.error('Error fetching forms:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// DELETE /form/:formId - Delete form
router.delete('/form/:formId', async (req, res) => {
  try {
    const { formId } = req.params;
    
    const form = await Form.findById(formId);
    if (!form) {
      return res.status(404).json({
        success: false,
        message: 'Form not found'
      });
    }

    // Check if user owns the form or is admin
    if (form.userId.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Access denied'
      });
    }

    await Form.findByIdAndDelete(formId);

    res.json({
      success: true,
      message: 'Form deleted successfully'
    });

  } catch (error) {
    console.error('Error deleting form:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

module.exports = router;