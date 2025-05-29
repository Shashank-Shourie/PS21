const express = require('express');
const fs = require('fs');
const multer = require('multer');
require('dotenv').config();
const { TextractClient, AnalyzeDocumentCommand } = require('@aws-sdk/client-textract');

const router = express.Router();

const textractClient = new TextractClient({
  region: process.env.AWS_REGION || 'us-east-1',
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
});

const upload = multer({
  dest: 'uploads/',
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
});

// Existing text extraction route
router.post('/extract-text', upload.single('file'), async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No file uploaded', details: 'Please provide a PDF file' });
  }

  const filePath = req.file.path;
  console.log(`Processing file: ${req.file.originalname}`);

  try {
    const fileBuffer = fs.readFileSync(filePath);
    if (fileBuffer.length === 0) throw new Error('Empty file received');

    const params = {
      Document: { Bytes: fileBuffer },
      FeatureTypes: ['TABLES', 'FORMS'],
    };

    console.log('Sending to AWS Textract...');
    const data = await textractClient.send(new AnalyzeDocumentCommand(params));

    if (!data.Blocks || data.Blocks.length === 0) {
      return res.status(400).json({ error: 'No text found', details: 'The document may be image-only or corrupted' });
    }

    const extractedText = data.Blocks.filter((block) => block.BlockType === 'LINE').map((line) => line.Text).join('\n');

    res.setHeader('Content-Type', 'application/json');
    res.json({
      success: true,
      extractedText,
      pageCount: data.DocumentMetadata?.Pages || 1,
    });
  } catch (error) {
    console.error('Processing error:', error);
    const statusCode = error.$metadata?.httpStatusCode || 500;
    const errorResponse = {
      error: error.message || 'Document processing failed',
      details: error.name || 'Internal server error',
    };

    if (error.$metadata) {
      errorResponse.awsStatus = error.$metadata.httpStatusCode;
      errorResponse.requestId = error.$metadata.requestId;
    }

    res.setHeader('Content-Type', 'application/json');
    res.status(statusCode).json(errorResponse);
  } finally {
    if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
  }
});

// New route to compare form data with PDF content
router.post('/compare-form', upload.single('file'), async (req, res) => {
  if (!req.file || !req.body.formData) {
    return res.status(400).json({ error: 'Missing file or form data' });
  }

  const formData = JSON.parse(req.body.formData);
  const filePath = req.file.path;

  try {
    const fileBuffer = fs.readFileSync(filePath);
    const params = {
      Document: { Bytes: fileBuffer },
      FeatureTypes: ['TABLES', 'FORMS'],
    };
    const data = await textractClient.send(new AnalyzeDocumentCommand(params));

    const extractedText = data.Blocks.filter((b) => b.BlockType === 'LINE').map((b) => b.Text.toLowerCase());

    const comparisonResults = {};
    for (const [key, value] of Object.entries(formData)) {
      const lowerVal = String(value).toLowerCase();
      const match = extractedText.find((text) => text.includes(lowerVal));
      comparisonResults[key] = match ? 'match' : 'not found';
    }

    res.json({ success: true, comparison: comparisonResults });
  } catch (error) {
    console.error('Comparison error:', error);
    res.status(500).json({ error: 'Comparison failed', details: error.message });
  } finally {
    if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
  }
});

router.get('/health', (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.json({ status: 'OK', service: 'PDF Text Extraction', timestamp: new Date().toISOString() });
});

module.exports = router;
