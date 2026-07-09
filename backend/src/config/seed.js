import sequelize from './db.js';
import { User, Notice, Course, Attendance, Assignment, PlacementJob } from '../models/index.js';

async function seedDatabase() {
  try {
    await sequelize.authenticate();
    console.log('Connecting to database for seeding...');

    // Clear database and recreate tables
    await sequelize.sync({ force: true });
    console.log('Database tables cleared and recreated.');

    // 1. Create Default Users for all 4 roles
    const admin = await User.create({
      name: 'Super Administrator',
      email: 'admin@campus.edu',
      password: 'admin123',
      role: 'Admin',
      department: 'Campus Administration',
    });

    const faculty = await User.create({
      name: 'Prof. Sarah Jenkins',
      email: 'jenkins@campus.edu',
      password: 'faculty123',
      role: 'Faculty',
      department: 'Computer Science & Engineering, BEC Bapatla',
    });

    const student = await User.create({
      name: 'Alex Thompson',
      email: 'student@campus.edu',
      password: 'student123',
      role: 'Student',
      department: 'CSE (AI & ML), BEC Bapatla',
    });

    const placementOfficer = await User.create({
      name: 'Director Jane Vance',
      email: 'placement@campus.edu',
      password: 'officer123',
      role: 'PlacementOfficer',
      department: 'Training & Placements Cell, BEC',
    });

    console.log('✓ Seeded Users (Admin, Faculty, Student, Placement Officer).');

    // 2. Create Default Academic Courses
    const course1 = await Course.create({
      code: 'ENG-402',
      title: 'Systems Engineering',
      instructorId: faculty.id,
    });

    const course2 = await Course.create({
      code: 'PHY-301',
      title: 'Quantum Physics II',
      instructorId: faculty.id,
    });

    const course3 = await Course.create({
      code: 'MTH-205',
      title: 'Linear Algebra',
      instructorId: faculty.id,
    });

    const course4 = await Course.create({
      code: 'CS499',
      title: 'AI Ethics Seminar',
      instructorId: faculty.id,
    });

    console.log('✓ Seeded Academic Courses.');

    // 3. Create Default Attendance Logs (to match 85%, 72%, and 94% statistics)
    
    // Systems Engineering (ENG-402): 24 present / 28 total = 85%
    for (let i = 1; i <= 24; i++) {
      await Attendance.create({
        studentId: student.id,
        courseId: course1.id,
        date: `2023-10-${i.toString().padStart(2, '0')}`,
        status: 'Present',
      });
    }
    for (let i = 25; i <= 28; i++) {
      await Attendance.create({
        studentId: student.id,
        courseId: course1.id,
        date: `2023-10-${i.toString().padStart(2, '0')}`,
        status: 'Absent',
      });
    }

    // Quantum Physics II (PHY-301): 18 present / 25 total = 72%
    for (let i = 1; i <= 18; i++) {
      await Attendance.create({
        studentId: student.id,
        courseId: course2.id,
        date: `2023-10-${i.toString().padStart(2, '0')}`,
        status: 'Present',
      });
    }
    for (let i = 19; i <= 25; i++) {
      await Attendance.create({
        studentId: student.id,
        courseId: course2.id,
        date: `2023-10-${i.toString().padStart(2, '0')}`,
        status: 'Absent',
      });
    }

    // Linear Algebra (MTH-205): 30 present / 32 total = 94%
    for (let i = 1; i <= 30; i++) {
      await Attendance.create({
        studentId: student.id,
        courseId: course3.id,
        date: `2023-10-${i.toString().padStart(2, '0')}`,
        status: 'Present',
      });
    }
    for (let i = 31; i <= 32; i++) {
      await Attendance.create({
        studentId: student.id,
        courseId: course3.id,
        date: `2023-10-${i.toString().padStart(2, '0')}`,
        status: 'Absent',
      });
    }

    console.log('✓ Seeded Student Attendance Logs.');

    // 4. Create Default Notices
    await Notice.create({
      title: 'BEC-FEST 2026: National Technical Symposium',
      category: 'Events',
      snippet: 'Registrations are officially open for BEC-FEST 2026! Participate in coding hackathons, technical paper presentations, and robotics events.',
      description: 'Bapatla Engineering College is excited to announce the national-level student technical symposium, BEC-FEST 2026. This year’s edition hosts over 25+ events across Computer Science, Electronics, Electrical, Mechanical, Civil, and Chemical streams.\n\nEvents include Hackathons, Robowars, CAD Design Challenges, Paper Presentations, and Workshops on Generative AI. Cash prizes worth Rs. 2,00,000 are up for grabs!\n\nRegistration deadline: July 20, 2026\nMain Event: July 28-30, 2026\nRegister at the Student Activity Desk or online via the portal.',
      imageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&auto=format&fit=crop',
      postedById: admin.id,
    });

    await Notice.create({
      title: 'B.Tech R20 & R24 Semester Exam Registration',
      category: 'Academic',
      snippet: 'Examinations fee payment notifications and registration schedules are active for B.Tech semesters under R20/R24 regulations.',
      description: 'The Office of the Controller of Examinations at Bapatla Engineering College has released the exam fee notification circulars for the upcoming end-semester examinations.\n\nStudents belonging to R20 and R24 regulations must log in to their student portal accounts to verify their eligibility (minimum 75% attendance is mandatory) and make the online fee payment.\n\nAdmit Card download starts: July 15, 2026\nExams start: July 22, 2026',
      imageUrl: 'https://images.unsplash.com/photo-1506784983877-45594efa4cbe?w=800&auto=format&fit=crop',
      postedById: admin.id,
    });

    await Notice.create({
      title: 'Campus Drive: PEGA Systems & TCS Recruitment',
      category: 'Placement',
      snippet: 'Pre-placement talk and programming rounds for final year B.Tech CSE, CSE-AIML, CSE-DS, IT, and ECE students. Eligible CGPA: 7.0+.',
      description: 'The Training & Placement Cell of BEC Bapatla is hosting a joint recruitment drive with PEGA Systems and Tata Consultancy Services (TCS) for software engineer roles.\n\nRegistration is mandatory on the placement portal. All eligible final year students with no active backlogs must attend. Formal dress code is strictly required.\n\nSchedule:\nPEGA Systems PPT & Assessment: July 12, 09:30 AM, Main Auditorium\nTCS Technical Interviews: July 13, 09:00 AM, CSE Block Lab 4',
      imageUrl: 'https://images.unsplash.com/photo-1521737711867-e3b90473bd58?w=800&auto=format&fit=crop',
      postedById: placementOfficer.id,
    });

    await Notice.create({
      title: 'B.Tech Admissions 2026-27 Helpline Desks Active',
      category: 'Administrative',
      snippet: 'Counselling assistance desks for new B.Tech admissions are active in the Admin Block. Contact details inside.',
      description: 'BEC Bapatla Admissions Cell announces that guidance helplines are now operational for the 2026-27 academic intake counselling process. Specialized seats are available in CSE, ECE, EEE, Civil, Mechanical, CSE-AIML, CSE-DS, and CSE-Cyber Security.\n\nFor queries, candidates can visit the Helpdesk in the Administrative Block or contact our coordinators at +91 9100 681 777 or +91 9100 682 777.',
      imageUrl: 'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=800&auto=format&fit=crop',
      postedById: admin.id,
    });

    console.log('✓ Seeded Campus Announcements.');

    // 5. Create Default Placements
    await PlacementJob.create({
      company: 'Google',
      title: 'Associate Software Engineer (Internship)',
      description: 'Join the Google Search or Cloud team for a 6-month hands-on engineering internship.',
      requirements: 'Currently enrolled in B.Tech/M.Tech 3rd or 4th year. Strong CS fundamentals and coding skills in C++, Java, or Go.',
      deadline: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days from now
      postedById: placementOfficer.id,
    });

    await PlacementJob.create({
      company: 'Microsoft',
      title: 'Software Engineer I (Full-Time)',
      description: 'Full-time software engineer roles across Windows, Azure, and Developer Tools.',
      requirements: 'Graduating in 2024. Proficient in Data Structures, Algorithms, and Object-Oriented programming.',
      deadline: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000), // 14 days from now
      postedById: placementOfficer.id,
    });

    console.log('✓ Seeded Placement Jobs.');

    console.log('🚀 Seeding Database Completed Successfully!');
    process.exit(0);
  } catch (error) {
    console.error('✗ Seeding failed:', error);
    process.exit(1);
  }
}

seedDatabase();
