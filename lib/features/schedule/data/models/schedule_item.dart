class ScheduleItem {
  final String id;
  final String title;
  final String code;
  final String time;
  final String professor;
  final String room;
  final String sessionType; // e.g., Morning Session, Afternoon Lab, Seminar
  final bool isBreak;
  final bool isSpecial; // Guest lectures, seminars, etc.

  const ScheduleItem({
    required this.id,
    required this.title,
    required this.code,
    required this.time,
    required this.professor,
    required this.room,
    required this.sessionType,
    this.isBreak = false,
    this.isSpecial = false,
  });
}
