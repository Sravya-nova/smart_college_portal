import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novau/core/theme/theme_provider.dart';
import 'package:novau/core/theme/app_typography.dart';
import 'package:novau/features/attendance/presentation/pages/attendance_page.dart';
import 'package:novau/features/attendance/presentation/providers/attendance_provider.dart';
import 'package:novau/features/chatbot/presentation/pages/chatbot_page.dart';
import 'package:novau/features/notices/data/models/notice.dart';
import 'package:novau/features/notices/presentation/providers/notices_provider.dart';
import 'package:novau/features/shell/presentation/providers/navigation_provider.dart';
import 'package:novau/features/auth/presentation/providers/auth_provider.dart';
import 'package:novau/features/dashboard/presentation/providers/dashboard_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final recentNotices = ref.watch(recentNoticesProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.background,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Psych AI Assistant Chatbot FAB
            FloatingActionButton(
              heroTag: 'chatbot_fab',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatbotPage()),
                );
              },
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.onSecondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
              child: const Icon(Icons.psychology, size: 28),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar
            SliverToBoxAdapter(
              child: _buildHeader(context, ref, state),
            ),
            // Main content
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Stats Row
                  _buildStatsRow(context, state),
                  const SizedBox(height: 24),
                  // Next Class Hero Card
                  _buildNextClassHero(context, state),
                  const SizedBox(height: 24),
                  // Quick Actions Card with Gradient Background
                  _buildQuickActions(context, ref),
                  const SizedBox(height: 24),
                  // Recent Notices Section
                  _buildRecentNoticesSection(context, ref, recentNotices),
                  const SizedBox(height: 96), // Extra scroll padding at bottom
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, DashboardState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final student = authState.studentUser;

    final studentName = student != null ? student.name.split(' ').first : state.studentName;
    final studentAvatar = student != null ? student.avatarUrl : state.studentAvatarUrl;
    final department = student != null ? student.department : state.departmentYear;

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.outlineVariant, width: 2),
                  image: DecorationImage(
                    image: NetworkImage(studentAvatar),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $studentName',
                    style: AppTypography.titleLg.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    department,
                    style: AppTypography.labelSm.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              // Theme Toggle Option
              IconButton(
                onPressed: () {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: colorScheme.primary,
                  size: 24,
                ),
                style: IconButton.styleFrom(
                  hoverColor: colorScheme.surfaceVariant,
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: 4),
              // Notifications Option
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications are up to date.')),
                  );
                },
                icon: Icon(Icons.notifications_outlined, color: colorScheme.primary, size: 24),
                style: IconButton.styleFrom(
                  hoverColor: colorScheme.surfaceVariant,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, DashboardState state) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Attendance Card
        Expanded(
          child: _buildStatsCard(
            context: context,
            title: 'Attendance',
            value: '${state.stats.attendancePercent}%',
            bottomWidget: Column(
              children: [
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: state.stats.attendancePercent / 100,
                    backgroundColor: colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // CGPA Card
        Expanded(
          child: _buildStatsCard(
            context: context,
            title: 'CGPA',
            value: state.stats.cgpa,
            bottomWidget: Column(
              children: [
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "DEAN'S LIST",
                    style: AppTypography.labelSm.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Lib Dues Card
        Expanded(
          child: _buildStatsCard(
            context: context,
            title: 'Lib Dues',
            value: '\$${state.stats.libraryDues}',
            bottomWidget: Column(
              children: [
                const SizedBox(height: 8),
                Icon(Icons.check_circle, color: colorScheme.onSecondaryContainer, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard({
    required BuildContext context,
    required String title,
    required String value,
    required Widget bottomWidget,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.1 : 0.03),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTypography.labelSm.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.headlineLgMobile.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottomWidget,
        ],
      ),
    );
  }

  Widget _buildNextClassHero(BuildContext context, DashboardState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFEFF6FF), const Color(0xFFE6FFFA)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'NEXT UP',
                  style: AppTypography.labelSm.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                state.nextClass.timeRemaining,
                style: AppTypography.labelSm.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            state.nextClass.title,
            style: AppTypography.headlineLgMobile.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: colorScheme.onSurfaceVariant,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                state.nextClass.room,
                style: AppTypography.labelMd.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                color: colorScheme.onSurfaceVariant,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                state.nextClass.time,
                style: AppTypography.labelMd.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Showing map to ${state.nextClass.room}')),
                  );
                },
                icon: const Icon(Icons.map, size: 18),
                label: const Text('View Map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.primary, width: 2),
                      image: DecorationImage(
                        image: NetworkImage(state.nextClass.professorAvatarUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? colorScheme.surface : colorScheme.primaryContainer,
                      border: Border.all(color: colorScheme.primary, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '+${state.nextClass.extraStudentsCount}',
                      style: TextStyle(
                        color: isDark ? colorScheme.onSurface : colorScheme.onPrimaryContainer,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.read(authProvider);
    final student = authState.studentUser;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFEFF6FF), const Color(0xFFE6FFFA)], // Pastel blue-teal gradient
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTypography.titleLg.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.65,
            children: [
              _buildActionButton(
                context: context,
                title: 'Mark Attendance',
                imagePath: 'assets/images/attendance_icon.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AttendancePage(initialTab: AttendanceTab.overview),
                    ),
                  );
                },
              ),
              _buildActionButton(
                context: context,
                title: 'View Grades',
                imagePath: 'assets/images/grades_icon.png',
                onTap: () => _showGradesDialog(context, student),
              ),
              _buildActionButton(
                context: context,
                title: 'Request ID',
                imagePath: 'assets/images/id_card_icon.png',
                onTap: () => _showStubMessage(context, 'ID card request simulation.'),
              ),
              _buildActionButton(
                context: context,
                title: 'Hostel Info',
                imagePath: 'assets/images/hostel_icon.png',
                onTap: () => _showHostelDialog(context, student),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                // Faded watermark background logo on the bottom-right
                Positioned(
                  right: -8,
                  bottom: -8,
                  child: Opacity(
                    opacity: isDark ? 0.16 : 0.08,
                    child: Image.asset(
                      imagePath,
                      width: 52,
                      height: 52,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Main content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Small circular icon badge at the top-left
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: isDark
                              ? colorScheme.surfaceVariant
                              : colorScheme.surfaceVariant.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        title,
                        style: AppTypography.labelSm.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentNoticesSection(BuildContext context, WidgetRef ref, List<Notice> recentNotices) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFEFF6FF), const Color(0xFFE6FFFA)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Notices',
                style: AppTypography.titleLg.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  ref.read(navigationProvider.notifier).selectTab(ShellTab.notices);
                },
                child: Text(
                  'View All',
                  style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: recentNotices.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final notice = recentNotices[index];
                Color barColor = colorScheme.secondary;
                if (notice.category.toLowerCase() == 'academic') {
                  barColor = colorScheme.primary;
                } else if (notice.category.toLowerCase() == 'administrative') {
                  barColor = colorScheme.outline;
                } else if (notice.category.toLowerCase() == 'error' || notice.title.contains('Outage')) {
                  barColor = colorScheme.error;
                }

                return Container(
                  width: 250,
                  decoration: BoxDecoration(
                    color: isDark ? colorScheme.surface : Colors.white,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                    border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            bottomLeft: Radius.circular(4),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              ref.read(noticesProvider.notifier).openNoticeDetail(notice);
                              ref.read(navigationProvider.notifier).selectTab(ShellTab.notices);
                            },
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        notice.category.toLowerCase() == 'academic'
                                            ? Icons.school_outlined
                                            : notice.category.toLowerCase() == 'placement'
                                                ? Icons.work_outline
                                                : Icons.campaign_outlined,
                                        color: barColor,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        notice.category.toUpperCase(),
                                        style: AppTypography.labelSm.copyWith(
                                          color: barColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    notice.title,
                                    style: AppTypography.labelMd.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notice.snippet,
                                    style: AppTypography.labelSm.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showStubMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showGradesDialog(BuildContext context, StudentUser? student) {
    final cgpa = student?.cgpa ?? '8.8 / 10';
    
    final Map<String, List<Map<String, String>>> gradesData = {
      'Semester 1': [
        {'subject': 'Engineering Mathematics I', 'code': 'MTH-101', 'grade': 'A'},
        {'subject': 'Applied Physics', 'code': 'PHY-101', 'grade': 'A+'},
        {'subject': 'Programming in C', 'code': 'CS-101', 'grade': 'A'},
        {'subject': 'English for Communication', 'code': 'ENG-101', 'grade': 'B+'},
      ],
      'Semester 2': [
        {'subject': 'Engineering Mathematics II', 'code': 'MTH-201', 'grade': 'A+'},
        {'subject': 'Data Structures & Algorithms', 'code': 'CS-201', 'grade': 'A'},
        {'subject': 'Digital Electronics', 'code': 'EC-201', 'grade': 'B+'},
        {'subject': 'Environmental Studies', 'code': 'CIV-101', 'grade': 'A'},
      ],
      'Semester 3': [
        {'subject': 'Discrete Mathematics', 'code': 'MTH-301', 'grade': 'A'},
        {'subject': 'Object Oriented Programming', 'code': 'CS-302', 'grade': 'A+'},
        {'subject': 'Database Management Systems', 'code': 'CS-303', 'grade': 'A'},
        {'subject': 'Computer Organization', 'code': 'CS-304', 'grade': 'B+'},
      ],
      'Semester 4': [
        {'subject': 'Design & Analysis of Algorithms', 'code': 'CS-401', 'grade': 'A'},
        {'subject': 'Operating Systems', 'code': 'CS-402', 'grade': 'A'},
        {'subject': 'Formal Languages & Automata', 'code': 'CS-403', 'grade': 'B+'},
        {'subject': 'Probability & Statistics', 'code': 'MTH-401', 'grade': 'A+'},
      ],
      'Semester 5': [
        {'subject': 'Systems Engineering', 'code': 'ENG-402', 'grade': 'A'},
        {'subject': 'Quantum Physics II', 'code': 'PHY-301', 'grade': 'A+'},
        {'subject': 'Linear Algebra', 'code': 'MTH-205', 'grade': 'A'},
        {'subject': 'AI Ethics Seminar', 'code': 'CS499', 'grade': 'A+'},
      ]
    };

    final semGpa = {
      'Semester 1': '8.2',
      'Semester 2': '8.5',
      'Semester 3': '8.7',
      'Semester 4': '8.8',
      'Semester 5': student?.prevSemMarks.split(' ').first ?? '8.8',
    };

    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.emoji_events, color: colorScheme.secondary),
              const SizedBox(width: 10),
              const Text('Academic Grade Sheet'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(
                  'Student: ${student?.name ?? "Alex Thompson"} (${student?.id ?? "ST-202301"})',
                  style: AppTypography.labelMd.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cumulative CGPA: $cgpa',
                  style: AppTypography.labelSm.copyWith(color: colorScheme.secondary, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 20),
                ...gradesData.entries.map((entry) {
                  final sem = entry.key;
                  final subjects = entry.value;
                  final gpa = semGpa[sem];

                  return ExpansionTile(
                    title: Text(sem, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'GPA: $gpa',
                        style: TextStyle(color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                    children: subjects.map((subj) {
                      return ListTile(
                        dense: true,
                        title: Text(subj['subject']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        subtitle: Text(subj['code']!),
                        trailing: CircleAvatar(
                          radius: 13,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(
                            subj['grade']!,
                            style: TextStyle(color: colorScheme.onPrimaryContainer, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showHostelDialog(BuildContext context, StudentUser? student) {
    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.apartment, color: colorScheme.secondary),
              const SizedBox(width: 10),
              const Text('Hostel Information'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHostelRow(context, Icons.domain, 'Hostel Block', student?.hostelBlock ?? 'Block B (Boys Hostel)'),
              _buildHostelRow(context, Icons.meeting_room, 'Room Number', student?.roomNo ?? 'Room 208'),
              _buildHostelRow(context, Icons.people, 'Room Occupancy', 'Double Sharing (AC Room)'),
              _buildHostelRow(context, Icons.face, 'Warden Name', 'Dr. A. K. Sen (Ext: 2404)'),
              const Divider(height: 20),
              Text(
                'Mess Schedule & Timings:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorScheme.onSurface),
              ),
              const SizedBox(height: 6),
              Text(
                '• Breakfast: 07:30 AM - 09:00 AM\n• Lunch: 12:30 PM - 02:00 PM\n• Dinner: 07:30 PM - 09:00 PM',
                style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              _buildHostelRow(context, Icons.check_circle, 'Mess Fee Status', 'Fully Paid (No Dues)', color: colorScheme.secondary),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHostelRow(BuildContext context, IconData icon, String label, String value, {Color? color}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
                children: [
                  TextSpan(text: '$label: ', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant)),
                  TextSpan(text: value, style: TextStyle(color: color ?? colorScheme.onSurface, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
