import express from 'express';
import { User } from '../models/index.js';
import { authenticateToken, authorizeRoles } from '../middlewares/auth.js';

const router = express.Router();

// Apply global middlewares: user must be authenticated AND must be an Admin
router.use(authenticateToken);
router.use(authorizeRoles('Admin'));

// GET /api/users - List all users
router.get('/', async (req, res) => {
  try {
    const users = await User.findAll({
      attributes: { exclude: ['password'] },
      order: [['createdAt', 'DESC']],
    });
    res.json(users);
  } catch (error) {
    console.error('List users error:', error);
    res.status(500).json({ error: 'Server error listing users' });
  }
});

// POST /api/users - Admin manually creates a student or faculty account
router.post('/', async (req, res) => {
  try {
    const { name, email, password, role, department } = req.body;

    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(400).json({ error: 'Email already exists' });
    }

    const newUser = await User.create({ name, email, password, role, department });
    res.status(201).json({
      message: 'User created successfully',
      user: { id: newUser.id, name: newUser.name, email: newUser.email, role: newUser.role, department: newUser.department }
    });
  } catch (error) {
    console.error('Create user error:', error);
    res.status(500).json({ error: 'Server error creating user' });
  }
});

// PUT /api/users/:id - Update user account details
router.put('/:id', async (req, res) => {
  try {
    const { name, department, role, isActive } = req.body;
    const user = await User.findByPk(req.params.id);

    if (!user) return res.status(404).json({ error: 'User not found' });

    await user.update({ name, department, role, isActive });
    res.json({ message: 'User updated successfully', user });
  } catch (error) {
    console.error('Update user error:', error);
    res.status(500).json({ error: 'Server error updating user' });
  }
});

// DELETE /api/users/:id - Deactivate/suspend a user
router.delete('/:id', async (req, res) => {
  try {
    const user = await User.findByPk(req.params.id);
    if (!user) return res.status(404).json({ error: 'User not found' });

    // Set active to false (soft suspend)
    await user.update({ isActive: false });
    res.json({ message: 'User suspended successfully' });
  } catch (error) {
    console.error('Deactivate user error:', error);
    res.status(500).json({ error: 'Server error deactivating user' });
  }
});

export default router;
