import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/schedule_item.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart' as auth;

class ScheduleState {
  final int selectedDayIndex; // 0: Mon, 1: Tue, 2: Wed, 3: Thu, 4: Fri
  final Set<String> activeReminders; // Set of ScheduleItem IDs with reminders active
  final Map<int, List<ScheduleItem>> weeklySchedule;

  const ScheduleState({
    required this.selectedDayIndex,
    required this.activeReminders,
    required this.weeklySchedule,
  });

  ScheduleState copyWith({
    int? selectedDayIndex,
    Set<String>? activeReminders,
    Map<int, List<ScheduleItem>>? weeklySchedule,
  }) {
    return ScheduleState(
      selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
      activeReminders: activeReminders ?? this.activeReminders,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
    );
  }
}

class ScheduleNotifier extends StateNotifier<ScheduleState> {
  ScheduleNotifier(Ref ref, auth.AuthState authState)
      : super(
          ScheduleState(
            selectedDayIndex: DateTime.now().weekday - 1, // Dynamically default to current system day (0: Mon, 6: Sun)
            activeReminders: const {},
            weeklySchedule: _getScheduleForUser(authState.studentUser),
          ),
        );

  void selectDay(int index) {
    state = state.copyWith(selectedDayIndex: index);
  }

  void toggleReminder(String itemId) {
    final updated = Set<String>.from(state.activeReminders);
    if (updated.contains(itemId)) {
      updated.remove(itemId);
    } else {
      updated.add(itemId);
    }
    state = state.copyWith(activeReminders: updated);
  }

  static Map<int, List<ScheduleItem>> _getScheduleForUser(auth.StudentUser? student) {
    if (student == null) return _itWeeklySchedule;

    final dept = student.department.toLowerCase();
    if (dept.contains('cse') || dept.contains('computer science')) {
      return _cseWeeklySchedule;
    } else if (dept.contains('electronics') || dept.contains('ece')) {
      return _eceWeeklySchedule;
    } else if (dept.contains('civil')) {
      return _civilWeeklySchedule;
    } else if (dept.contains('mechanical') || dept.contains('mech')) {
      return _mechWeeklySchedule;
    }
    return _itWeeklySchedule;
  }
}

final scheduleProvider = StateNotifierProvider<ScheduleNotifier, ScheduleState>((ref) {
  final authState = ref.watch(auth.authProvider);
  return ScheduleNotifier(ref, authState);
});

// Selector for currently displayed schedule items
final currentDayScheduleProvider = Provider<List<ScheduleItem>>((ref) {
  final scheduleState = ref.watch(scheduleProvider);
  // Safe bounds check for Sunday / index out of range
  if (scheduleState.selectedDayIndex < 0 || scheduleState.selectedDayIndex > 6) {
    return [];
  }
  return scheduleState.weeklySchedule[scheduleState.selectedDayIndex] ?? [];
});

// ==================== IT DEPARTMENT ROUTINE (ORIGINAL) ====================
const _itMonday = [
  ScheduleItem(id: 'it_m1', title: 'ATACD', code: '24IT501', time: '09:00:00 - 09:50:00', professor: 'Dept. of IT', room: 'Room: RPLH3', sessionType: 'Lecture Session'),
  ScheduleItem(id: 'it_m2', title: 'TPWAI', code: '24IT506/MC03', time: '09:50:00 - 10:40:00', professor: 'Dept. of IT', room: 'Room: RPLH3', sessionType: 'Lecture Session'),
  ScheduleItem(id: 'it_m3', title: 'PEAAT', code: '24IT505/JOE1A', time: '10:40:00 - 11:30:00', professor: 'Dept. of IT', room: 'Room: RPLH3', sessionType: 'Lecture Session'),
  ScheduleItem(id: 'it_m_break', title: 'Lunch Break', code: '', time: '11:30:00 - 01:10:00', professor: '', room: 'Campus Cafeteria', sessionType: 'restaurant', isBreak: true),
  ScheduleItem(id: 'it_m4', title: 'ML', code: '24IT502', time: '01:10:00 - 02:00:00', professor: 'Dept. of IT', room: 'Room: RPLH3', sessionType: 'Lecture Session'),
  ScheduleItem(id: 'it_m5', title: 'WN', code: '24IT504/PE1B', time: '02:00:00 - 02:50:00', professor: 'Dept. of IT', room: 'Room: RPLH2', sessionType: 'Lecture Session'),
];

const _itTuesday = [
  ScheduleItem(id: 'it_t1', title: 'MLL', code: '24ITL502', time: '09:00:00 - 11:30:00', professor: 'Dept. of IT', room: 'Room: RPL02', sessionType: 'Lab Session'),
  ScheduleItem(id: 'it_t_break', title: 'Lunch Break', code: '', time: '11:30:00 - 01:10:00', professor: '', room: 'Campus Cafeteria', sessionType: 'restaurant', isBreak: true),
  ScheduleItem(id: 'it_t2', title: 'SE', code: '24IT503', time: '01:10:00 - 02:00:00', professor: 'Dept. of IT', room: 'Room: RPLH3', sessionType: 'Lecture Session'),
  ScheduleItem(id: 'it_t3', title: 'DIP', code: '24IT504/PE1A', time: '02:00:00 - 02:50:00', professor: 'Dept. of IT', room: 'Room: RPLH3', sessionType: 'Lecture Session'),
];

final Map<int, List<ScheduleItem>> _itWeeklySchedule = {
  0: _itMonday,
  1: _itTuesday,
  2: _itMonday, // Repeat Monday for Wed
  3: _itTuesday, // Repeat Tuesday for Thu
  4: _itMonday, // Repeat Monday for Fri
  5: [],
  6: [],
};

// ==================== CSE DEPARTMENT ROUTINE ====================
const _cseMonday = [
  ScheduleItem(id: 'cse_m1', title: 'Systems Engineering', code: 'ENG-402', time: '09:00:00 - 09:50:00', professor: 'Dr. Sarah Jenkins', room: 'Room: 302', sessionType: 'Lecture Session'),
  ScheduleItem(id: 'cse_m2', title: 'Quantum Physics II', code: 'PHY-301', time: '09:50:00 - 10:40:00', professor: 'Dr. Elena Rodriguez', room: 'Room: 302', sessionType: 'Lecture Session'),
  ScheduleItem(id: 'cse_m3', title: 'Linear Algebra', code: 'MTH-205', time: '10:40:00 - 11:30:00', professor: 'Prof. Michael Chen', room: 'Room: 302', sessionType: 'Lecture Session'),
  ScheduleItem(id: 'cse_m_break', title: 'Lunch Break', code: '', time: '11:30:00 - 01:10:00', professor: '', room: 'Campus Cafeteria', sessionType: 'restaurant', isBreak: true),
  ScheduleItem(id: 'cse_m4', title: 'AI Ethics Seminar', code: 'CS499', time: '01:10:00 - 02:00:00', professor: 'Dr. Michael Chen', room: 'Room: 302', sessionType: 'Seminar Session', isSpecial: true),
];

const _cseTuesday = [
  ScheduleItem(id: 'cse_t1', title: 'Machine Learning Lab', code: 'CSL301', time: '09:00:00 - 11:30:00', professor: 'Dr. Michael Chen', room: 'CSE Lab 4', sessionType: 'Lab Session'),
  ScheduleItem(id: 'cse_t_break', title: 'Lunch Break', code: '', time: '11:30:00 - 01:10:00', professor: '', room: 'Campus Cafeteria', sessionType: 'restaurant', isBreak: true),
  ScheduleItem(id: 'cse_t2', title: 'Systems Engineering', code: 'ENG-402', time: '01:10:00 - 02:00:00', professor: 'Dr. Sarah Jenkins', room: 'Room: 302', sessionType: 'Lecture Session'),
  ScheduleItem(id: 'cse_t3', title: 'Linear Algebra', code: 'MTH-205', time: '02:00:00 - 02:50:00', professor: 'Prof. Michael Chen', room: 'Room: 302', sessionType: 'Lecture Session'),
];

final Map<int, List<ScheduleItem>> _cseWeeklySchedule = {
  0: _cseMonday,
  1: _cseTuesday,
  2: _cseMonday,
  3: _cseTuesday,
  4: _cseMonday,
  5: [],
  6: [],
};

// ==================== ECE DEPARTMENT ROUTINE ====================
const _eceMonday = [
  ScheduleItem(id: 'ece_m1', title: 'Microprocessors', code: 'EC301', time: '09:00:00 - 09:50:00', professor: 'Prof. Rajesh Kumar', room: 'Room: 412', sessionType: 'Lecture Session'),
  ScheduleItem(id: 'ece_m2', title: 'Signals & Systems', code: 'EC302', time: '09:50:00 - 10:40:00', professor: 'Dr. Amit Sharma', room: 'Room: 412', sessionType: 'Lecture Session'),
  ScheduleItem(id: 'ece_m3', title: 'Digital Image Processing', code: 'EC303', time: '10:40:00 - 11:30:00', professor: 'Prof. Rajesh Kumar', room: 'Room: 412', sessionType: 'Lecture Session'),
  ScheduleItem(id: 'ece_m_break', title: 'Lunch Break', code: '', time: '11:30:00 - 01:10:00', professor: '', room: 'Campus Cafeteria', sessionType: 'restaurant', isBreak: true),
  ScheduleItem(id: 'ece_m4', title: 'Electromagnetic Waves', code: 'EC304', time: '01:10:00 - 02:00:00', professor: 'Dr. S. K. Bose', room: 'Room: 412', sessionType: 'Lecture Session'),
];

const _eceTuesday = [
  ScheduleItem(id: 'ece_t1', title: 'Analog Circuits Lab', code: 'ECL301', time: '09:00:00 - 11:30:00', professor: 'Prof. Rajesh Kumar', room: 'ECE Lab 2', sessionType: 'Lab Session'),
  ScheduleItem(id: 'ece_t_break', title: 'Lunch Break', code: '', time: '11:30:00 - 01:10:00', professor: '', room: 'Campus Cafeteria', sessionType: 'restaurant', isBreak: true),
  ScheduleItem(id: 'ece_t2', title: 'Microprocessors', code: 'EC301', time: '01:10:00 - 02:00:00', professor: 'Prof. Rajesh Kumar', room: 'Room: 412', sessionType: 'Lecture Session'),
];

final Map<int, List<ScheduleItem>> _eceWeeklySchedule = {
  0: _eceMonday,
  1: _eceTuesday,
  2: _eceMonday,
  3: _eceTuesday,
  4: _eceMonday,
  5: [],
  6: [],
};

// ==================== CIVIL DEPARTMENT ROUTINE ====================
const _civilMonday = [
  ScheduleItem(id: 'civ_m1', title: 'Structural Analysis', code: 'CE301', time: '09:00:00 - 09:50:00', professor: 'Dr. P. Venugopal', room: 'Room: 205', sessionType: 'Lecture Session'),
  ScheduleItem(id: 'civ_m2', title: 'Geotechnical Eng.', code: 'CE302', time: '09:50:00 - 10:40:00', professor: 'Prof. M. R. Prasad', room: 'Room: 205', sessionType: 'Lecture Session'),
  ScheduleItem(id: 'civ_m3', title: 'Transportation Eng.', code: 'CE303', time: '10:40:00 - 11:30:00', professor: 'Dr. P. Venugopal', room: 'Room: 205', sessionType: 'Lecture Session'),
  ScheduleItem(id: 'civ_m_break', title: 'Lunch Break', code: '', time: '11:30:00 - 01:10:00', professor: '', room: 'Campus Cafeteria', sessionType: 'restaurant', isBreak: true),
  ScheduleItem(id: 'civ_m4', title: 'Fluid Mechanics', code: 'CE304', time: '01:10:00 - 02:00:00', professor: 'Dr. T. R. Rao', room: 'Room: 205', sessionType: 'Lecture Session'),
];

const _civilTuesday = [
  ScheduleItem(id: 'civ_t1', title: 'Concrete Testing Lab', code: 'CEL301', time: '09:00:00 - 11:30:00', professor: 'Prof. M. R. Prasad', room: 'Civil Heavy Lab', sessionType: 'Lab Session'),
  ScheduleItem(id: 'civ_t_break', title: 'Lunch Break', code: '', time: '11:30:00 - 01:10:00', professor: '', room: 'Campus Cafeteria', sessionType: 'restaurant', isBreak: true),
  ScheduleItem(id: 'civ_t2', title: 'Structural Analysis', code: 'CE301', time: '01:10:00 - 02:00:00', professor: 'Dr. P. Venugopal', room: 'Room: 205', sessionType: 'Lecture Session'),
];

final Map<int, List<ScheduleItem>> _civilWeeklySchedule = {
  0: _civilMonday,
  1: _civilTuesday,
  2: _civilMonday,
  3: _civilTuesday,
  4: _civilMonday,
  5: [],
  6: [],
};

// ==================== MECHANICAL DEPARTMENT ROUTINE ====================
const _mechMonday = [
  ScheduleItem(id: 'mec_m1', title: 'Thermodynamics', code: 'ME301', time: '09:00:00 - 09:50:00', professor: 'Dr. A. K. Verma', room: 'Room: 102', sessionType: 'Lecture Session'),
  ScheduleItem(id: 'mec_m2', title: 'Strength of Materials', code: 'ME302', time: '09:50:00 - 10:40:00', professor: 'Prof. H. S. Murthy', room: 'Room: 102', sessionType: 'Lecture Session'),
  ScheduleItem(id: 'mec_m3', title: 'Fluid Machinery', code: 'ME303', time: '10:40:00 - 11:30:00', professor: 'Dr. A. K. Verma', room: 'Room: 102', sessionType: 'Lecture Session'),
  ScheduleItem(id: 'mec_m_break', title: 'Lunch Break', code: '', time: '11:30:00 - 01:10:00', professor: '', room: 'Campus Cafeteria', sessionType: 'restaurant', isBreak: true),
  ScheduleItem(id: 'mec_m4', title: 'Kinematics of Machines', code: 'ME304', time: '01:10:00 - 02:00:00', professor: 'Prof. K. R. Rao', room: 'Room: 102', sessionType: 'Lecture Session'),
];

const _mechTuesday = [
  ScheduleItem(id: 'mec_t1', title: 'CAD/CAM Lab Session', code: 'MEL301', time: '09:00:00 - 11:30:00', professor: 'Prof. H. S. Murthy', room: 'Mech CAD Lab', sessionType: 'Lab Session'),
  ScheduleItem(id: 'mec_t_break', title: 'Lunch Break', code: '', time: '11:30:00 - 01:10:00', professor: '', room: 'Campus Cafeteria', sessionType: 'restaurant', isBreak: true),
  ScheduleItem(id: 'mec_t2', title: 'Thermodynamics', code: 'ME301', time: '01:10:00 - 02:00:00', professor: 'Dr. A. K. Verma', room: 'Room: 102', sessionType: 'Lecture Session'),
];

final Map<int, List<ScheduleItem>> _mechWeeklySchedule = {
  0: _mechMonday,
  1: _mechTuesday,
  2: _mechMonday,
  3: _mechTuesday,
  4: _mechMonday,
  5: [],
  6: [],
};
