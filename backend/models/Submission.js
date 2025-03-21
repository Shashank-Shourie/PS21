const mongoose = require('mongoose');

const SubmissionSchema = new mongoose.Schema({
    form: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Form',
        required: true
    },
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    responses: {
        name: { type: String },
        eamcetRank: { type: Number },
        jeeRank: { type: Number },
        aadharCopy: { type: String }, // Can be a file URL
        rankCardCopy: { type: String } // Can be a file URL
    },
    submittedAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Submission', SubmissionSchema);
