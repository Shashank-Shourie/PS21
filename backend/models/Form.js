const mongoose = require('mongoose');

const formSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  
  // Personal Information
  fullName: {
    type: String,
    required: true,
    trim: true,
    maxlength: 100
  },
  
  fatherName: {
    type: String,
    required: true,
    trim: true,
    maxlength: 100
  },
  
  motherName: {
    type: String,
    trim: true,
    maxlength: 100
  },
  
  dateOfBirth: {
    type: String,
    required: true,
    trim: true
  },
  
  gender: {
    type: String,
    required: true,
    enum: ['Male', 'Female', 'Other'],
    trim: true
  },
  
  // Contact Information
  aadharNumber: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    match: [/^\d{4}\s?\d{4}\s?\d{4}$/, 'Please enter a valid Aadhar number']
  },
  
  mobileNumber: {
    type: String,
    required: true,
    trim: true,
    match: [/^\d{10}$/, 'Please enter a valid 10-digit mobile number']
  },
  
  email: {
    type: String,
    trim: true,
    lowercase: true,
    match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Please enter a valid email']
  },
  
  // Address Information
  pincode: {
    type: String,
    required: true,
    trim: true,
    match: [/^\d{6}$/, 'Please enter a valid 6-digit pincode']
  },
  
  // Academic Information
  tenthMarks: {
    type: Number,
    required: true,
    min: [0, 'Marks cannot be negative'],
    max: [100, 'Marks cannot exceed 100']
  },
  
  interMarks: {
    type: Number,
    required: true,
    min: [0, 'Marks cannot be negative'],
    max: [100, 'Marks cannot exceed 100']
  },
  
  eamcetRank: {
    type: Number,
    min: [1, 'Rank must be positive']
  },
  
  category: {
    type: String,
    required: true,
    enum: ['GENERAL', 'OC', 'SC', 'ST', 'EWS', 'OBC'],
    trim: true,
    uppercase: true
  },
  
  // Financial Information
  income: {
    type: Number,
    min: [0, 'Income cannot be negative']
  },
  
  // Verification Information
  extractedText: {
    type: String,
    required: true
  },
  
  matchPercentage: {
    type: Number,
    min: [0, 'Match percentage cannot be negative'],
    max: [100, 'Match percentage cannot exceed 100']
  },
  
  isVerified: {
    type: Boolean,
    default: false
  },
  
  verificationStatus: {
    type: String,
    enum: ['pending', 'verified', 'rejected'],
    default: 'pending'
  },
  
  // Timestamps
  submittedAt: {
    type: Date,
    default: Date.now
  },
  
  verifiedAt: {
    type: Date
  }
}, {
  timestamps: true,
  collection: 'forms'
});

// Indexes for better query performance
formSchema.index({ userId: 1, createdAt: -1 });
formSchema.index({ verificationStatus: 1 });
formSchema.index({ isVerified: 1 });
formSchema.index({ aadharNumber: 1 }, { unique: true });

// Pre-save middleware to clean up data
formSchema.pre('save', function(next) {
  // Clean up Aadhar number (remove spaces)
  if (this.aadharNumber) {
    this.aadharNumber = this.aadharNumber.replace(/\s/g, '');
  }
  
  // Convert category to uppercase
  if (this.category) {
    this.category = this.category.toUpperCase();
  }
  
  next();
});

// Instance methods
formSchema.methods.getFormSummary = function() {
  return {
    id: this._id,
    fullName: this.fullName,
    submittedAt: this.submittedAt,
    verificationStatus: this.verificationStatus,
    matchPercentage: this.matchPercentage,
    isVerified: this.isVerified
  };
};

// Static methods
formSchema.statics.findByUserId = function(userId) {
  return this.find({ userId }).sort({ createdAt: -1 });
};

formSchema.statics.findPendingForms = function() {
  return this.find({ verificationStatus: 'pending' }).sort({ createdAt: -1 });
};

const Form = mongoose.model('Form', formSchema);

module.exports = Form;