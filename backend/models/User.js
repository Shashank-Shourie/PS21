const mongoose = require('mongoose');
const Organization = require('./Organization');

const UserSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    password: {
        type: String,
        required: true
    },
    email: {
        type: String,
        required: true,
        unique: true
    },
    submitted: {
        type: Boolean,
        required: true,
        default: false
    },
    Organization: {
        type: mongoose.Schema.Types.ObjectId,
        ref: Organization,
        required: true
    },
    percentage_matched:{
        type: Number,
        required:true,
        default: -1
    }
})

module.exports = mongoose.model('User', UserSchema);