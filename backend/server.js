const express = require('express');
const connectDB = require('./config/db');
// const cors = require('cors');

const app = express();

connectDB();
app.use(express.json());


const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));