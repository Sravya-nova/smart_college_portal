import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novau/core/theme/app_typography.dart';
import 'package:novau/features/schedule/presentation/providers/schedule_provider.dart';
import 'package:novau/features/auth/presentation/providers/auth_provider.dart';

class SchedulePage extends ConsumerWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduleProvider);
    final scheduleItems = ref.watch(currentDayScheduleProvider);
    final colorScheme = Theme.of(context).colorScheme;
    
    final authState = ref.watch(authProvider);
    final student = authState.studentUser;
    final studentName = student != null ? student.name.split(' ').first : 'Student';
    final studentAvatar = student != null ? student.avatarUrl : 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150&auto=format&fit=crop';

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(studentAvatar),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Hello, $studentName',
              style: AppTypography.titleLg.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_outlined, color: colorScheme.primary),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar Strip
            _buildCalendarStrip(context, ref, state),
            const SizedBox(height: 16),
            // Timeline Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "${_getDayName(state.selectedDayIndex)}'s Timeline",
                style: AppTypography.titleLg.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            // Timeline Content
            Expanded(
              child: scheduleItems.isEmpty
                  ? _buildEmptyState(context)
                  : _buildTimelineList(context, ref, state, scheduleItems),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarStrip(BuildContext context, WidgetRef ref, ScheduleState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final now = DateTime.now();
    final currentWeekday = now.weekday; // 1 = Mon, 7 = Sun
    final monday = now.subtract(Duration(days: currentWeekday - 1));

    final days = List.generate(7, (index) {
      final date = monday.add(Duration(days: index));
      final names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return {
        'name': names[index],
        'date': date.day.toString(),
      };
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: List.generate(days.length, (index) {
          final isSelected = state.selectedDayIndex == index;
          final day = days[index];

          return Container(
            width: 60,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                ref.read(scheduleProvider.notifier).selectDay(index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.secondary
                      : (isDark ? colorScheme.surface : const Color(0xFFFFFFFF)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.secondary.withValues(alpha: 0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      day['name']!,
                      style: AppTypography.labelSm.copyWith(
                        color: isSelected
                            ? colorScheme.onSecondary.withValues(alpha: 0.8)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day['date']!,
                      style: AppTypography.headlineMedium.copyWith(
                        color: isSelected ? colorScheme.onSecondary : colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimelineList(
    BuildContext context,
    WidgetRef ref,
    ScheduleState state,
    List<dynamic> items,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isLast = index == items.length - 1;

        return Stack(
          children: [
            // Vertical Line matching `.timeline-line` in HTML
            if (!isLast)
              Positioned(
                left: 11,
                top: 24,
                bottom: 0,
                child: Container(
                  width: 2,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
            // Timeline Content Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline Dot
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _buildTimelineDot(context, item, state),
                ),
                const SizedBox(width: 16),
                // Timeline Card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _buildTimelineCard(context, ref, state, item),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimelineDot(BuildContext context, dynamic item, ScheduleState state) {
    final colorScheme = Theme.of(context).colorScheme;

    if (item.isBreak) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.outlineVariant, width: 4),
        ),
      );
    }

    if (item.isSpecial) {
      final isReminderActive = state.activeReminders.contains(item.id);
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: isReminderActive ? colorScheme.tertiary : colorScheme.primaryContainer,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: (isReminderActive ? colorScheme.tertiary : colorScheme.tertiaryContainer).withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      );
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.secondary, width: 4),
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, WidgetRef ref, ScheduleState state, dynamic item) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (item.isBreak) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.restaurant, color: colorScheme.outline, size: 20),
            const SizedBox(width: 12),
            Text(
              '${item.title} (${item.time})',
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    final isSpecial = item.isSpecial;
    final isReminderActive = state.activeReminders.contains(item.id);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSpecial
              ? (isReminderActive ? colorScheme.tertiary : colorScheme.tertiaryContainer)
              : colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: isSpecial ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (isSpecial)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12)),
                ),
                child: Text(
                  'Happening Soon',
                  style: AppTypography.labelSm.copyWith(
                    color: colorScheme.onTertiaryContainer,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSpecial
                            ? colorScheme.tertiaryContainer.withValues(alpha: 0.3)
                            : colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        item.sessionType.toUpperCase(),
                        style: AppTypography.labelSm.copyWith(
                          color: isSpecial ? colorScheme.onTertiaryContainer : colorScheme.onSecondaryContainer,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: isSpecial ? 90 : 0), // Push away from tag
                      child: Text(
                        item.time,
                        style: AppTypography.labelSm.copyWith(color: colorScheme.outline),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  style: AppTypography.titleLarge.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.person_outline, color: colorScheme.onSurfaceVariant, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.professor,
                              style: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: colorScheme.onSurfaceVariant, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.room,
                              style: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (isSpecial)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(scheduleProvider.notifier).toggleReminder(item.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isReminderActive
                                      ? 'Reminder cancelled for ${item.title}'
                                      : 'Reminder set for ${item.title}!',
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isReminderActive ? colorScheme.outlineVariant : colorScheme.secondary,
                            foregroundColor: isReminderActive ? colorScheme.primary : colorScheme.onSecondary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(isReminderActive ? 'Reminder Set ✓' : 'Set Reminder'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Opening syllabus PDF...')),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.secondary,
                            side: BorderSide(color: colorScheme.secondary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('View Syllabus'),
                        ),
                      ),
                    ],
                  )
                else
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Downloading materials for ${item.title}...')),
                      );
                    },
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Download Materials'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.secondary,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.outlineVariant,
              style: BorderStyle.solid,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_busy, size: 64, color: colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                'No classes scheduled',
                style: AppTypography.headlineLgMobile.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Enjoy your break! Use this time to catch up on research or visit the campus library.',
                style: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDayName(int index) {
    const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    if (index >= 0 && index < names.length) {
      return names[index];
    }
    return 'Unknown';
  }
}
