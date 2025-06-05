const express = require('express');
// const multer = require('multer');
const cors = require('cors');
// const fs = require('fs');
const connectDB = require('./config/db');
require('dotenv').config();
// const { TextractClient, AnalyzeDocumentCommand } = require('@aws-sdk/client-textract');

require('dotenv').config();
const app = express();

connectDB();


app.use(express.json());
app.use(cors());
app.use('/api/auth', require('./routes/auth'));
app.use('/extract',require('./routes/awstextract'))
app.use('/user',require('./routes/createusers'));
app.use('/storeform',require('./routes/form'))


const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`AWS Region: ${process.env.AWS_REGION || 'ap-south-1'}`);
});