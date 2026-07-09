import express from 'express';
import { Assignment, Submission, Course, User } from '../models/index.js';
import { authenticateToken, authorizeRoles } from '../middlewares/auth.js';

const router = express.Router();

router.use(authenticateToken);

// GET /api/assignments - List assignments (Students/Faculty)
router.get('/', async (req, res) => {
  try {
    const filter = {};
    if (req.user.role === 'Faculty') {
      const courses = await Course.findAll({ where: { instructorId: req.user.id } });
      const courseIds = courses.map(c => c.id);
      filter.courseId = courseIds;
    }

    const assignments = await Assignment.findAll({
      where: filter,
      include: { model: Course, as: 'course', attributes: ['code', 'title'] },
      order: [['dueDate', 'ASC']],
    });

    res.json(assignments);
  } catch (error) {
    console.error('List assignments error:', error);
    res.status(500).json({ error: 'Server error listing assignments' });
  }
});

// POST /api/assignments - Create a new assignment (Faculty only)
router.post('/', authorizeRoles('Faculty', 'Admin'), async (req, res) => {
  try {
    const { title, description, courseId, dueDate } = req.body;

    const course = await Course.findByPk(courseId);
    if (!course) return res.status(404).json({ error: 'Course not found' });

    // Enforce faculty matches instructor
    if (req.user.role === 'Faculty' && course.instructorId !== req.user.id) {
      return res.status(403).json({ error: 'Cannot create assignment for a course you do not teach' });
    }

    const newAssignment = await Assignment.create({ title, description, courseId, dueDate });
    res.status(201).json({ message: 'Assignment created successfully', assignment: newAssignment });
  } catch (error) {
    console.error('Create assignment error:', error);
    res.status(500).json({ error: 'Server error creating assignment' });
  }
});

// POST /api/assignments/:id/submit - Submit assignment solution (Student only)
router.post('/:id/submit', authorizeRoles('Student'), async (req, res) => {
  try {
    const { fileUrl } = req.body;
    const assignmentId = req.params.id;

    const assignment = await Assignment.findByPk(assignmentId);
    if (!assignment) return res.status(404).json({ error: 'Assignment not found' });

    let submission = await Submission.findOne({ where: { assignmentId, studentId: req.user.id } });
    if (submission) {
      await submission.update({ fileUrl });
    } else {
      submission = await Submission.create({
        assignmentId,
        studentId: req.user.id,
        fileUrl,
      });
    }

    res.status(201).json({ message: 'Assignment submitted successfully', submission });
  } catch (error) {
    console.error('Submit assignment error:', error);
    res.status(500).json({ error: 'Server error submitting assignment' });
  }
});

// GET /api/assignments/submissions - List submissions (Faculty see course-specific; Students see own)
router.get('/submissions', async (req, res) => {
  try {
    const filter = {};
    if (req.user.role === 'Student') {
      filter.studentId = req.user.id;
    } else if (req.user.role === 'Faculty') {
      const courses = await Course.findAll({ where: { instructorId: req.user.id } });
      const courseIds = courses.map(c => c.id);
      
      const assignments = await Assignment.findAll({ where: { courseId: courseIds } });
      const assignmentIds = assignments.map(a => a.id);
      filter.assignmentId = assignmentIds;
    }

    const submissions = await Submission.findAll({
      where: filter,
      include: [
        { model: Assignment, as: 'assignment', attributes: ['title'] },
        { model: User, as: 'student', attributes: ['id', 'name'] },
      ],
      order: [['updatedAt', 'DESC']],
    });

    res.json(submissions);
  } catch (error) {
    console.error('Get submissions error:', error);
    res.status(500).json({ error: 'Server error retrieving submissions' });
  }
});

// PUT /api/assignments/submissions/:subId/grade - Grade submission and add remarks (Faculty only)
router.put('/submissions/:subId/grade', authorizeRoles('Faculty', 'Admin'), async (req, res) => {
  try {
    const { grade, remarks } = req.body;
    const submission = await Submission.findByPk(req.params.subId, {
      include: { model: Assignment, as: 'assignment', include: { model: Course, as: 'course' } }
    });

    if (!submission) return res.status(404).json({ error: 'Submission not found' });

    // Enforce faculty matches instructor
    if (req.user.role === 'Faculty' && submission.assignment.course.instructorId !== req.user.id) {
      return res.status(403).json({ error: 'Cannot grade submissions for a course you do not teach' });
    }

    await submission.update({ grade, remarks });
    res.json({ message: 'Submission graded successfully', submission });
  } catch (error) {
    console.error('Grade submission error:', error);
    res.status(500).json({ error: 'Server error grading submission' });
  }
});

export default router;
