const mongoose = require('mongoose');

const applicationSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  admissionType: { type: String, required: true },
  formData: { type: Object, required: true }, // Dynamic form fields
  docMatchPercent: { type: Number }, // e.g., 85
  status: { type: String, enum: ['draft', 'submitted', 'approved'], default: 'draft' },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Application', applicationSchema);