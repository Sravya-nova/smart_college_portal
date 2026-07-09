import express from 'express';
import { PlacementJob, Application, User } from '../models/index.js';
import { authenticateToken, authorizeRoles } from '../middlewares/auth.js';

const router = express.Router();

router.use(authenticateToken);

// GET /api/placement/jobs - Browse all placement jobs (Students/Officers)
router.get('/jobs', async (req, res) => {
  try {
    const jobs = await PlacementJob.findAll({
      include: { model: User, as: 'postedBy', attributes: ['id', 'name'] },
      order: [['deadline', 'ASC']],
    });
    res.json(jobs);
  } catch (error) {
    console.error('List jobs error:', error);
    res.status(500).json({ error: 'Server error listing jobs' });
  }
});

// POST /api/placement/jobs - Create job opening (Placement Officer/Admin only)
router.post('/jobs', authorizeRoles('PlacementOfficer', 'Admin'), async (req, res) => {
  try {
    const { company, title, description, requirements, deadline } = req.body;

    const newJob = await PlacementJob.create({
      company,
      title,
      description,
      requirements,
      deadline,
      postedById: req.user.id,
    });

    res.status(201).json({ message: 'Job posting created successfully', job: newJob });
  } catch (error) {
    console.error('Create job error:', error);
    res.status(500).json({ error: 'Server error creating job posting' });
  }
});

// POST /api/placement/jobs/:id/apply - Apply for job (Student only)
router.post('/jobs/:id/apply', authorizeRoles('Student'), async (req, res) => {
  try {
    const jobId = req.params.id;

    const job = await PlacementJob.findByPk(jobId);
    if (!job) return res.status(404).json({ error: 'Job opening not found' });

    // Check if deadline passed
    if (new Date(job.deadline) < new Date()) {
      return res.status(400).json({ error: 'Application deadline has passed' });
    }

    // Check for double application
    const existing = await Application.findOne({ where: { jobId, studentId: req.user.id } });
    if (existing) {
      return res.status(400).json({ error: 'You have already applied for this position' });
    }

    const application = await Application.create({
      jobId,
      studentId: req.user.id,
      status: 'Applied',
    });

    res.status(201).json({ message: 'Application submitted successfully', application });
  } catch (error) {
    console.error('Apply job error:', error);
    res.status(500).json({ error: 'Server error submitting application' });
  }
});

// GET /api/placement/jobs/:id/applicants - View all student applicants (Placement Officer/Admin only)
router.get('/jobs/:id/applicants', authorizeRoles('PlacementOfficer', 'Admin'), async (req, res) => {
  try {
    const applicants = await Application.findAll({
      where: { jobId: req.params.id },
      include: {
        model: User,
        as: 'student',
        attributes: ['id', 'name', 'email', 'department'],
      },
      order: [['createdAt', 'DESC']],
    });

    res.json(applicants);
  } catch (error) {
    console.error('Get applicants error:', error);
    res.status(500).json({ error: 'Server error retrieving applicants list' });
  }
});

// PUT /api/placement/applications/:appId - Update application status (Placement Officer/Admin only)
router.put('/applications/:appId', authorizeRoles('PlacementOfficer', 'Admin'), async (req, res) => {
  try {
    const { status } = req.body;
    const application = await Application.findByPk(req.params.appId);

    if (!application) return res.status(404).json({ error: 'Application record not found' });

    await application.update({ status });
    res.json({ message: 'Applicant status updated successfully', application });
  } catch (error) {
    console.error('Update application error:', error);
    res.status(500).json({ error: 'Server error updating application' });
  }
});

export default router;
