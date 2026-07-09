import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:novau/core/theme/app_colors.dart';
import 'package:novau/core/theme/app_typography.dart';
import 'package:novau/features/attendance/presentation/providers/attendance_provider.dart';
import 'package:novau/features/auth/presentation/providers/auth_provider.dart' as auth;

class AttendancePage extends ConsumerStatefulWidget {
  final AttendanceTab initialTab;

  const AttendancePage({
    super.key,
    this.initialTab = AttendanceTab.overview,
  });

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> with SingleTickerProviderStateMixin {
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _primaryColor => _isDark ? const Color(0xFF93C5FD) : const Color(0xFF002045);
  Color get _onPrimary => _isDark ? const Color(0xFF002045) : const Color(0xFFFFFFFF);
  Color get _primaryContainer => _isDark ? const Color(0xFF1E3A8A) : const Color(0xFF1A365D);
  Color get _onPrimaryContainer => _isDark ? const Color(0xFFBFDBFE) : const Color(0xFF86A0CD);

  // Present/On-Track status: Emerald Green (light) vs Teal (dark)
  Color get _presentColor => _isDark ? const Color(0xFF2DD4BF) : const Color(0xFF10B981);
  Color get _onSecondary => _isDark ? const Color(0xFF115E59) : const Color(0xFFFFFFFF);
  Color get _presentContainerColor => _isDark ? const Color(0xFF13696A).withOpacity(0.3) : const Color(0xFFD1FAE5);
  Color get _onPresentContainerColor => _isDark ? const Color(0xFFCCFBF1) : const Color(0xFF065F46);

  Color get _tertiaryColor => _isDark ? const Color(0xFFFDE047) : const Color(0xFF2D1D00);
  Color get _onTertiary => _isDark ? const Color(0xFF713F12) : const Color(0xFFFFFFFF);
  Color get _tertiaryContainer => _isDark ? const Color(0xFF854D0E) : const Color(0xFF493100);
  Color get _onTertiaryContainer => _isDark ? const Color(0xFFFEF9C3) : const Color(0xFFCB9524);

  // Warning status: Yellow/Amber
  Color get _warningColor => _isDark ? const Color(0xFFFDE047) : const Color(0xFFF59E0B);
  Color get _warningContainerColor => _isDark ? const Color(0xFF854D0E).withOpacity(0.3) : const Color(0xFFFEF3C7);
  Color get _onWarningContainerColor => _isDark ? const Color(0xFFFEF9C3) : const Color(0xFF92400E);

  // Absent status: Bright Red
  Color get _absentColor => _isDark ? const Color(0xFFFCA5A5) : const Color(0xFFEF4444);
  Color get _onError => _isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFFFFFF);
  Color get _absentContainerColor => _isDark ? const Color(0xFF991B1B).withOpacity(0.3) : const Color(0xFFFEE2E2);
  Color get _onAbsentContainerColor => _isDark ? const Color(0xFFFEE2E2) : const Color(0xFF991B1B);

  // Structural colors
  Color get _backgroundColor => _isDark ? const Color(0xFF0F172A) : const Color(0xFFF7FAFC);
  Color get _onBackground => _isDark ? const Color(0xFFF8FAFC) : const Color(0xFF181C1E);

  Color get _surfaceColor => _isDark ? const Color(0xFF1E293B) : const Color(0xFFF7FAFC);
  Color get _onSurface => _isDark ? const Color(0xFFF8FAFC) : const Color(0xFF181C1E);
  Color get _surfaceBright => _isDark ? const Color(0xFF1E293B) : const Color(0xFFF7FAFC);
  Color get _surfaceDim => _isDark ? const Color(0xFF0F172A) : const Color(0xFFD7DADC);

  Color get _surfaceContainerLowest => _isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF);
  Color get _surfaceContainerLow => _isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F4F6);
  Color get _surfaceContainer => _isDark ? const Color(0xFF1E293B) : const Color(0xFFEBEEF0);
  Color get _surfaceContainerHigh => _isDark ? const Color(0xFF334155) : const Color(0xFFE5E9EB);
  Color get _surfaceContainerHighest => _isDark ? const Color(0xFF334155) : const Color(0xFFE0E3E5);

  Color get _onSurfaceVariant => _isDark ? const Color(0xFF94A3B8) : const Color(0xFF43474E);
  Color get _outline => _isDark ? const Color(0xFF64748B) : const Color(0xFF74777F);
  Color get _outlineVariant => _isDark ? const Color(0xFF334155) : const Color(0xFFC4C6CF);

  late AnimationController _scannerAnimationController;
  late TextEditingController _regNoController;

  @override
  void initState() {
    super.initState();
    _scannerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _regNoController = TextEditingController();

    // Set initial tab after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(attendanceProvider.notifier).setTab(widget.initialTab);
    });
  }

  @override
  void dispose() {
    _scannerAnimationController.dispose();
    _regNoController.dispose();
    super.dispose();
  }

  Widget _buildStudentHeader(auth.StudentUser student) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(student.avatarUrl),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 2),
                Text(
                  '${student.id} · ${student.department}',
                  style: AppTypography.labelSm.copyWith(color: _onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacultyHeader(auth.AdminUser admin) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(admin.avatarUrl),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  admin.name,
                  style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 2),
                Text(
                  'Faculty ID: ${admin.id} · ${admin.dept}',
                  style: AppTypography.labelSm.copyWith(color: _onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceProvider);
    final filteredLogs = ref.watch(filteredLogsProvider);
    final authState = ref.watch(auth.authProvider);
    final student = authState.studentUser;
    final admin = authState.adminUser;

    final isStudent = state.role == UserRole.student;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isStudent ? 'Attendance Module' : 'Faculty Panel',
          style: AppTypography.titleLg.copyWith(color: _primaryColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_outlined, color: _primaryColor),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display profile-locked header
              if (isStudent && student != null)
                _buildStudentHeader(student)
              else if (!isStudent && admin != null)
                _buildFacultyHeader(admin),

              // Switch between Student view and Faculty view
              if (isStudent) ...[
                // Tabs selection row
                _buildStudentTabs(state),
                const SizedBox(height: 20),
                // Active tab contents
                _buildActiveTabContent(state, filteredLogs),
              ] else ...[
                // Faculty View contents
                _buildFacultyView(state),
              ],
              const SizedBox(height: 48), // Padding at bottom
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildRoleToggle(AttendanceState state) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _surfaceContainer,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => ref.read(attendanceProvider.notifier).setRole(UserRole.student),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: state.role == UserRole.student ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(99),
                boxShadow: state.role == UserRole.student
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                'Student',
                style: AppTypography.labelMd.copyWith(
                  color: state.role == UserRole.student ? _presentColor : _onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => ref.read(attendanceProvider.notifier).setRole(UserRole.faculty),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: state.role == UserRole.faculty ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(99),
                boxShadow: state.role == UserRole.faculty
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                'Faculty',
                style: AppTypography.labelMd.copyWith(
                  color: state.role == UserRole.faculty ? _presentColor : _onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentTabs(AttendanceState state) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _outlineVariant.withOpacity(0.3))),
      ),
      child: Row(
        children: [
          _buildTabItem(AttendanceTab.overview, 'Overview', state),
          const SizedBox(width: 20),
          _buildTabItem(AttendanceTab.history, 'History', state),
          const SizedBox(width: 20),
          _buildTabItem(AttendanceTab.scanner, 'Scan Presence', state, icon: Icons.qr_code_scanner),
        ],
      ),
    );
  }

  Widget _buildTabItem(AttendanceTab tab, String label, AttendanceState state, {IconData? icon}) {
    final isActive = state.activeTab == tab;

    return GestureDetector(
      onTap: () => ref.read(attendanceProvider.notifier).setTab(tab),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 18,
                    color: isActive ? _presentColor : _onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: AppTypography.labelMd.copyWith(
                    color: isActive ? _presentColor : _onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              height: 3,
              width: 60,
              decoration: BoxDecoration(
                color: _presentColor,
                borderRadius: BorderRadius.circular(9),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveTabContent(AttendanceState state, List<AttendanceLogRecord> logs) {
    switch (state.activeTab) {
      case AttendanceTab.overview:
        return _buildOverviewTab(state);
      case AttendanceTab.history:
        return _buildHistoryTab(state, logs);
      case AttendanceTab.scanner:
        return _buildScannerTab(state);
    }
  }

  Widget _buildOverviewTab(AttendanceState state) {
    final hasLowAttendance = state.studentSubjects.any((s) => s.isLow);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Attendance warning chip
        if (hasLowAttendance) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _warningContainerColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _warningColor.withOpacity(0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning, color: _onWarningContainerColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Low Attendance Alert',
                        style: AppTypography.titleLarge.copyWith(
                          color: _onWarningContainerColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Your attendance in 'Quantum Physics II' is currently 72%. Minimum required is 75%.",
                        style: AppTypography.bodyMedium.copyWith(color: _onWarningContainerColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Bento Subjects Grid
        Text(
          'Subject Summary',
          style: AppTypography.titleLg.copyWith(color: _primaryColor, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 12,
            mainAxisExtent: 140,
          ),
          itemCount: state.studentSubjects.where((s) => s.total > 0).length,
          itemBuilder: (context, index) {
            final subject = state.studentSubjects.where((s) => s.total > 0).toList()[index];
            final percentColor = subject.isLow ? _onWarningContainerColor : _presentColor;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _outlineVariant.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: subject.isLow ? _warningContainerColor : _presentContainerColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          subject.code,
                          style: AppTypography.labelSm.copyWith(
                            color: subject.isLow ? _onWarningContainerColor : _onPresentContainerColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Attended: ${subject.attended}/${subject.total}',
                        style: AppTypography.labelSm.copyWith(color: _onSurfaceVariant),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          subject.title,
                          style: AppTypography.titleLarge.copyWith(
                            color: _primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${subject.percent}%',
                            style: AppTypography.headlineLgMobile.copyWith(
                              color: percentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            subject.statusText,
                            style: AppTypography.labelSm.copyWith(
                              color: percentColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: subject.percent / 100,
                      backgroundColor: _surfaceContainerLow,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        subject.isLow ? _warningColor : _presentColor,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHistoryTab(AttendanceState state, List<AttendanceLogRecord> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filters Row
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _outlineVariant.withOpacity(0.4)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: state.selectedLogFilter,
                    icon: Icon(Icons.arrow_drop_down, color: _outline),
                    isExpanded: true,
                    style: AppTypography.bodyMedium.copyWith(color: _onSurface),
                    items: <String>[
                      'All Subjects',
                      'Systems Engineering',
                      'Linear Algebra',
                      'Quantum Physics II',
                      'AI Ethics Seminar'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        ref.read(attendanceProvider.notifier).setLogFilter(newValue);
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _outlineVariant.withOpacity(0.4)),
              ),
              child: Icon(Icons.filter_list, color: _outline, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Logs table card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _outlineVariant.withOpacity(0.3)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: _surfaceContainerLow,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Attendance Logs', style: AppTypography.titleLarge.copyWith(fontSize: 16)),
                  ],
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: _outlineVariant.withOpacity(0.2),
                ),
                itemBuilder: (context, index) {
                  final log = logs[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.subjectName,
                                style: AppTypography.labelMd.copyWith(color: _primaryColor, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${log.dateStr} · ${log.instructor}',
                                style: AppTypography.labelSm.copyWith(color: _onSurfaceVariant, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: log.isPresent
                                ? _presentContainerColor.withOpacity(0.4)
                                : _absentContainerColor,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: log.isPresent ? _presentColor : _absentColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                log.isPresent ? 'Present' : 'Absent',
                                style: AppTypography.labelSm.copyWith(
                                  color: log.isPresent ? _onPresentContainerColor : _onAbsentContainerColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (logs.isEmpty)
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text('No attendance logs found for this filter.', style: TextStyle(color: _outline)),
                  ),
                ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: _surfaceContainerLow,
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'View Older Records',
                    style: AppTypography.labelMd.copyWith(color: _presentColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScannerTab(AttendanceState state) {
    final authState = ref.watch(auth.authProvider);
    final student = authState.studentUser;

    if (state.scanErrorMessage != null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _absentColor.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 10),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _absentContainerColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline, color: _absentColor, size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                'Verification Failed',
                style: AppTypography.headlineLgMobile.copyWith(color: _absentColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                state.scanErrorMessage!,
                style: AppTypography.bodyMedium.copyWith(color: _onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(attendanceProvider.notifier).resetScanner();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _absentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Try Again'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (state.isScanSuccessful) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _outlineVariant.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(0, 10),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _presentContainerColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: _onPresentContainerColor, size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                'Verification Successful!',
                style: AppTypography.headlineLgMobile.copyWith(color: _primaryColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Attendance has been registered successfully.',
                style: AppTypography.bodyMedium.copyWith(color: _onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      state.scannedStudentName ?? 'Visitor Student',
                      style: AppTypography.labelMd.copyWith(color: _primaryColor, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reg Number: ${state.scannedRegNumber ?? "N/A"}',
                      style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Session: R20/R24 Lab Check-In',
                      style: AppTypography.labelSm.copyWith(color: _onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Time: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} · 04:00 PM',
                      style: AppTypography.labelSm.copyWith(color: _onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(attendanceProvider.notifier).setTab(AttendanceTab.overview);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _presentColor,
                        foregroundColor: _onSecondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Go to Overview'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(attendanceProvider.notifier).setTab(AttendanceTab.history);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _presentColor,
                        side: BorderSide(color: _presentColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('View Logs'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 10),
              blurRadius: 30,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Mark Presence',
                style: AppTypography.headlineLgMobile.copyWith(color: _primaryColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Align the student barcode/QR within the camera viewfinder or enter manually.',
                style: AppTypography.bodyMedium.copyWith(color: _onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Scanner view (Real MobileScanner + Simulated scan line)
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Camera Icon Center when camera is inactive
                    if (!state.isScannerCameraActive)
                      const Center(
                        child: Icon(Icons.photo_camera, size: 64, color: Colors.white38),
                      )
                    else
                      // Real Camera viewfinder
                      Stack(
                        children: [
                          Positioned.fill(
                            child: MobileScanner(
                              onDetect: (capture) {
                                final List<Barcode> barcodes = capture.barcodes;
                                for (final barcode in barcodes) {
                                  if (barcode.rawValue != null) {
                                    ref.read(attendanceProvider.notifier).scanRegistrationNumber(barcode.rawValue!);
                                    break;
                                  }
                                }
                              },
                            ),
                          ),
                          // Moving Scan Line overlay
                          AnimatedBuilder(
                            animation: _scannerAnimationController,
                            builder: (context, child) {
                              return Positioned(
                                top: _scannerAnimationController.value * 200,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 2,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        _presentColor.withValues(alpha: 0.8),
                                        Colors.transparent
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                    // Scanner frame corners
                    Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    // Thick border corners
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: _presentColor, width: 4),
                            left: BorderSide(color: _presentColor, width: 4),
                          ),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(8)),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: _presentColor, width: 4),
                            right: BorderSide(color: _presentColor, width: 4),
                          ),
                          borderRadius: BorderRadius.only(topRight: Radius.circular(8)),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: _presentColor, width: 4),
                            left: BorderSide(color: _presentColor, width: 4),
                          ),
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8)),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: _presentColor, width: 4),
                            right: BorderSide(color: _presentColor, width: 4),
                          ),
                          borderRadius: BorderRadius.only(bottomRight: Radius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (state.isScannerCameraActive) ...[
                // Registration Number Manual Input
                TextField(
                  controller: _regNoController,
                  decoration: InputDecoration(
                    labelText: 'Student Reg Number',
                    hintText: 'e.g., ST-202301 or 24IT501',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: () {
                        if (_regNoController.text.trim().isNotEmpty) {
                          ref.read(attendanceProvider.notifier).scanRegistrationNumber(_regNoController.text);
                          _regNoController.clear();
                        }
                      },
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      ref.read(attendanceProvider.notifier).scanRegistrationNumber(value);
                      _regNoController.clear();
                    }
                  },
                ),
                const SizedBox(height: 12),
                // Suggestions Header
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Quick Scan Simulation Codes:',
                    style: AppTypography.labelSm.copyWith(color: _onSurfaceVariant, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 6),
                // Suggestions Pills
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (student != null)
                      _buildQuickCodeChip(student.id, 'Myself (${student.name.split(' ')[0]})'),
                    _buildQuickCodeChip('ST-202301', 'Alex'),
                    _buildQuickCodeChip('ST-202302', 'Beatrice'),
                    _buildQuickCodeChip('ST-202305', 'Ethan'),
                    _buildQuickCodeChip('24IT501', 'Invalid ID'),
                  ],
                ),
                const SizedBox(height: 16),
              ] else ...[
                // Instruction Note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info, color: _presentColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Align the QR/barcode on your pass card. System camera will scan and verify it against your logged-in profile.',
                          style: AppTypography.labelMd.copyWith(color: _onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isScannerCameraActive
                      ? null
                      : () {
                          ref.read(attendanceProvider.notifier).activateScannerCamera();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _presentColor,
                    foregroundColor: _onSecondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 2,
                  ),
                  child: Text(
                    state.isScannerCameraActive ? 'Scanning in progress...' : 'Access Camera',
                    style: AppTypography.labelMd.copyWith(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCodeChip(String code, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return ActionChip(
      label: Text('$label ($code)'),
      labelStyle: AppTypography.labelSm.copyWith(color: colorScheme.onSecondaryContainer, fontSize: 11),
      backgroundColor: colorScheme.secondaryContainer,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      onPressed: () {
        ref.read(attendanceProvider.notifier).scanRegistrationNumber(code);
      },
    );
  }

  Widget _buildFacultyView(AttendanceState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Roster Details Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _outlineVariant.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Session Management',
                style: AppTypography.titleLarge.copyWith(color: _primaryColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Recording attendance for CS-101: Introduction to AI',
                style: AppTypography.bodyMedium.copyWith(color: _onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Simulated QR Code generated on projector screen.')),
                  );
                },
                icon: const Icon(Icons.qr_code, size: 18),
                label: const Text('Generate QR Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Roster List Table
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Student Roster',
              style: AppTypography.titleLg.copyWith(color: _primaryColor, fontWeight: FontWeight.bold),
            ),
            Text(
              '(${state.facultyRoster.length} Registered)',
              style: AppTypography.bodyMedium.copyWith(color: _onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _outlineVariant.withOpacity(0.3)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Roster Header
              Container(
                color: _surfaceContainerLow,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text('Student', style: AppTypography.labelSm.copyWith(color: _onSurfaceVariant)),
                    ),
                    Expanded(
                      child: Text('Attendance', style: AppTypography.labelSm.copyWith(color: _onSurfaceVariant)),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text('Status', style: AppTypography.labelSm.copyWith(color: _onSurfaceVariant)),
                      ),
                    ),
                  ],
                ),
              ),
              // Roster Items
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.facultyRoster.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: _outlineVariant.withOpacity(0.2),
                ),
                itemBuilder: (context, index) {
                  final student = state.facultyRoster[index];

                  final isPresentSelected = student.status == AttendanceStatus.present;
                  final isAbsentSelected = student.status == AttendanceStatus.absent;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                student.id,
                                style: AppTypography.labelSm.copyWith(color: _outline),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(99),
                                  child: LinearProgressIndicator(
                                    value: student.overallAttendance / 100,
                                    backgroundColor: _surfaceContainerLow,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      student.overallAttendance < 75 ? _absentColor : _presentColor,
                                    ),
                                    minHeight: 4,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${student.overallAttendance}%',
                                style: AppTypography.labelSm.copyWith(
                                  color: student.overallAttendance < 75 ? _absentColor : _onSurface,
                                  fontWeight: student.overallAttendance < 75 ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () {
                                  ref
                                      .read(attendanceProvider.notifier)
                                      .toggleRosterStatus(student.id, AttendanceStatus.present);
                                },
                                icon: const Icon(Icons.check, size: 18),
                                color: isPresentSelected ? Colors.white : _outline,
                                style: IconButton.styleFrom(
                                  backgroundColor: isPresentSelected ? _presentColor : Colors.transparent,
                                  side: BorderSide(
                                    color: isPresentSelected ? Colors.transparent : _outlineVariant,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                onPressed: () {
                                  ref
                                      .read(attendanceProvider.notifier)
                                      .toggleRosterStatus(student.id, AttendanceStatus.absent);
                                },
                                icon: const Icon(Icons.close, size: 18),
                                color: isAbsentSelected ? Colors.white : _outline,
                                style: IconButton.styleFrom(
                                  backgroundColor: isAbsentSelected ? _absentColor : Colors.transparent,
                                  side: BorderSide(
                                    color: isAbsentSelected ? Colors.transparent : _outlineVariant,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Action Buttons Bottom
              Container(
                padding: const EdgeInsets.all(16),
                color: _surfaceContainerLow,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Session cancelled.')),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _onSurface,
                          side: BorderSide(color: _outline),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel Session'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Attendance roster submitted to university systems.')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _presentColor,
                          foregroundColor: _onSecondary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Submit Roster'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
