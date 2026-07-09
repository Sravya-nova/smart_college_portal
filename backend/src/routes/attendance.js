import express from 'express';
import { Attendance, Course, User } from '../models/index.js';
import { authenticateToken, authorizeRoles } from '../middlewares/auth.js';

const router = express.Router();

router.use(authenticateToken);

// GET /api/attendance/courses - Helper to list academic courses
router.get('/courses', async (req, res) => {
  try {
    const courses = await Course.findAll({
      include: { model: User, as: 'instructor', attributes: ['id', 'name'] }
    });
    res.json(courses);
  } catch (error) {
    console.error('List courses error:', error);
    res.status(500).json({ error: 'Server error listing courses' });
  }
});

// POST /api/attendance/courses - Admin helper to register new course
router.post('/courses', authorizeRoles('Admin'), async (req, res) => {
  try {
    const { code, title, instructorId } = req.body;
    const newCourse = await Course.create({ code, title, instructorId });
    res.status(201).json({ message: 'Course created successfully', course: newCourse });
  } catch (error) {
    console.error('Create course error:', error);
    res.status(500).json({ error: 'Server error creating course' });
  }
});

// POST /api/attendance/mark - Mark/update attendance record (Faculty only)
router.post('/mark', authorizeRoles('Faculty', 'Admin'), async (req, res) => {
  try {
    const { studentId, courseId, date, status } = req.body;

    // Verify course exists
    const course = await Course.findByPk(courseId);
    if (!course) return res.status(404).json({ error: 'Course not found' });

    // Verify student exists and has student role
    const student = await User.findByPk(studentId);
    if (!student || student.role !== 'Student') {
      return res.status(400).json({ error: 'Invalid Student ID' });
    }

    // Check if attendance already registered for this date & course
    let attendance = await Attendance.findOne({ where: { studentId, courseId, date } });
    if (attendance) {
      await attendance.update({ status });
    } else {
      attendance = await Attendance.create({ studentId, courseId, date, status });
    }

    res.json({ message: 'Attendance marked successfully', attendance });
  } catch (error) {
    console.error('Mark attendance error:', error);
    res.status(500).json({ error: 'Server error marking attendance' });
  }
});

// GET /api/attendance/student-summary - Retrieve current student summary (Student only)
router.get('/student-summary', authorizeRoles('Student', 'Admin'), async (req, res) => {
  try {
    const studentId = req.user.role === 'Student' ? req.user.id : req.query.studentId;
    if (!studentId) return res.status(400).json({ error: 'Student ID required' });

    const attendanceRecords = await Attendance.findAll({
      where: { studentId },
      include: { model: Course, as: 'course', attributes: ['code', 'title'] },
    });

    // Group and calculate statistics
    const summaryMap = {};
    attendanceRecords.forEach(record => {
      const courseId = record.courseId;
      if (!summaryMap[courseId]) {
        summaryMap[courseId] = {
          code: record.course.code,
          title: record.course.title,
          attended: 0,
          total: 0,
        };
      }
      summaryMap[courseId].total += 1;
      if (record.status === 'Present') {
        summaryMap[courseId].attended += 1;
      }
    });

    const summaryList = Object.values(summaryMap).map(item => {
      const percent = item.total > 0 ? Math.round((item.attended / item.total) * 100) : 0;
      return {
        ...item,
        percent,
        statusText: percent >= 85 ? 'Excellent' : percent >= 75 ? 'On Track' : 'Low Attendance',
        isLow: percent < 75,
      };
    });

    res.json(summaryList);
  } catch (error) {
    console.error('Summary attendance error:', error);
    res.status(500).json({ error: 'Server error retrieving summary' });
  }
});

// GET /api/attendance/logs - Retrieve attendance list logs
router.get('/logs', async (req, res) => {
  try {
    const filter = {};

    // Filter by role visibility
    if (req.user.role === 'Student') {
      filter.studentId = req.user.id;
    } else if (req.user.role === 'Faculty') {
      // Find courses taught by this faculty member
      const courses = await Course.findAll({ where: { instructorId: req.user.id } });
      const courseIds = courses.map(c => c.id);
      filter.courseId = courseIds;
    }

    const logs = await Attendance.findAll({
      where: filter,
      include: [
        { model: User, as: 'student', attributes: ['id', 'name'] },
        { model: Course, as: 'course', attributes: ['code', 'title'] },
      ],
      order: [['date', 'DESC']],
    });

    res.json(logs);
  } catch (error) {
    console.error('List logs error:', error);
    res.status(500).json({ error: 'Server error listing attendance logs' });
  }
});

export default router;
