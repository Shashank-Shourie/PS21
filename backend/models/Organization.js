const mongoose = require('mongoose');

const OrganizationSchema = new mongoose.Schema({
    OrganizationName: {
        type: String,
        required: true
    },
    members: [
        {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Member'
        }
    ]
});

module.exports = mongoose.model('Organization', OrganizationSchema);
