const mongoose = require('mongoose');

const FormSchema = new mongoose.Schema({
    createdBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Members', // The member who created the form
        required: true
    },
    organization: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Organization',
        required: true
    },
    fields: {
        name: { type: Boolean, default: false },
        eamcetRank: { type: Boolean, default: false },
        jeeRank: { type: Boolean, default: false },
        aadharCopy: { type: Boolean, default: false },
        rankCardCopy: { type: Boolean, default: false }
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Form', FormSchema);
