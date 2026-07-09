import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notice.dart';

class NoticesState {
  final List<Notice> notices;
  final String selectedCategory; // All, Academic, Events, Placement, Administrative
  final Notice? selectedNoticeDetail;
  final bool isPostNoticeFormOpen;

  const NoticesState({
    required this.notices,
    required this.selectedCategory,
    this.selectedNoticeDetail,
    required this.isPostNoticeFormOpen,
  });

  NoticesState copyWith({
    List<Notice>? notices,
    String? selectedCategory,
    Notice? selectedNoticeDetail,
    bool? isPostNoticeFormOpen,
    bool clearSelectedNotice = false,
  }) {
    return NoticesState(
      notices: notices ?? this.notices,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedNoticeDetail: clearSelectedNotice ? null : (selectedNoticeDetail ?? this.selectedNoticeDetail),
      isPostNoticeFormOpen: isPostNoticeFormOpen ?? this.isPostNoticeFormOpen,
    );
  }
}

class NoticesNotifier extends StateNotifier<NoticesState> {
  NoticesNotifier()
      : super(
          NoticesState(
            notices: _initialNotices,
            selectedCategory: 'All',
            isPostNoticeFormOpen: false,
          ),
        );

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void openNoticeDetail(Notice notice) {
    state = state.copyWith(selectedNoticeDetail: notice);
  }

  void closeNoticeDetail() {
    state = state.copyWith(clearSelectedNotice: true);
  }

  void togglePostNoticeForm(bool open) {
    state = state.copyWith(isPostNoticeFormOpen: open);
  }

  void postNotice({
    required String title,
    required String category,
    required String snippet,
    required String description,
  }) {
    final newNotice = Notice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      date: _getTodayFormattedDate(),
      snippet: snippet,
      description: description,
      imageUrl: 'https://images.unsplash.com/photo-1557804506-669a67965ba0?w=800&auto=format&fit=crop', // Stock placeholder
    );

    state = state.copyWith(
      notices: [newNotice, ...state.notices],
      isPostNoticeFormOpen: false,
    );
  }

  String _getTodayFormattedDate() {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}

final noticesProvider = StateNotifierProvider<NoticesNotifier, NoticesState>((ref) {
  return NoticesNotifier();
});

// Selector provider for filtered notices
final filteredNoticesProvider = Provider<List<Notice>>((ref) {
  final state = ref.watch(noticesProvider);
  if (state.selectedCategory == 'All') {
    return state.notices;
  }
  return state.notices.where((n) => n.category.toLowerCase() == state.selectedCategory.toLowerCase()).toList();
});

const List<Notice> _initialNotices = [
  Notice(
    id: '1',
    title: 'BEC-FEST 2026: National Technical Symposium',
    category: 'Events',
    date: 'Jul 07, 2026',
    snippet: 'Registrations are officially open for BEC-FEST 2026! Participate in coding hackathons, technical paper presentations, and robotics events.',
    description: 'Bapatla Engineering College is excited to announce the national-level student technical symposium, BEC-FEST 2026. This year’s edition hosts over 25+ events across Computer Science, Electronics, Electrical, Mechanical, Civil, and Chemical streams.\n\nEvents include Hackathons, Robowars, CAD Design Challenges, Paper Presentations, and Workshops on Generative AI. Cash prizes worth Rs. 2,00,000 are up for grabs!\n\nRegistration deadline: July 20, 2026\nMain Event: July 28-30, 2026\nRegister at the Student Activity Desk or online via the portal.',
    imageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&auto=format&fit=crop',
  ),
  Notice(
    id: '2',
    title: 'B.Tech R20 & R24 Semester Exam Registration',
    category: 'Academic',
    date: 'Jul 06, 2026',
    snippet: 'Examinations fee payment notifications and registration schedules are active for B.Tech semesters under R20/R24 regulations.',
    description: 'The Office of the Controller of Examinations at Bapatla Engineering College has released the exam fee notification circulars for the upcoming end-semester examinations.\n\nStudents belonging to R20 and R24 regulations must log in to their student portal accounts to verify their eligibility (minimum 75% attendance is mandatory) and make the online fee payment.\n\nAdmit Card download starts: July 15, 2026\nExams start: July 22, 2026',
    imageUrl: 'https://images.unsplash.com/photo-1506784983877-45594efa4cbe?w=800&auto=format&fit=crop',
  ),
  Notice(
    id: '3',
    title: 'Campus Drive: PEGA Systems & TCS Recruitment',
    category: 'Placement',
    date: 'Jul 05, 2026',
    snippet: 'Pre-placement talk and programming rounds for final year B.Tech CSE, CSE-AIML, CSE-DS, IT, and ECE students. Eligible CGPA: 7.0+.',
    description: 'The Training & Placement Cell of BEC Bapatla is hosting a joint recruitment drive with PEGA Systems and Tata Consultancy Services (TCS) for software engineer roles.\n\nRegistration is mandatory on the placement portal. All eligible final year students with no active backlogs must attend. Formal dress code is strictly required.\n\nSchedule:\nPEGA Systems PPT & Assessment: July 12, 09:30 AM, Main Auditorium\nTCS Technical Interviews: July 13, 09:00 AM, CSE Block Lab 4',
    imageUrl: 'https://images.unsplash.com/photo-1521737711867-e3b90473bd58?w=800&auto=format&fit=crop',
  ),
  Notice(
    id: '4',
    title: 'B.Tech Admissions 2026-27 Helpline Desks Active',
    category: 'Administrative',
    date: 'Jul 04, 2026',
    snippet: 'Counselling assistance desks for new B.Tech admissions are active in the Admin Block. Contact details inside.',
    description: 'BEC Bapatla Admissions Cell announces that guidance helplines are now operational for the 2026-27 academic intake counselling process. Specialized seats are available in CSE, ECE, EEE, Civil, Mechanical, CSE-AIML, CSE-DS, and CSE-Cyber Security.\n\nFor queries, candidates can visit the Helpdesk in the Administrative Block or contact our coordinators at +91 9100 681 777 or +91 9100 682 777.',
    imageUrl: 'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=800&auto=format&fit=crop',
  ),
  Notice(
    id: '5',
    title: 'Faculty Development Program on Cyber Security & ML',
    category: 'Events',
    date: 'Jul 03, 2026',
    snippet: 'National-level workshop for faculty and research scholars hosted by the CSE & IT departments.',
    description: 'The Departments of Computer Science & Engineering and Information Technology are organizing a 5-day Faculty Development Program (FDP) on "Emerging Trends in Cyber Security and Machine Learning Applications."\n\nResource persons from IITs, NITs, and Industry will deliver sessions.\n\nVenue: Seminar Hall, IT Block\nDates: July 18-22, 2026',
    imageUrl: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=800&auto=format&fit=crop',
  ),
];
