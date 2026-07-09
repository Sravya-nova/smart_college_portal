import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import sequelize from './src/config/db.js';
import './src/models/index.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5001;

// Global Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

import authRoutes from './src/routes/auth.js';
import userRoutes from './src/routes/users.js';
import noticeRoutes from './src/routes/notices.js';
import attendanceRoutes from './src/routes/attendance.js';
import assignmentRoutes from './src/routes/assignments.js';
import complaintRoutes from './src/routes/complaints.js';
import placementRoutes from './src/routes/placement.js';

// Route Handlers
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/notices', noticeRoutes);
app.use('/api/attendance', attendanceRoutes);
app.use('/api/assignments', assignmentRoutes);
app.use('/api/complaints', complaintRoutes);
app.use('/api/placement', placementRoutes);

// Health Check / Status Route
app.get('/api/status', (req, res) => {
  res.json({
    status: 'online',
    timestamp: new Date(),
    environment: process.env.NODE_ENV || 'development',
    database: 'sqlite'
  });
});

// Database Sync and Start Server
async function startServer() {
  try {
    await sequelize.authenticate();
    console.log('✓ SQLite Database connected successfully.');
    
    // Sync models (will build tables as models are loaded)
    await sequelize.sync({ alter: true });
    console.log('✓ Database tables synchronized.');

    app.listen(PORT, () => {
      console.log(`🚀 Server running on http://localhost:${PORT}`);
    });
  } catch (error) {
    console.error('✗ Unable to start server:', error);
    process.exit(1);
  }
}

startServer();
