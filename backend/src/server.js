const express = require('express');
const cors = require('cors');
require('dotenv').config();

const aiRoutes = require('./routes/ai.routes');

const app = express();
const PORT = process.env.PORT || 5000;

// Middlewares
app.use(cors());
app.use(express.json({ limit: '15mb' }));
app.use(express.urlencoded({ extended: true, limit: '15mb' }));

// Health Check
app.get('/api/v1/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    service: 'Thrifty Backend API',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// AI Routes
app.use('/api/v1/ai', aiRoutes);

// Root route
app.get('/', (req, res) => {
  res.send({
    message: 'Welcome to Thrifty Backend API',
    endpoints: {
      health: '/api/v1/health',
      aiGrading: 'POST /api/v1/ai/grade-and-classify'
    }
  });
});

app.listen(PORT, () => {
  console.log(`===============================================`);
  console.log(`  Thrifty Backend running on port ${PORT}`);
  console.log(`  AI Endpoint: http://localhost:${PORT}/api/v1/ai/grade-and-classify`);
  console.log(`===============================================`);
});

module.exports = app;
