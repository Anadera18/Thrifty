const express = require('express');
const router = express.Router();
const multer = require('multer');
const aiController = require('../controllers/ai.controller');

// In-memory upload buffer for AI processing
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 } // 10MB limit
});

/**
 * @route   POST /api/v1/ai/grade-and-classify
 * @desc    Analyze clothing photo for category classification and condition grading (A-D)
 * @access  Public / Authenticated
 */
router.post('/grade-and-classify', upload.single('image'), aiController.gradeAndClassify);

module.exports = router;
