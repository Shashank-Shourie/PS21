const express = require('express');
const fs = require('fs').promises;
const multer = require('multer');
require('dotenv').config();
const { TextractClient, AnalyzeDocumentCommand } = require('@aws-sdk/client-textract');

const router = express.Router();

const textractClient = new TextractClient({
  region: process.env.AWS_REGION || 'us-east-1',
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
  }
});

const upload = multer({
  dest: 'uploads/',
  limits: { fileSize: 10 * 1024 * 1024 }
});

router.post('/extract-text', upload.single('file'), async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: "No file uploaded", details: "Please provide a PDF file" });
  }

  const filePath = req.file.path;
  const originalName = req.file.originalname;
  console.log(`Processing file: ${originalName}`);

  try {
    const fileBuffer = await fs.readFile(filePath);

    if (fileBuffer.length === 0) {
      throw new Error("Empty file received");
    }

    if (req.file.mimetype !== 'application/pdf') {
      return res.status(400).json({ error: "Invalid file type", details: "Only PDF files are allowed" });
    }

    const params = {
      Document: { Bytes: fileBuffer },
      FeatureTypes: ["TABLES", "FORMS"]
    };

    console.log("Sending to AWS Textract...");
    const data = await textractClient.send(new AnalyzeDocumentCommand(params));

    if (!data.Blocks || data.Blocks.length === 0) {
      return res.status(400).json({ error: "No text found", details: "The document may be image-only or corrupted" });
    }

    const extractedText = data.Blocks
      .filter(block => block.BlockType === "LINE")
      .map(line => line.Text)
      .join("\n");

    res.setHeader('Content-Type', 'application/json');
    res.json({ success: true, extractedText, pageCount: data.DocumentMetadata?.Pages || 1 });
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
    try {
      await fs.unlink(filePath);
    } catch (cleanupErr) {
      console.warn(`Failed to delete temp file: ${filePath}`, cleanupErr);
    }
  }
});

router.get('/health', (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.json({ status: 'OK', service: 'PDF Text Extraction', timestamp: new Date().toISOString() });
});

module.exports = router;
