const mongoose = require('mongoose');

const ExtractedTextSchema = new mongoose.Schema({
    content: {
        type: String,
        required: true
    },
    originalFileName: {
        type: String
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('ExtractedText', ExtractedTextSchema);
