import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart' as auth;

enum UserRole { student, faculty }
enum AttendanceTab { overview, history, scanner }
enum AttendanceStatus { present, absent, unmarked }

class SubjectAttendance {
  final String code;
  final String title;
  final int attended;
  final int total;
  final int percent;
  final String statusText;
  final bool isLow;

  const SubjectAttendance({
    required this.code,
    required this.title,
    required this.attended,
    required this.total,
    required this.percent,
    required this.statusText,
    this.isLow = false,
  });

  SubjectAttendance copyWith({
    int? attended,
    int? total,
    int? percent,
    String? statusText,
    bool? isLow,
  }) {
    return SubjectAttendance(
      code: code,
      title: title,
      attended: attended ?? this.attended,
      total: total ?? this.total,
      percent: percent ?? this.percent,
      statusText: statusText ?? this.statusText,
      isLow: isLow ?? this.isLow,
    );
  }
}

class AttendanceLogRecord {
  final String id;
  final String dateStr;
  final String subjectName;
  final String instructor;
  final bool isPresent;

  const AttendanceLogRecord({
    required this.id,
    required this.dateStr,
    required this.subjectName,
    required this.instructor,
    required this.isPresent,
  });
}

class RosterStudent {
  final String id;
  final String name;
  final int overallAttendance;
  final AttendanceStatus status;

  const RosterStudent({
    required this.id,
    required this.name,
    required this.overallAttendance,
    required this.status,
  });

  RosterStudent copyWith({
    AttendanceStatus? status,
  }) {
    return RosterStudent(
      id: id,
      name: name,
      overallAttendance: overallAttendance,
      status: status ?? this.status,
    );
  }
}

class AttendanceState {
  final UserRole role;
  final AttendanceTab activeTab;
  final List<SubjectAttendance> studentSubjects;
  final List<AttendanceLogRecord> logs;
  final String selectedLogFilter; // 'All Subjects', 'Systems Engineering', etc.
  final List<RosterStudent> facultyRoster;
  
  // Scanner state
  final bool isScannerCameraActive;
  final bool isScanning;
  final bool isScanSuccessful;
  final String? scannedRegNumber;
  final String? scannedStudentName;
  final String? scanErrorMessage;

  const AttendanceState({
    required this.role,
    required this.activeTab,
    required this.studentSubjects,
    required this.logs,
    required this.selectedLogFilter,
    required this.facultyRoster,
    required this.isScannerCameraActive,
    required this.isScanning,
    required this.isScanSuccessful,
    this.scannedRegNumber,
    this.scannedStudentName,
    this.scanErrorMessage,
  });

  AttendanceState copyWith({
    UserRole? role,
    AttendanceTab? activeTab,
    List<SubjectAttendance>? studentSubjects,
    List<AttendanceLogRecord>? logs,
    String? selectedLogFilter,
    List<RosterStudent>? facultyRoster,
    bool? isScannerCameraActive,
    bool? isScanning,
    bool? isScanSuccessful,
    String? scannedRegNumber,
    String? scannedStudentName,
    String? scanErrorMessage,
    bool clearScanned = false,
  }) {
    return AttendanceState(
      role: role ?? this.role,
      activeTab: activeTab ?? this.activeTab,
      studentSubjects: studentSubjects ?? this.studentSubjects,
      logs: logs ?? this.logs,
      selectedLogFilter: selectedLogFilter ?? this.selectedLogFilter,
      facultyRoster: facultyRoster ?? this.facultyRoster,
      isScannerCameraActive: isScannerCameraActive ?? this.isScannerCameraActive,
      isScanning: isScanning ?? this.isScanning,
      isScanSuccessful: isScanSuccessful ?? this.isScanSuccessful,
      scannedRegNumber: clearScanned ? null : (scannedRegNumber ?? this.scannedRegNumber),
      scannedStudentName: clearScanned ? null : (scannedStudentName ?? this.scannedStudentName),
      scanErrorMessage: clearScanned ? null : (scanErrorMessage ?? this.scanErrorMessage),
    );
  }
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final Ref _ref;
  Timer? _scanTimer;

  AttendanceNotifier(this._ref, auth.AuthState authState)
      : super(
          AttendanceState(
            role: authState.role == auth.UserRole.admin ? UserRole.faculty : UserRole.student,
            activeTab: AttendanceTab.overview,
            studentSubjects: authState.studentUser != null
                ? (_studentSubjectsMap[authState.studentUser!.id] ?? _initialSubjects)
                : _initialSubjects,
            logs: authState.studentUser != null
                ? (_studentLogsMap[authState.studentUser!.id] ?? _initialLogs)
                : _initialLogs,
            selectedLogFilter: 'All Subjects',
            facultyRoster: _initialRoster,
            isScannerCameraActive: false,
            isScanning: false,
            isScanSuccessful: false,
          ),
        );

  @override
  void dispose() {
    _scanTimer?.cancel();
    super.dispose();
  }

  void setRole(UserRole role) {
    // Keep setRole method signature for compatibility, but state is managed by authProvider
    state = state.copyWith(role: role);
  }

  void setTab(AttendanceTab tab) {
    state = state.copyWith(activeTab: tab);
  }

  void setLogFilter(String filter) {
    state = state.copyWith(selectedLogFilter: filter);
  }

  void toggleRosterStatus(String studentId, AttendanceStatus status) {
    final updatedRoster = state.facultyRoster.map((student) {
      if (student.id == studentId) {
        // Toggle: if clicking the same status, revert to unmarked
        return student.copyWith(
          status: student.status == status ? AttendanceStatus.unmarked : status,
        );
      }
      return student;
    }).toList();

    state = state.copyWith(facultyRoster: updatedRoster);
  }

  void activateScannerCamera() {
    state = state.copyWith(
      isScannerCameraActive: true,
      isScanning: true,
      isScanSuccessful: false,
      clearScanned: true,
    );

    // Get the logged-in student's ID (or fallback)
    final authState = _ref.read(auth.authProvider);
    final String activeId = authState.studentUser?.id ?? 'ST-202301';

    // Simulate scanning delay of 2.5 seconds (auto check-in fallback if no manual code input)
    _scanTimer?.cancel();
    _scanTimer = Timer(const Duration(milliseconds: 2500), () {
      if (state.isScanning) {
        scanRegistrationNumber(activeId); // Auto scan the logged-in student's ID
      }
    });
  }

  void resetScanner() {
    state = state.copyWith(
      isScannerCameraActive: false,
      isScanning: false,
      isScanSuccessful: false,
      clearScanned: true,
    );
  }

  void scanRegistrationNumber(String regNo) {
    _scanTimer?.cancel();
    regNo = regNo.trim().toUpperCase();
    if (regNo.isEmpty) return;

    final authState = _ref.read(auth.authProvider);

    // Enforce matching register number from the QR/Barcode for logged-in Student:
    if (authState.role == auth.UserRole.student) {
      final loggedInStudentId = authState.studentUser?.id ?? '';
      if (regNo != loggedInStudentId) {
        state = state.copyWith(
          isScannerCameraActive: false,
          isScanning: false,
          isScanSuccessful: false,
          scanErrorMessage: 'Verification Failed: Scanned code ($regNo) does not match your logged-in profile ($loggedInStudentId).',
        );
        return;
      }
    }

    // Look up in roster
    final studentIndex = state.facultyRoster.indexWhere((s) => s.id.toUpperCase() == regNo);
    String studentName = 'Visitor Student';

    if (studentIndex != -1) {
      final student = state.facultyRoster[studentIndex];
      studentName = student.name;

      // Update roster status to present
      final updatedRoster = List<RosterStudent>.from(state.facultyRoster);
      updatedRoster[studentIndex] = student.copyWith(status: AttendanceStatus.present);
      state = state.copyWith(
        facultyRoster: updatedRoster,
      );
    } else {
      // Dynamically add to roster
      studentName = 'Scanned Student ($regNo)';
      final newStudent = RosterStudent(
        id: regNo,
        name: studentName,
        overallAttendance: 100,
        status: AttendanceStatus.present,
      );
      state = state.copyWith(
        facultyRoster: [...state.facultyRoster, newStudent],
      );
    }

    // Add record to student subjects if it's the logged-in student (updating their record)
    final loggedInStudentId = authState.studentUser?.id ?? 'ST-202301';
    if (regNo == loggedInStudentId) {
      final updatedSubjects = List<SubjectAttendance>.from(state.studentSubjects);
      final ethicsIndex = updatedSubjects.indexWhere((s) => s.code == 'CS499');
      if (ethicsIndex != -1) {
        final item = updatedSubjects[ethicsIndex];
        updatedSubjects[ethicsIndex] = item.copyWith(
          attended: item.attended + 1,
          total: item.total + 1,
          percent: (((item.attended + 1) / (item.total + 1)) * 100).round(),
          statusText: 'Excellent',
          isLow: false,
        );
      }
      state = state.copyWith(studentSubjects: updatedSubjects);
      _ref.read(dashboardProvider.notifier).updateAttendancePercent(86);
    }

    // Add a log record
    final newLog = AttendanceLogRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dateStr: _getTodayFormattedDateTime(),
      subjectName: 'R20/R24 Lab Check-In',
      instructor: 'Student ID: $regNo',
      isPresent: true,
    );

    state = state.copyWith(
      isScannerCameraActive: false,
      isScanning: false,
      isScanSuccessful: true,
      scanErrorMessage: null, // Clear error
      scannedRegNumber: regNo,
      scannedStudentName: studentName,
      logs: [newLog, ...state.logs],
    );
  }

  String _getTodayFormattedDateTime() {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year} · 04:00 PM';
  }
}

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  final authState = ref.watch(auth.authProvider);
  return AttendanceNotifier(ref, authState);
});

// Selector provider for filtered logs
final filteredLogsProvider = Provider<List<AttendanceLogRecord>>((ref) {
  final attendanceState = ref.watch(attendanceProvider);
  if (attendanceState.selectedLogFilter == 'All Subjects') {
    return attendanceState.logs;
  }
  return attendanceState.logs
      .where((log) => log.subjectName.toLowerCase() == attendanceState.selectedLogFilter.toLowerCase())
      .toList();
});

const _initialSubjects = [
  SubjectAttendance(
    code: 'ENG-402',
    title: 'Systems Engineering',
    attended: 24,
    total: 28,
    percent: 85,
    statusText: 'On Track',
  ),
  SubjectAttendance(
    code: 'PHY-301',
    title: 'Quantum Physics II',
    attended: 18,
    total: 25,
    percent: 72,
    statusText: 'Low Attendance',
    isLow: true,
  ),
  SubjectAttendance(
    code: 'MTH-205',
    title: 'Linear Algebra',
    attended: 30,
    total: 32,
    percent: 94,
    statusText: 'Excellent',
  ),
  SubjectAttendance(
    code: 'CS499',
    title: 'AI Ethics Seminar',
    attended: 0,
    total: 0,
    percent: 0,
    statusText: 'Unmarked',
  ),
];

const _initialLogs = [
  AttendanceLogRecord(
    id: 'l1',
    dateStr: 'Oct 24, 2023 · 09:00 AM',
    subjectName: 'Systems Engineering',
    instructor: 'Dr. Sarah Jenkins',
    isPresent: true,
  ),
  AttendanceLogRecord(
    id: 'l2',
    dateStr: 'Oct 23, 2023 · 11:30 AM',
    subjectName: 'Linear Algebra',
    instructor: 'Prof. Michael Chen',
    isPresent: true,
  ),
  AttendanceLogRecord(
    id: 'l3',
    dateStr: 'Oct 22, 2023 · 02:00 PM',
    subjectName: 'Quantum Physics II',
    instructor: 'Dr. Elena Rodriguez',
    isPresent: false,
  ),
];

const _initialRoster = [
  RosterStudent(
    id: 'ST-202301',
    name: 'Alex Thompson',
    overallAttendance: 92,
    status: AttendanceStatus.unmarked,
  ),
  RosterStudent(
    id: 'ST-202305',
    name: 'Beatrice Miller',
    overallAttendance: 68,
    status: AttendanceStatus.unmarked,
  ),
  RosterStudent(
    id: 'ST-202312',
    name: 'Cassius Gray',
    overallAttendance: 84,
    status: AttendanceStatus.unmarked,
  ),
];

// Student Mock Database Map for specific subjects
const Map<String, List<SubjectAttendance>> _studentSubjectsMap = {
  'ST-202301': [
    SubjectAttendance(code: 'ENG-402', title: 'Systems Engineering', attended: 24, total: 28, percent: 85, statusText: 'On Track'),
    SubjectAttendance(code: 'PHY-301', title: 'Quantum Physics II', attended: 18, total: 25, percent: 72, statusText: 'Low Attendance', isLow: true),
    SubjectAttendance(code: 'MTH-205', title: 'Linear Algebra', attended: 30, total: 32, percent: 94, statusText: 'Excellent'),
    SubjectAttendance(code: 'CS499', title: 'AI Ethics Seminar', attended: 0, total: 0, percent: 0, statusText: 'Unmarked'),
  ],
  'ST-202302': [
    SubjectAttendance(code: 'ENG-402', title: 'Systems Engineering', attended: 26, total: 28, percent: 93, statusText: 'Excellent'),
    SubjectAttendance(code: 'PHY-301', title: 'Quantum Physics II', attended: 22, total: 25, percent: 88, statusText: 'On Track'),
    SubjectAttendance(code: 'MTH-205', title: 'Linear Algebra', attended: 28, total: 32, percent: 88, statusText: 'On Track'),
    SubjectAttendance(code: 'CS499', title: 'AI Ethics Seminar', attended: 0, total: 0, percent: 0, statusText: 'Unmarked'),
  ],
  'ST-202303': [
    SubjectAttendance(code: 'ENG-402', title: 'Systems Engineering', attended: 15, total: 28, percent: 53, statusText: 'Low Attendance', isLow: true),
    SubjectAttendance(code: 'PHY-301', title: 'Quantum Physics II', attended: 19, total: 25, percent: 76, statusText: 'On Track'),
    SubjectAttendance(code: 'MTH-205', title: 'Linear Algebra', attended: 20, total: 32, percent: 62, statusText: 'Low Attendance', isLow: true),
    SubjectAttendance(code: 'CS499', title: 'AI Ethics Seminar', attended: 0, total: 0, percent: 0, statusText: 'Unmarked'),
  ],
  'ST-202304': [
    SubjectAttendance(code: 'ENG-402', title: 'Systems Engineering', attended: 28, total: 28, percent: 100, statusText: 'Excellent'),
    SubjectAttendance(code: 'PHY-301', title: 'Quantum Physics II', attended: 24, total: 25, percent: 96, statusText: 'Excellent'),
    SubjectAttendance(code: 'MTH-205', title: 'Linear Algebra', attended: 32, total: 32, percent: 100, statusText: 'Excellent'),
    SubjectAttendance(code: 'CS499', title: 'AI Ethics Seminar', attended: 0, total: 0, percent: 0, statusText: 'Unmarked'),
  ],
  'ST-202305': [
    SubjectAttendance(code: 'ENG-402', title: 'Systems Engineering', attended: 22, total: 28, percent: 78, statusText: 'On Track'),
    SubjectAttendance(code: 'PHY-301', title: 'Quantum Physics II', attended: 17, total: 25, percent: 68, statusText: 'Low Attendance', isLow: true),
    SubjectAttendance(code: 'MTH-205', title: 'Linear Algebra', attended: 25, total: 32, percent: 78, statusText: 'On Track'),
    SubjectAttendance(code: 'CS499', title: 'AI Ethics Seminar', attended: 0, total: 0, percent: 0, statusText: 'Unmarked'),
  ],
};

// Student Mock Database Map for specific logs
const Map<String, List<AttendanceLogRecord>> _studentLogsMap = {
  'ST-202301': [
    AttendanceLogRecord(id: 'l1', dateStr: 'Oct 24, 2023 · 09:00 AM', subjectName: 'Systems Engineering', instructor: 'Dr. Sarah Jenkins', isPresent: true),
    AttendanceLogRecord(id: 'l2', dateStr: 'Oct 23, 2023 · 11:30 AM', subjectName: 'Linear Algebra', instructor: 'Prof. Michael Chen', isPresent: true),
    AttendanceLogRecord(id: 'l3', dateStr: 'Oct 22, 2023 · 02:00 PM', subjectName: 'Quantum Physics II', instructor: 'Dr. Elena Rodriguez', isPresent: false),
  ],
  'ST-202302': [
    AttendanceLogRecord(id: 'l1', dateStr: 'Oct 24, 2023 · 09:00 AM', subjectName: 'Systems Engineering', instructor: 'Dr. Sarah Jenkins', isPresent: true),
    AttendanceLogRecord(id: 'l2', dateStr: 'Oct 23, 2023 · 11:30 AM', subjectName: 'Linear Algebra', instructor: 'Prof. Michael Chen', isPresent: true),
    AttendanceLogRecord(id: 'l3', dateStr: 'Oct 22, 2023 · 02:00 PM', subjectName: 'Quantum Physics II', instructor: 'Dr. Elena Rodriguez', isPresent: true),
  ],
  'ST-202303': [
    AttendanceLogRecord(id: 'l1', dateStr: 'Oct 24, 2023 · 09:00 AM', subjectName: 'Systems Engineering', instructor: 'Dr. Sarah Jenkins', isPresent: false),
    AttendanceLogRecord(id: 'l2', dateStr: 'Oct 23, 2023 · 11:30 AM', subjectName: 'Linear Algebra', instructor: 'Prof. Michael Chen', isPresent: false),
    AttendanceLogRecord(id: 'l3', dateStr: 'Oct 22, 2023 · 02:00 PM', subjectName: 'Quantum Physics II', instructor: 'Dr. Elena Rodriguez', isPresent: true),
  ],
  'ST-202304': [
    AttendanceLogRecord(id: 'l1', dateStr: 'Oct 24, 2023 · 09:00 AM', subjectName: 'Systems Engineering', instructor: 'Dr. Sarah Jenkins', isPresent: true),
    AttendanceLogRecord(id: 'l2', dateStr: 'Oct 23, 2023 · 11:30 AM', subjectName: 'Linear Algebra', instructor: 'Prof. Michael Chen', isPresent: true),
    AttendanceLogRecord(id: 'l3', dateStr: 'Oct 22, 2023 · 02:00 PM', subjectName: 'Quantum Physics II', instructor: 'Dr. Elena Rodriguez', isPresent: true),
  ],
  'ST-202305': [
    AttendanceLogRecord(id: 'l1', dateStr: 'Oct 24, 2023 · 09:00 AM', subjectName: 'Systems Engineering', instructor: 'Dr. Sarah Jenkins', isPresent: true),
    AttendanceLogRecord(id: 'l2', dateStr: 'Oct 23, 2023 · 11:30 AM', subjectName: 'Linear Algebra', instructor: 'Prof. Michael Chen', isPresent: true),
    AttendanceLogRecord(id: 'l3', dateStr: 'Oct 22, 2023 · 02:00 PM', subjectName: 'Quantum Physics II', instructor: 'Dr. Elena Rodriguez', isPresent: false),
  ],
};
