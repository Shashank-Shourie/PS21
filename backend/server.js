const express = require('express');
const connectDB = require('./config/db');
const multer = require('multer');
const cors = require('cors');
const fs = require('fs');
require('dotenv').config();

const { TextractClient, AnalyzeDocumentCommand } = require('@aws-sdk/client-textract');
const ExtractedText = require('./models/ExtractedText');
const app = express();
connectDB();
app.use(express.json());
app.use(cors());

// Import and use routes
app.use('/api/auth', require('./routes/auth'));
const textractClient = new TextractClient({
    region: process.env.AWS_REGION,
    credentials: {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
    }
});

const upload = multer({ dest: 'uploads/' });

app.post('/api/extract-text', upload.single('file'), async (req, res) => {
    try {
        console.log("Received request");  
        if (!req.file) {
            console.log("No file received");  
            return res.status(400).json({ error: "No file uploaded" });
        }
        console.log("File uploaded:", req.file); 
        const filePath = req.file.path;
        const fileContents = fs.readFileSync(filePath);

        console.log("File read successfully");
        const params = {
            Document: { Bytes: fileContents },
            FeatureTypes: ["TABLES", "FORMS"]
        };
        const command = new AnalyzeDocumentCommand(params);
        const data = await textractClient.send(command);
        console.log("AWS Response:", data);
        const extractedText = data.Blocks
            .filter(block => block.BlockType === "LINE")
            .map(line => line.Text)
            .join(" ");
        console.log("Extracted text:", extractedText); 
        res.json({ extractedText });
    } catch (error) {
        console.error("Server Error:", error); 
        res.status(500).send("Server error");
    }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
