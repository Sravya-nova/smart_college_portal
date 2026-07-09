import express from 'express';
import { Complaint, User } from '../models/index.js';
import { authenticateToken, authorizeRoles } from '../middlewares/auth.js';

const router = express.Router();

router.use(authenticateToken);

// POST /api/complaints - Raise a new complaint (Student only)
router.post('/', authorizeRoles('Student'), async (req, res) => {
  try {
    const { title, description } = req.body;

    const newComplaint = await Complaint.create({
      title,
      description,
      studentId: req.user.id,
    });

    res.status(201).json({
      message: 'Complaint registered successfully',
      complaint: newComplaint,
    });
  } catch (error) {
    console.error('Create complaint error:', error);
    res.status(500).json({ error: 'Server error creating complaint' });
  }
});

// GET /api/complaints - List complaints (Students see own; Admins see all)
router.get('/', async (req, res) => {
  try {
    const filter = {};
    if (req.user.role === 'Student') {
      filter.studentId = req.user.id;
    }

    const complaints = await Complaint.findAll({
      where: filter,
      include: [
        { model: User, as: 'student', attributes: ['id', 'name', 'department'] },
        { model: User, as: 'assignedTo', attributes: ['id', 'name'] },
      ],
      order: [['createdAt', 'DESC']],
    });

    res.json(complaints);
  } catch (error) {
    console.error('List complaints error:', error);
    res.status(500).json({ error: 'Server error listing complaints' });
  }
});

// PUT /api/complaints/:id - Update status/assignment (Admin only)
router.put('/:id', authorizeRoles('Admin'), async (req, res) => {
  try {
    const { status, assignedToId } = req.body;
    const complaint = await Complaint.findByPk(req.params.id);

    if (!complaint) return res.status(404).json({ error: 'Complaint not found' });

    // Validate assigned admin exists
    if (assignedToId) {
      const adminUser = await User.findByPk(assignedToId);
      if (!adminUser || adminUser.role !== 'Admin') {
        return res.status(400).json({ error: 'Assigned handler must be an administrator' });
      }
      complaint.assignedToId = assignedToId;
    }

    if (status) {
      complaint.status = status;
    }

    await complaint.save();
    res.json({ message: 'Complaint updated successfully', complaint });
  } catch (error) {
    console.error('Update complaint error:', error);
    res.status(500).json({ error: 'Server error updating complaint' });
  }
});

export default router;
