import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novau/features/notices/data/models/notice.dart';
import 'package:novau/features/notices/presentation/providers/notices_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart' as auth;
import '../../../../features/attendance/presentation/providers/attendance_provider.dart';

class DashboardStats {
  final int attendancePercent;
  final double gpa;
  final String cgpa;
  final int libraryDues;
  final bool isDeansList;

  const DashboardStats({
    required this.attendancePercent,
    required this.gpa,
    required this.cgpa,
    required this.libraryDues,
    required this.isDeansList,
  });
}

class NextClassInfo {
  final String title;
  final String code;
  final String room;
  final String time;
  final String timeRemaining;
  final String professorName;
  final String professorAvatarUrl;
  final int extraStudentsCount;

  const NextClassInfo({
    required this.title,
    required this.code,
    required this.room,
    required this.time,
    required this.timeRemaining,
    required this.professorName,
    required this.professorAvatarUrl,
    required this.extraStudentsCount,
  });
}

class DashboardState {
  final String studentName;
  final String departmentYear;
  final String studentAvatarUrl;
  final DashboardStats stats;
  final NextClassInfo nextClass;

  const DashboardState({
    required this.studentName,
    required this.departmentYear,
    required this.studentAvatarUrl,
    required this.stats,
    required this.nextClass,
  });

  DashboardState copyWith({
    String? studentName,
    String? departmentYear,
    String? studentAvatarUrl,
    DashboardStats? stats,
    NextClassInfo? nextClass,
  }) {
    return DashboardState(
      studentName: studentName ?? this.studentName,
      departmentYear: departmentYear ?? this.departmentYear,
      studentAvatarUrl: studentAvatarUrl ?? this.studentAvatarUrl,
      stats: stats ?? this.stats,
      nextClass: nextClass ?? this.nextClass,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier(Ref ref, auth.AuthState authState, AttendanceState attendanceState)
      : super(
          _createState(authState, attendanceState),
        );

  static DashboardState _createState(auth.AuthState authState, AttendanceState attendanceState) {
    final student = authState.studentUser;
    
    // Calculate attendance percentage dynamically
    final attendancePercent = _calculateOverallAttendance(attendanceState.studentSubjects);
    
    // Parse GPA
    final gpa = _getGpaForStudent(student?.cgpa);
    
    // Dean's List status
    final isDeansList = gpa >= 3.8;

    // Next class details based on student profile
    final nextClass = _getNextClassForStudent(student?.id);

    return DashboardState(
      studentName: student?.name.split(' ').first ?? 'Student',
      departmentYear: student?.department ?? 'BEC Bapatla',
      studentAvatarUrl: student?.avatarUrl ?? 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150&auto=format&fit=crop',
      stats: DashboardStats(
        attendancePercent: attendancePercent,
        gpa: gpa,
        cgpa: student?.cgpa ?? '8.8 / 10',
        libraryDues: 0,
        isDeansList: isDeansList,
      ),
      nextClass: nextClass,
    );
  }

  void updateAttendancePercent(int percent) {
    state = state.copyWith(
      stats: DashboardStats(
        attendancePercent: percent,
        gpa: state.stats.gpa,
        cgpa: state.stats.cgpa,
        libraryDues: state.stats.libraryDues,
        isDeansList: state.stats.isDeansList,
      ),
    );
  }

  static int _calculateOverallAttendance(List<SubjectAttendance> subjects) {
    int totalAttended = 0;
    int totalClasses = 0;
    for (final subject in subjects) {
      totalAttended += subject.attended;
      totalClasses += subject.total;
    }
    if (totalClasses == 0) return 85;
    return ((totalAttended / totalClasses) * 100).round();
  }

  static double _getGpaForStudent(String? cgpaStr) {
    if (cgpaStr == null) return 3.8;
    try {
      final parts = cgpaStr.split('/');
      if (parts.isNotEmpty) {
        final value = double.tryParse(parts[0].trim());
        if (value != null) {
          if (value >= 9.2) return 4.0;
          if (value >= 9.0) return 3.9;
          if (value >= 8.8) return 3.8;
          if (value >= 8.4) return 3.6;
          if (value >= 8.0) return 3.4;
          return 3.0;
        }
      }
    } catch (_) {}
    return 3.5;
  }

  static NextClassInfo _getNextClassForStudent(String? studentId) {
    if (studentId == 'ST-202302') {
      return const NextClassInfo(
        title: 'Quantum Physics II',
        code: 'PHY-301',
        room: 'Room 104',
        time: '10:30 AM',
        timeRemaining: 'Starts in 15 mins',
        professorName: 'Dr. Elena Rodriguez',
        professorAvatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop',
        extraStudentsCount: 8,
      );
    }
    if (studentId == 'ST-202303') {
      return const NextClassInfo(
        title: 'Linear Algebra',
        code: 'MTH-205',
        room: 'Room 412',
        time: '10:30 AM',
        timeRemaining: 'Starts in 15 mins',
        professorName: 'Prof. Michael Chen',
        professorAvatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&auto=format&fit=crop',
        extraStudentsCount: 15,
      );
    }
    // Default/Alex Thompson
    return const NextClassInfo(
      title: 'Systems Engineering',
      code: 'ENG-402',
      room: 'Room 302',
      time: '10:30 AM',
      timeRemaining: 'Starts in 15 mins',
      professorName: 'Dr. Sarah Jenkins',
      professorAvatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop',
      extraStudentsCount: 12,
    );
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final authState = ref.watch(auth.authProvider);
  final attendanceState = ref.watch(attendanceProvider);
  return DashboardNotifier(ref, authState, attendanceState);
});

// Sync notices list with dashboard
final recentNoticesProvider = Provider<List<Notice>>((ref) {
  final noticesState = ref.watch(noticesProvider);
  // Get first 3 notices for dashboard view
  return noticesState.notices.take(3).toList();
});
