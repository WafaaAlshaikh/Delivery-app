// src/app.js
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const http = require('http'); 
const { initializeSocket } = require('./socket');
const path = require('path');
const fs = require('fs');

dotenv.config();

const app = express();

// ===========================
// 📌 Middlewares
// ===========================
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));

app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  next();
});

// ===========================
// 📌 Create required directories
// ===========================
const requiredDirs = ['uploads', 'uploads/profiles'];
requiredDirs.forEach(dir => {
  const dirPath = path.join(__dirname, dir);
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
    console.log(`📁 Created directory: ${dir}`);
  }
});

// ===========================
// 📌 Static files
// ===========================
app.use('/uploads', express.static(path.join(__dirname, 'uploads'), {
  maxAge: '1d'
}));

// ===========================
// 📌 Routes
// ===========================
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/admin', require('./routes/adminRoutes'));
app.use('/api/driver', require('./routes/driverRoutes'));
app.use('/api/stores', require('./routes/storeRoutes'));

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Test route
app.get('/test', (req, res) => {
  res.json({ message: 'Server is running!' });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.url} not found`
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('❌ Global error:', err.message);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal server error'
  });
});

const server = http.createServer(app);
const io = initializeSocket(server);
app.set('io', io);

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`🔌 Socket.IO ready`);
});

module.exports = app;