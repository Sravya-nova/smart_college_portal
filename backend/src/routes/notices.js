import express from 'express';
import { Notice, User } from '../models/index.js';
import { authenticateToken, authorizeRoles } from '../middlewares/auth.js';

const router = express.Router();

// Apply auth globally
router.use(authenticateToken);

// GET /api/notices - List all notices (supports optional category filtering)
router.get('/', async (req, res) => {
  try {
    const { category } = req.query;
    const filter = {};
    if (category && category !== 'All') {
      filter.category = category;
    }

    const notices = await Notice.findAll({
      where: filter,
      include: {
        model: User,
        as: 'postedBy',
        attributes: ['id', 'name', 'role'],
      },
      order: [['createdAt', 'DESC']],
    });

    res.json(notices);
  } catch (error) {
    console.error('List notices error:', error);
    res.status(500).json({ error: 'Server error listing notices' });
  }
});

// POST /api/notices - Create a notice (Admin, Faculty, Placement Officer only)
router.post('/', authorizeRoles('Admin', 'Faculty', 'PlacementOfficer'), async (req, res) => {
  try {
    const { title, snippet, description, category, imageUrl } = req.body;

    const newNotice = await Notice.create({
      title,
      snippet,
      description,
      category,
      imageUrl,
      postedById: req.user.id,
    });

    res.status(201).json({
      message: 'Notice posted successfully',
      notice: newNotice,
    });
  } catch (error) {
    console.error('Create notice error:', error);
    res.status(500).json({ error: 'Server error creating notice' });
  }
});

// DELETE /api/notices/:id - Delete/archive notice (Admin or creator only)
router.delete('/:id', async (req, res) => {
  try {
    const notice = await Notice.findByPk(req.params.id);
    if (!notice) return res.status(404).json({ error: 'Notice not found' });

    // Grant deletion permission to Admin or creator
    if (req.user.role !== 'Admin' && notice.postedById !== req.user.id) {
      return res.status(403).json({ error: 'Unauthorized to delete this notice' });
    }

    await notice.destroy();
    res.json({ message: 'Notice deleted successfully' });
  } catch (error) {
    console.error('Delete notice error:', error);
    res.status(500).json({ error: 'Server error deleting notice' });
  }
});

export default router;
