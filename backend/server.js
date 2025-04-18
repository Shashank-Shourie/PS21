const express = require('express');
const multer = require('multer');
const cors = require('cors');
const fs = require('fs');
require('dotenv').config();
const { TextractClient, AnalyzeDocumentCommand } = require('@aws-sdk/client-textract');

const app = express();
app.use(express.json());
app.use(cors());

// AWS Configuration
const textractClient = new TextractClient({
  region: process.env.AWS_REGION || 'us-east-1',
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
  }
});

// File upload configuration
const upload = multer({
  dest: 'uploads/',
  limits: { fileSize: 10 * 1024 * 1024 } // 10MB limit
});

// Text extraction endpoint
app.post('/api/extract-text', upload.single('file'), async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ 
      error: "No file uploaded",
      details: "Please provide a PDF file"
    });
  }

  const filePath = req.file.path;
  console.log(`Processing file: ${req.file.originalname}`);

  try {
    const fileBuffer = fs.readFileSync(filePath);
    
    // Validate file content
    if (fileBuffer.length === 0) {
      throw new Error("Empty file received");
    }

    // AWS Textract request
    const params = {
      Document: { Bytes: fileBuffer },
      FeatureTypes: ["TABLES", "FORMS"]
    };

    console.log("Sending to AWS Textract...");
    const data = await textractClient.send(new AnalyzeDocumentCommand(params));
    
    if (!data.Blocks || data.Blocks.length === 0) {
      return res.status(400).json({ 
        error: "No text found",
        details: "The document may be image-only or corrupted"
      });
    }

    // Process extracted text
    const extractedText = data.Blocks
      .filter(block => block.BlockType === "LINE")
      .map(line => line.Text)
      .join("\n");

    res.setHeader('Content-Type', 'application/json');
    res.json({
      success: true,
      extractedText,
      pageCount: data.DocumentMetadata?.Pages || 1
    });

  } catch (error) {
    console.error("Processing error:", error);
    
    const statusCode = error.$metadata?.httpStatusCode || 500;
    const errorResponse = {
      error: error.message || "Document processing failed",
      details: error.name || "Internal server error"
    };

    if (error.$metadata) {
      errorResponse.awsStatus = error.$metadata.httpStatusCode;
      errorResponse.requestId = error.$metadata.requestId;
    }

    res.setHeader('Content-Type', 'application/json');
    res.status(statusCode).json(errorResponse);
  } finally {
    // Clean up uploaded file
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.json({ 
    status: 'OK', 
    service: 'PDF Text Extraction',
    timestamp: new Date().toISOString()
  });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`AWS Region: ${process.env.AWS_REGION || 'ap-south-1'}`);
});