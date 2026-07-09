import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novau/core/theme/app_typography.dart';
import 'package:novau/features/auth/presentation/providers/auth_provider.dart';
import 'package:novau/features/auth/presentation/pages/login_page.dart';
import 'package:novau/features/attendance/presentation/providers/attendance_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late StudentUser _currentProfile;
  bool _initialized = false;
  final TextEditingController _scanInputController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final loggedInStudent = ref.read(authProvider).studentUser;
      _currentProfile = loggedInStudent ?? studentDatabase['ST-202301']!;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _scanInputController.dispose();
    super.dispose();
  }

  void _scanProfileCode(String code) {
    code = code.trim().toUpperCase();
    if (studentDatabase.containsKey(code)) {
      setState(() {
        _currentProfile = studentDatabase[code]!;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully loaded profile for ${studentDatabase[code]!.name}!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } else {
      // Dynamic profile fallback
      setState(() {
        _currentProfile = StudentUser(
          id: code,
          name: 'External Student ($code)',
          age: 20,
          semester: 'N/A',
          phone: 'N/A',
          parentName: 'External Guardian',
          parentPhone: 'N/A',
          prevSemMarks: 'N/A',
          email: 'external@becbapatla.ac.in',
          cgpa: 'N/A',
          department: 'Guest Department, BEC',
          hostelBlock: 'Visvesvaraya Block',
          roomNo: 'N/A',
          libraryCard: 'LIB-BEC-EXT-${code.hashCode.abs()}',
          avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop',
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loaded guest card details.')),
      );
    }
  }

  // Opens camera simulator sheet
  void _openCameraScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Simulated Barcode Scanner',
                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan or enter an active student registration number to pull their academic records.',
                    style: AppTypography.labelSm.copyWith(color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Mock Camera Viewport
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Positioned.fill(
                            child: Icon(
                              Icons.photo_camera,
                              color: Colors.white24,
                              size: 64,
                            ),
                          ),
                          // Pulse red scanner line
                          Container(
                            width: double.infinity,
                            height: 3,
                            color: Colors.redAccent,
                          ),
                          Positioned(
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Align Student ID within frame',
                                style: TextStyle(color: Colors.white, fontSize: 11),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Manual Text input
                  TextField(
                    controller: _scanInputController,
                    decoration: InputDecoration(
                      labelText: 'Registration ID / Code',
                      hintText: 'e.g. ST-202302',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          if (_scanInputController.text.isNotEmpty) {
                            _scanProfileCode(_scanInputController.text);
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                    onSubmitted: (val) {
                      if (val.isNotEmpty) {
                        _scanProfileCode(val);
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Quick test suggestions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ActionChip(
                        label: const Text('Beatrice (ST-202302)'),
                        onPressed: () {
                          _scanProfileCode('ST-202302');
                          Navigator.pop(context);
                        },
                      ),
                      ActionChip(
                        label: const Text('Cassius (ST-202303)'),
                        onPressed: () {
                          _scanProfileCode('ST-202303');
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Student Directory Card', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 1. Student Glass Identity Card
              Container(
                width: double.infinity,
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
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                      offset: const Offset(0, 10),
                      blurRadius: 24,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar image frame
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: colorScheme.primary, width: 2.5),
                            image: DecorationImage(
                              image: NetworkImage(_currentProfile.avatarUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Basic Identity
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentProfile.name,
                                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentProfile.department,
                                style: AppTypography.labelMd.copyWith(color: colorScheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _currentProfile.id,
                                  style: AppTypography.labelSm.copyWith(
                                    color: colorScheme.onSecondaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, thickness: 1),
                    // Simulated Identity QR Code Card
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // QR View container
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                              ),
                              child: const Icon(
                                Icons.qr_code_2,
                                size: 50,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BEC Student Pass',
                                  style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Tap code to scan other ID',
                                  style: AppTypography.labelSm.copyWith(color: colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Scanner Trigger
                        ElevatedButton.icon(
                          onPressed: _openCameraScanner,
                          icon: const Icon(Icons.photo_camera, size: 16),
                          label: const Text('Scan QR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.secondary,
                            foregroundColor: colorScheme.onSecondary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Student Details Bento System
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _buildDetailTile(
                    'CGPA',
                    _currentProfile.cgpa,
                    Icons.insights,
                    onTap: () => _showCgpaDialog(context, _currentProfile),
                  ),
                  _buildDetailTile(
                    'Semester',
                    _currentProfile.semester,
                    Icons.school,
                    onTap: () => _showSemesterSubjectsDialog(context, ref, _currentProfile),
                  ),
                  _buildDetailTile('Age', '${_currentProfile.age} Yrs', Icons.cake_outlined),
                  _buildDetailTile(
                    'Library Card',
                    _currentProfile.libraryCard,
                    Icons.local_library,
                    onTap: () => _showLibraryDialog(context, _currentProfile),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3. Contact & Parents & Marks (Full Width Bento Rows)
              _buildFullWidthTile(
                title: 'Previous Sem Marks',
                value: _currentProfile.prevSemMarks,
                icon: Icons.emoji_events_outlined,
              ),
              const SizedBox(height: 12),
              _buildFullWidthTile(
                title: 'Parent / Guardian',
                value: _currentProfile.parentName,
                icon: Icons.supervisor_account_outlined,
              ),
              const SizedBox(height: 12),
              _buildFullWidthTile(
                title: 'Parent Phone Number',
                value: _currentProfile.parentPhone,
                icon: Icons.phone_callback_outlined,
              ),
              const SizedBox(height: 12),
              _buildFullWidthTile(
                title: 'Email Address',
                value: _currentProfile.email,
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 12),
              _buildFullWidthTile(
                title: 'Student Mobile Phone',
                value: _currentProfile.phone,
                icon: Icons.phone_android,
              ),
              const SizedBox(height: 12),
              _buildFullWidthTile(
                title: 'Campus Accommodation',
                value: '${_currentProfile.hostelBlock} · ${_currentProfile.roomNo}',
                icon: Icons.apartment,
              ),
              const SizedBox(height: 24),

              // 4. Logout Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Log Out Session', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 60), // bottom spacing for scroller overlap
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTile(String title, String value, IconData icon, {VoidCallback? onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTypography.labelSm.copyWith(color: colorScheme.onSurfaceVariant)),
                Icon(icon, size: 16, color: colorScheme.secondary),
              ],
            ),
            Text(
              value,
              style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullWidthTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelSm.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSemesterSubjectsDialog(BuildContext context, WidgetRef ref, StudentUser student) {
    final attendanceState = ref.read(attendanceProvider);
    final subjects = attendanceState.studentSubjects;

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
              Icon(Icons.school, color: colorScheme.secondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${student.semester} Enrolled Courses',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.secondaryContainer,
                    child: Text(
                      subject.code.split('-').first,
                      style: TextStyle(color: colorScheme.onSecondaryContainer, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(subject.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('Code: ${subject.code} · ${subject.attended}/${subject.total} Classes', style: const TextStyle(fontSize: 11)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: subject.isLow ? colorScheme.errorContainer : colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${subject.percent}%',
                      style: TextStyle(
                        color: subject.isLow ? colorScheme.onErrorContainer : colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                );
              },
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

  void _showCgpaDialog(BuildContext context, StudentUser student) {
    final semGpa = {
      'Semester 1': '8.2',
      'Semester 2': '8.5',
      'Semester 3': '8.7',
      'Semester 4': '8.8',
      'Semester 5 (Prev Sem)': student.prevSemMarks.split(' ').first,
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
              Icon(Icons.insights, color: colorScheme.secondary),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Academic GPAs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text('Cumulative Grade Point Average (CGPA)', style: TextStyle(color: colorScheme.onSecondaryContainer, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(student.cgpa, style: TextStyle(color: colorScheme.onSecondaryContainer, fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...semGpa.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(
                        '${entry.value} / 10',
                        style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }).toList(),
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

  void _showLibraryDialog(BuildContext context, StudentUser student) {
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
              Icon(Icons.local_library, color: colorScheme.secondary),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Library Card Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHostelRow(context, Icons.badge_outlined, 'Card Number', student.libraryCard),
              _buildHostelRow(context, Icons.info_outline, 'Card Status', 'Active (All Access)'),
              _buildHostelRow(context, Icons.event_available, 'Expiry Date', 'June 15, 2027'),
              _buildHostelRow(context, Icons.monetization_on_outlined, 'Outstanding Fines', '\$0.00'),
              const Divider(height: 20),
              Text(
                'Books Currently Issued:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              _buildBookRow(context, '1. Systems Engineering Principles', 'Due: July 15, 2026'),
              const SizedBox(height: 6),
              _buildBookRow(context, '2. Quantum Mechanics: Concepts', 'Due: July 20, 2026'),
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

  Widget _buildBookRow(BuildContext context, String title, String dueInfo) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        Text(dueInfo, style: TextStyle(color: colorScheme.secondary, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
