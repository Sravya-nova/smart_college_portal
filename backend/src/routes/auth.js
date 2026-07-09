import express from 'express';
import jwt from 'jsonwebtoken';
import { User } from '../models/index.js';
import { authenticateToken } from '../middlewares/auth.js';

const router = express.Router();

// Helper to generate access & refresh tokens
const generateTokens = (user) => {
  const payload = { id: user.id, email: user.email, role: user.role };
  const accessToken = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1h' });
  const refreshToken = jwt.sign(payload, process.env.JWT_REFRESH_SECRET, { expiresIn: '7d' });
  return { accessToken, refreshToken };
};

// POST /api/auth/signup
router.post('/signup', async (req, res) => {
  try {
    const { name, email, password, role, department } = req.body;

    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(400).json({ error: 'Email already registered' });
    }

    const newUser = await User.create({ name, email, password, role, department });
    const { accessToken, refreshToken } = generateTokens(newUser);

    res.status(201).json({
      message: 'Registration successful',
      user: { id: newUser.id, name: newUser.name, email: newUser.email, role: newUser.role },
      accessToken,
      refreshToken
    });
  } catch (error) {
    console.error('Signup error:', error);
    res.status(500).json({ error: 'Server error during signup' });
  }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ where: { email } });
    if (!user || !(await user.comparePassword(password))) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    if (!user.isActive) {
      return res.status(403).json({ error: 'Account suspended. Contact administrator.' });
    }

    const { accessToken, refreshToken } = generateTokens(user);

    res.json({
      message: 'Login successful',
      user: { id: user.id, name: user.name, email: user.email, role: user.role, department: user.department },
      accessToken,
      refreshToken
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Server error during login' });
  }
});

// POST /api/auth/refresh-token
router.post('/refresh-token', async (req, res) => {
  try {
    const { token } = req.body;
    if (!token) return res.status(401).json({ error: 'Refresh token required' });

    const decoded = jwt.verify(token, process.env.JWT_REFRESH_SECRET);
    const user = await User.findByPk(decoded.id);

    if (!user || !user.isActive) {
      return res.status(403).json({ error: 'User is suspended or invalid' });
    }

    const { accessToken, refreshToken } = generateTokens(user);
    res.json({ accessToken, refreshToken });
  } catch (error) {
    console.error('Refresh token error:', error);
    res.status(403).json({ error: 'Invalid or expired refresh token' });
  }
});

// GET /api/auth/me
router.get('/me', authenticateToken, (req, res) => {
  res.json({
    user: {
      id: req.user.id,
      name: req.user.name,
      email: req.user.email,
      role: req.user.role,
      department: req.user.department
    }
  });
});

export default router;
