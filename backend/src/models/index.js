import User from './User.js';
import Notice from './Notice.js';
import Course from './Course.js';
import Attendance from './Attendance.js';
import Assignment from './Assignment.js';
import Submission from './Submission.js';
import Complaint from './Complaint.js';
import PlacementJob from './PlacementJob.js';
import Application from './Application.js';

// Associations

// Notice - User (Posted By)
User.hasMany(Notice, { foreignKey: 'postedById', onDelete: 'CASCADE' });
Notice.belongsTo(User, { as: 'postedBy', foreignKey: 'postedById' });

// Course - User (Instructor)
User.hasMany(Course, { foreignKey: 'instructorId', onDelete: 'SET NULL' });
Course.belongsTo(User, { as: 'instructor', foreignKey: 'instructorId' });

// Attendance - User (Student) & Course
User.hasMany(Attendance, { foreignKey: 'studentId', onDelete: 'CASCADE' });
Attendance.belongsTo(User, { as: 'student', foreignKey: 'studentId' });

Course.hasMany(Attendance, { foreignKey: 'courseId', onDelete: 'CASCADE' });
Attendance.belongsTo(Course, { as: 'course', foreignKey: 'courseId' });

// Assignment - Course
Course.hasMany(Assignment, { foreignKey: 'courseId', onDelete: 'CASCADE' });
Assignment.belongsTo(Course, { as: 'course', foreignKey: 'courseId' });

// Submission - Assignment & User (Student)
Assignment.hasMany(Submission, { foreignKey: 'assignmentId', onDelete: 'CASCADE' });
Submission.belongsTo(Assignment, { as: 'assignment', foreignKey: 'assignmentId' });

User.hasMany(Submission, { foreignKey: 'studentId', onDelete: 'CASCADE' });
Submission.belongsTo(User, { as: 'student', foreignKey: 'studentId' });

// Complaint - User (Student) & User (Admin)
User.hasMany(Complaint, { foreignKey: 'studentId', onDelete: 'CASCADE' });
Complaint.belongsTo(User, { as: 'student', foreignKey: 'studentId' });

User.hasMany(Complaint, { foreignKey: 'assignedToId', onDelete: 'SET NULL' });
Complaint.belongsTo(User, { as: 'assignedTo', foreignKey: 'assignedToId' });

// PlacementJob - User (Placement Officer)
User.hasMany(PlacementJob, { foreignKey: 'postedById', onDelete: 'SET NULL' });
PlacementJob.belongsTo(User, { as: 'postedBy', foreignKey: 'postedById' });

// Application - PlacementJob & User (Student)
PlacementJob.hasMany(Application, { foreignKey: 'jobId', onDelete: 'CASCADE' });
Application.belongsTo(PlacementJob, { as: 'job', foreignKey: 'jobId' });

User.hasMany(Application, { foreignKey: 'studentId', onDelete: 'CASCADE' });
Application.belongsTo(User, { as: 'student', foreignKey: 'studentId' });

export {
  User,
  Notice,
  Course,
  Attendance,
  Assignment,
  Submission,
  Complaint,
  PlacementJob,
  Application
};
