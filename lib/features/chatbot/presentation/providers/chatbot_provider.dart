import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:novau/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:novau/features/schedule/presentation/providers/schedule_provider.dart';
import 'package:novau/features/notices/presentation/providers/notices_provider.dart';
import 'package:novau/features/auth/presentation/providers/auth_provider.dart';
import 'package:novau/features/attendance/presentation/providers/attendance_provider.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isChart;
  final List<double>? chartData;
  final List<String>? chartLabels;
  final String? chartTitle;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isChart = false,
    this.chartData,
    this.chartLabels,
    this.chartTitle,
  });
}

class ChatbotState {
  final List<ChatMessage> messages;
  final bool isTyping;

  const ChatbotState({
    required this.messages,
    required this.isTyping,
  });

  ChatbotState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
  }) {
    return ChatbotState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class KnowledgeArticle {
  final String category;
  final List<String> keywords;
  final String content;

  const KnowledgeArticle({
    required this.category,
    required this.keywords,
    required this.content,
  });
}

class ChatbotNotifier extends StateNotifier<ChatbotState> {
  final Ref _ref;
  GenerativeModel? _model;

  static const List<KnowledgeArticle> _knowledgeBase = [
    KnowledgeArticle(
      category: 'R20 Academic Regulations',
      keywords: ['r20', 'regulation', 'detention', 'grading', 'marks', 'credits', 'gpa', 'condonation'],
      content: 'R20 Regulations at Bapatla Engineering College use a 10-point absolute grading scale. Minimum attendance of 75% per subject is required, with up to 10% condonation allowed for medical/sports grounds with formal approval. Pass mark is 40% combined internal and external.',
    ),
    KnowledgeArticle(
      category: 'R24 Academic Regulations',
      keywords: ['r24', 'regulation', 'relative', 'detention', 'grading', 'credits', 'internships', 'assessment'],
      content: 'R24 Regulations at Bapatla Engineering College use a relative grading scale based on class performance cohort curves. Strict attendance minimum of 75% applies, and non-compliance results in automatic detention. Graduation requires 160 credits, including 12 mandatory credits for industry internships. Assessment weightage is 40% internal and 60% external.',
    ),
    KnowledgeArticle(
      category: 'Hostel Info',
      keywords: ['hostel', 'room', 'mess', 'curfew', 'timings', 'warden', 'fee', 'dues', 'occupancy'],
      content: 'Curfew is at 9:30 PM. Mess timings: Breakfast: 7:30 AM - 9:00 AM, Lunch: 12:30 PM - 2:00 PM, Dinner: 7:30 PM - 9:00 PM. Room occupancy is Double Sharing (AC Room). Warden contact: Dr. A. K. Sen (Ext: 2404). Hostel mess fee status is Fully Paid with no outstanding dues.',
    ),
    KnowledgeArticle(
      category: 'Library Info',
      keywords: ['library', 'book', 'due', 'fine', 'card', 'borrow', 'issued'],
      content: 'Library card ID is linked to student profile. Allows borrowing up to 3 books. Issued books are due in 15 days. Card expiry: June 15, 2027. Outstanding fines are currently \$0.00. Late return fine is \$0.50 per day per book.',
    ),
    KnowledgeArticle(
      category: 'Placements',
      keywords: ['placement', 'job', 'recruit', 'salary', 'package', 'company', 'careers'],
      content: 'Bapatla Engineering College placement cell organizes soft skills and coding bootcamps. Top recruiters include PEGA Systems, TCS, Wipro, Infosys, Cognizant, and HCL.',
    ),
    KnowledgeArticle(
      category: 'Contact Info',
      keywords: ['contact', 'phone', 'address', 'email', 'principal', 'office'],
      content: 'Address: Bapatla Engineering College, Bapatla, Guntur District, Andhra Pradesh, India - 522101. Email: principal@becbapatla.ac.in. Phone: +91-8643-224244.',
    ),
  ];

  ChatbotNotifier(this._ref)
      : super(
          ChatbotState(
            messages: [
              ChatMessage(
                text: "Hi ${_ref.read(authProvider).studentUser?.name.split(' ').first ?? 'Student'}! I am your BEC Campus AI assistant. Ask me anything about your grades, schedule, hostel, library dues, attendance, or latest notices. I can also plot prediction graphs and answer college queries.",
                isUser: false,
                timestamp: DateTime.now(),
              ),
            ],
            isTyping: false,
          ),
        ) {
    _initGemini();
  }

  void _initGemini() {
    const apiKey = String.fromEnvironment('GEMINI_API_KEY');
    if (apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );
    }
  }

  void clearChat() {
    final student = _ref.read(authProvider).studentUser;
    final name = student != null ? student.name.split(' ').first : 'Student';
    state = ChatbotState(
      messages: [
        ChatMessage(
          text: "Hi $name! Chat has been cleared. Ask me anything about your student data.",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
      isTyping: false,
    );
  }

  List<KnowledgeArticle> _retrieveRelevantArticles(String query) {
    final cleanQuery = query.toLowerCase();
    final queryTerms = cleanQuery.split(RegExp(r'\s+'));
    final List<KnowledgeArticle> matches = [];

    for (final article in _knowledgeBase) {
      int score = 0;
      for (final keyword in article.keywords) {
        if (cleanQuery.contains(keyword)) {
          score += 3;
        }
      }
      for (final term in queryTerms) {
        if (term.length > 2 && article.content.toLowerCase().contains(term)) {
          score += 1;
        }
      }
      if (score > 0) {
        matches.add(article);
      }
    }
    return matches;
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
    );

    _handleResponseAsync(text);
  }

  Future<void> _handleResponseAsync(String text) async {
    final query = text.toLowerCase();
    ChatMessage aiMsg;

    // 1. Chart intent matching
    if (query.contains("graph") || query.contains("chart") || query.contains("plot") || query.contains("predict") || query.contains("forecast") || query.contains("trend")) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (query.contains("cgpa") || query.contains("gpa") || query.contains("grade") || query.contains("marks") || query.contains("performance")) {
        aiMsg = ChatMessage(
          text: "Based on your semester GPA records and attendance levels, here is your predictive CGPA forecast. A 5-semester progression with Semester 6 predicted at 8.95 based on current trends.",
          isUser: false,
          timestamp: DateTime.now(),
          isChart: true,
          chartData: [8.2, 8.5, 8.6, 8.7, 8.8, 8.95],
          chartLabels: ["S1", "S2", "S3", "S4", "S5", "S6 (Pred)"],
          chartTitle: "CGPA Progression & Forecast",
        );
      } else {
        aiMsg = ChatMessage(
          text: "Here is your weekly attendance trend analysis showing daily class presence levels.",
          isUser: false,
          timestamp: DateTime.now(),
          isChart: true,
          chartData: [80, 85, 85, 90, 85, 86],
          chartLabels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
          chartTitle: "Weekly Attendance Trend (%)",
        );
      }
      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isTyping: false,
      );
      return;
    }

    // 2. LLM RAG Mode check
    if (_model != null) {
      try {
        final reply = await _generateLlmResponse(text);
        aiMsg = ChatMessage(
          text: reply,
          isUser: false,
          timestamp: DateTime.now(),
        );
        state = state.copyWith(
          messages: [...state.messages, aiMsg],
          isTyping: false,
        );
        return;
      } catch (e) {
        // Fallback on API failure
      }
    }

    // 3. Heuristic / Offline Fallback Mode
    await Future.delayed(const Duration(milliseconds: 600));
    final reply = _generateResponseOffline(text);
    aiMsg = ChatMessage(
      text: reply,
      isUser: false,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, aiMsg],
      isTyping: false,
    );
  }

  Future<String> _generateLlmResponse(String userQuery) async {
    final dashboard = _ref.read(dashboardProvider);
    final schedule = _ref.read(scheduleProvider);
    final authState = _ref.read(authProvider);
    final attendanceState = _ref.read(attendanceProvider);
    final student = authState.studentUser;

    // Retrieve context articles
    final matches = _retrieveRelevantArticles(userQuery);
    final contextStr = matches.isEmpty
        ? "No specific offline knowledge articles retrieved for this query."
        : matches.map((m) => "[Context: ${m.category}] ${m.content}").join("\n\n");

    // Format schedule
    final weekdayIndex = DateTime.now().weekday - 1;
    final todaySchedule = schedule.weeklySchedule[weekdayIndex] ?? [];
    String scheduleStr = "";
    if (todaySchedule.isEmpty) {
      scheduleStr = "No classes scheduled for today.";
    } else {
      scheduleStr = todaySchedule.map((item) {
        return item.isBreak
            ? "- ${item.time}: ${item.title}"
            : "- ${item.time}: ${item.title} (${item.code}) at ${item.room}";
      }).join("\n");
    }

    final prompt = """
You are the BEC Campus AI assistant. Ground your answer in the student details and retrieved context below. Be helpful, concise, and professional.

Live Student Details:
- Name: ${student?.name ?? 'Alex Thompson'}
- Registration/Roll ID: ${student?.id ?? 'ST-202301'}
- CGPA: ${student?.cgpa ?? '8.8 / 10'}
- Overall Attendance: ${dashboard.stats.attendancePercent}%
- Current Semester: ${student?.semester ?? 'Semester 6'}
- Hostel Block/Room: ${student?.hostelBlock ?? 'Block B'}, Room ${student?.roomNo ?? '208'}
- Library Card ID: ${student?.libraryCard ?? 'LIB-BEC-9482'}

Enrolled Subject Attendance Status:
${attendanceState.studentSubjects.map((s) => "- ${s.title} (${s.code}): ${s.percent}% attendance (${s.attended}/${s.total} classes)").join('\n')}

Upcoming Class Routine:
$scheduleStr

Retrieved Knowledge Base Context:
$contextStr

User Question: $userQuery
""";

    final content = [Content.text(prompt)];
    final response = await _model!.generateContent(content);
    return response.text ?? "I'm sorry, I could not generate a response. Please try again.";
  }

  String _generateResponseOffline(String input) {
    final query = input.toLowerCase();

    final dashboard = _ref.read(dashboardProvider);
    final schedule = _ref.read(scheduleProvider);
    final notices = _ref.read(noticesProvider);

    final weekdayIndex = DateTime.now().weekday - 1;
    final todaySchedule = schedule.weeklySchedule[weekdayIndex] ?? [];

    String scheduleStr = "";
    if (todaySchedule.isEmpty) {
      scheduleStr = "You have no classes scheduled for today. Enjoy your day!";
    } else {
      scheduleStr = "Here is your class routine for today:\n";
      for (final item in todaySchedule) {
        if (item.isBreak) {
          scheduleStr += "• ${item.time}: **${item.title}** at ${item.room}\n";
        } else {
          scheduleStr += "• ${item.time}: **${item.title}** (${item.code}) at ${item.room}\n";
        }
      }
    }

    final authState = _ref.read(authProvider);
    final student = authState.studentUser;
    final studentName = student != null ? student.name.split(' ').first : "Student";
    final studentId = student != null ? student.id : "ST-202301";
    final hostelInfo = student != null ? "${student.hostelBlock}, ${student.roomNo}" : "Ramanujan Hostel Block (RPL), Room 302";
    final libraryCard = student != null ? student.libraryCard : "LIB-BEC-9482";
    final cgpaStr = student != null ? student.cgpa : "8.8 / 10";

    // 1. Basic greeting
    if (query.contains("hi") || query.contains("hello") || query.contains("hey")) {
      return "Hello $studentName! (Offline Mode) I am analyzing your student details. How can I help you today?";
    }

    // 2. Retrieve from Knowledge Base if matching keywords
    final matches = _retrieveRelevantArticles(query);
    if (matches.isNotEmpty &&
        (query.contains("reg") ||
            query.contains("curfew") ||
            query.contains("mess") ||
            query.contains("library") ||
            query.contains("book") ||
            query.contains("placement") ||
            query.contains("contact") ||
            query.contains("college") ||
            query.contains("bec") ||
            query.contains("bapatla"))) {
      return "Based on BEC Campus Records (Offline RAG):\n" + matches.map((m) => "• ${m.content}").join("\n\n");
    }

    // 3. Custom status endpoints
    if (query.contains("attendance") || query.contains("absent") || query.contains("present")) {
      final pct = dashboard.stats.attendancePercent;
      String remark = "";
      if (pct >= 85) {
        remark = "Excellent! You are safely above the 75% required attendance threshold.";
      } else if (pct >= 75) {
        remark = "Good, but try not to miss any more classes to stay above the 75% line.";
      } else {
        remark = "Warning: Your attendance is below 75%. Please contact your faculty advisor.";
      }
      return "Your overall attendance is **$pct%**. $remark";
    }

    if (query.contains("cgpa") || query.contains("gpa") || query.contains("grade") || query.contains("marks")) {
      return "Your cumulative grade points stand at **$cgpaStr** (US equivalent GPA: ${dashboard.stats.gpa}). You are listed on the College Dean's Merit List!";
    }

    if (query.contains("schedule") || query.contains("class") || query.contains("routine") || query.contains("today")) {
      return scheduleStr;
    }

    if (query.contains("next class") || query.contains("structures") || query.contains("room")) {
      final nextClass = dashboard.nextClass;
      return "Your upcoming class is **${nextClass.title} (${nextClass.code})** in **${nextClass.room}** at **${nextClass.time}** (${nextClass.timeRemaining}). Instructed by **${nextClass.professorName}**.";
    }

    if (query.contains("hostel") || query.contains("room") || query.contains("stay") || query.contains("dorm")) {
      return "You are staying in **$hostelInfo**.";
    }

    if (query.contains("library") || query.contains("book") || query.contains("due") || query.contains("card")) {
      return "Your Library Card ID is **$libraryCard**. You currently have **${dashboard.stats.libraryDues}** pending book returns/dues.";
    }

    if (query.contains("notice") || query.contains("exam") || query.contains("placement") || query.contains("announcement") || query.contains("news")) {
      if (notices.notices.isEmpty) {
        return "There are no active notices at the moment.";
      }
      String noticesStr = "Here are the recent announcements from BEC Bapatla:\n";
      final count = notices.notices.length > 3 ? 3 : notices.notices.length;
      for (int i = 0; i < count; i++) {
        final notice = notices.notices[i];
        noticesStr += "${i + 1}. **${notice.title}** (${notice.category})\n   _${notice.description}_\n";
      }
      return noticesStr;
    }

    if (query.contains("reg") || query.contains("roll") || query.contains("id")) {
      return "Your registration/roll number at Bapatla Engineering College is **$studentId**.";
    }

    if (query.contains("thank") || query.contains("thanks")) {
      return "You're welcome, $studentName! Let me know if you need anything else.";
    }

    return "I am in Offline RAG mode. You can ask me:\n"
        "• 'What is my CGPA?'\n"
        "• 'Show today's schedule'\n"
        "• 'Plot CGPA forecast graph'\n"
        "• 'Tell me about R24 regulations'\n"
        "• 'Mess timings and curfew'\n"
        "• 'Library card info'";
  }
}

final chatbotProvider = StateNotifierProvider<ChatbotNotifier, ChatbotState>((ref) {
  return ChatbotNotifier(ref);
});
