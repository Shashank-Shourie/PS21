const mongoose = require('mongoose');

const ExtractedTextSchema = new mongoose.Schema({
    originalFileName: String,
    extractedText: String,
    extractedTables: Object,
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('ExtractedText', ExtractedTextSchema);
