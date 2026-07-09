import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novau/core/theme/app_typography.dart';
import 'package:novau/features/auth/presentation/providers/auth_provider.dart';
import 'package:novau/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:novau/features/schedule/presentation/pages/schedule_page.dart';
import 'package:novau/features/notices/presentation/pages/notices_page.dart';
import 'package:novau/features/profile/presentation/pages/profile_page.dart';
import 'package:novau/features/shell/presentation/providers/navigation_provider.dart';
import 'package:novau/features/shell/presentation/pages/admin_shell_views.dart';

class ShellPage extends ConsumerStatefulWidget {
  const ShellPage({super.key});

  @override
  ConsumerState<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends ConsumerState<ShellPage> {
  int _adminActiveIndex = 0;
  bool _isDockVisible = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (authState.role == UserRole.admin) {
      return _buildAdminShell(context);
    } else {
      return _buildStudentShell(context);
    }
  }

  Widget _buildStudentShell(BuildContext context) {
    final activeTab = ref.watch(navigationProvider);

    final pages = [
      const DashboardPage(),
      const SchedulePage(),
      const NoticesPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: activeTab.index,
            children: pages,
          ),
          // Detection region at the bottom of the screen
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 70,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isDockVisible = true),
              onExit: (_) => setState(() => _isDockVisible = false),
              child: const SizedBox.expand(),
            ),
          ),
          // Tiny handle at the bottom center of the screen when dock is hidden
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            bottom: _isDockVisible ? -15 : 12,
            child: Center(
              child: GestureDetector(
                onTap: () => setState(() => _isDockVisible = true),
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isDockVisible = true),
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Animated floating glass dock
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            bottom: _isDockVisible ? 16 : -100,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isDockVisible = true),
              onExit: (_) => setState(() => _isDockVisible = false),
              child: _CustomBottomNavBar(
                activeTab: activeTab,
                onTabSelected: (tab) {
                  ref.read(navigationProvider.notifier).selectTab(tab);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminShell(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final adminPages = [
      AdminDashboardView(
        onGoToPublish: () => setState(() => _adminActiveIndex = 1),
        onGoToStudents: () => setState(() => _adminActiveIndex = 2),
      ),
      const AdminPublishNoticeView(),
      const AdminStudentDirectoryView(),
      const AdminProfileView(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _adminActiveIndex,
            children: adminPages,
          ),
          // Detection region at the bottom of the screen
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 70,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isDockVisible = true),
              onExit: (_) => setState(() => _isDockVisible = false),
              child: const SizedBox.expand(),
            ),
          ),
          // Tiny handle at the bottom center of the screen when dock is hidden
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            bottom: _isDockVisible ? -15 : 12,
            child: Center(
              child: GestureDetector(
                onTap: () => setState(() => _isDockVisible = true),
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isDockVisible = true),
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Animated floating glass dock for admin
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            bottom: _isDockVisible ? 16 : -100,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isDockVisible = true),
              onExit: (_) => setState(() => _isDockVisible = false),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155).withValues(alpha: 0.4)
                              : const Color(0xFFE2E8F0).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 10,
                        bottom: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildAdminNavItem(0, Icons.dashboard, Icons.dashboard_outlined, 'Console'),
                          _buildAdminNavItem(1, Icons.campaign, Icons.campaign_outlined, 'Publish'),
                          _buildAdminNavItem(2, Icons.badge, Icons.badge_outlined, 'Students'),
                          _buildAdminNavItem(3, Icons.person, Icons.person_outline, 'Profile'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = _adminActiveIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _adminActiveIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 8,
          vertical: isActive ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
              size: 24,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.labelSm.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CustomBottomNavBar extends StatelessWidget {
  final ShellTab activeTab;
  final ValueChanged<ShellTab> onTabSelected;

  const _CustomBottomNavBar({
    required this.activeTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155).withValues(alpha: 0.4)
                    : const Color(0xFFE2E8F0).withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ShellTab.values.map((tab) {
                final isActive = activeTab == tab;
                return GestureDetector(
                  onTap: () => onTabSelected(tab),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(
                      horizontal: isActive ? 16 : 8,
                      vertical: isActive ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? colorScheme.secondaryContainer : Colors.transparent,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getIconData(tab, isActive),
                          color: isActive ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 6),
                          Text(
                            _getTabLabel(tab),
                            style: AppTypography.labelSm.copyWith(
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(ShellTab tab, bool isActive) {
    switch (tab) {
      case ShellTab.dashboard:
        return isActive ? Icons.dashboard : Icons.dashboard_outlined;
      case ShellTab.schedule:
        return isActive ? Icons.calendar_today : Icons.calendar_today_outlined;
      case ShellTab.notices:
        return isActive ? Icons.campaign : Icons.campaign_outlined;
      case ShellTab.profile:
        return isActive ? Icons.person : Icons.person_outline;
    }
  }

  String _getTabLabel(ShellTab tab) {
    switch (tab) {
      case ShellTab.dashboard:
        return 'Dashboard';
      case ShellTab.schedule:
        return 'Schedule';
      case ShellTab.notices:
        return 'Notices';
      case ShellTab.profile:
        return 'Profile';
    }
  }
}
