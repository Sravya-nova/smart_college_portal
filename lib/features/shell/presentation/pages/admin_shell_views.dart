import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novau/core/theme/app_typography.dart';
import 'package:novau/features/auth/presentation/providers/auth_provider.dart';
import 'package:novau/features/notices/presentation/providers/notices_provider.dart';
import 'package:novau/features/auth/presentation/pages/login_page.dart';
import 'package:novau/features/notices/data/models/notice.dart';

// --- ADMIN DASHBOARD VIEW ---
class AdminDashboardView extends ConsumerWidget {
  final VoidCallback onGoToPublish;
  final VoidCallback onGoToStudents;

  const AdminDashboardView({
    super.key,
    required this.onGoToPublish,
    required this.onGoToStudents,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final noticesState = ref.watch(noticesProvider);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Admin Console', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Admin banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back,',
                      style: AppTypography.labelMd.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                    ),
                    Text(
                      authState.adminUser?.name ?? 'Administrator',
                      style: AppTypography.headlineLgMobile.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Department: ${authState.adminUser?.dept ?? "BEC Campus"}',
                      style: AppTypography.labelSm.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Statistics grid (Bento Style)
              Text(
                'Campus Analytics',
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildStatTile(
                    title: 'Active Students',
                    value: studentDatabase.length.toString(),
                    icon: Icons.people_outline,
                    color: colorScheme.primary,
                    bg: colorScheme.primaryContainer.withValues(alpha: 0.25),
                  ),
                  _buildStatTile(
                    title: 'Published Notices',
                    value: noticesState.notices.length.toString(),
                    icon: Icons.campaign_outlined,
                    color: colorScheme.secondary,
                    bg: colorScheme.secondaryContainer.withValues(alpha: 0.25),
                    onTap: () => _showPublishedNoticesDialog(context, noticesState.notices),
                  ),
                  _buildStatTile(
                    title: 'Admins Active',
                    value: adminDatabase.length.toString(),
                    icon: Icons.security_outlined,
                    color: Colors.teal,
                    bg: Colors.teal.withValues(alpha: 0.15),
                  ),
                  _buildStatTile(
                    title: 'System Regulation',
                    value: 'R20 / R24',
                    icon: Icons.settings_applications_outlined,
                    color: Colors.amber[800]!,
                    bg: Colors.amber.withValues(alpha: 0.15),
                    onTap: () => _showRegulationsDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Access Admin Buttons
              Text(
                'Quick Tasks',
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: onGoToPublish,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark ? colorScheme.surface : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.add_comment_outlined, size: 28, color: colorScheme.primary),
                            const SizedBox(height: 8),
                            Text('Publish Notice', style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: onGoToStudents,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark ? colorScheme.surface : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.badge_outlined, size: 28, color: colorScheme.secondary),
                            const SizedBox(height: 8),
                            Text('Student Records', style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bg,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 20, color: color),
                const Icon(Icons.trending_up, size: 14, color: Colors.green),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPublishedNoticesDialog(BuildContext context, List<Notice> notices) {
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
              Icon(Icons.campaign, color: colorScheme.secondary),
              const SizedBox(width: 10),
              const Text('Published Notices'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: notices.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('No notices have been published yet.'),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: notices.length,
                    itemBuilder: (context, index) {
                      final notice = notices[index];
                      return ExpansionTile(
                        title: Text(
                          notice.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          'Category: ${notice.category} · ${notice.date}',
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notice.snippet,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  notice.description,
                                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  void _showRegulationsDialog(BuildContext context) {
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
              Icon(Icons.settings_applications, color: colorScheme.secondary),
              const SizedBox(width: 10),
              const Text('Academic Regulations'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 350,
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: colorScheme.secondary,
                    unselectedLabelColor: colorScheme.onSurfaceVariant,
                    indicatorColor: colorScheme.secondary,
                    tabs: const [
                      Tab(text: 'R20 Regulation'),
                      Tab(text: 'R24 Regulation'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // R20 Regulation Points
                        ListView(
                          children: [
                            _buildRegulationPoint(context, '1. Grading Scale', 'Standard Absolute Grading Scale out of a 10-point scale.'),
                            _buildRegulationPoint(context, '2. Attendance Rule', 'Minimum of 75% attendance required in each individual subject.'),
                            _buildRegulationPoint(context, '3. Condonation Rule', 'Up to 10% condonation allowed on medical/sports grounds with formal approval.'),
                            _buildRegulationPoint(context, '4. Pass Percentage', 'Minimum 40% marks required in internal + external exams to pass a subject.'),
                            _buildRegulationPoint(context, '5. Credit Load', 'Standard semester load of 20-22 credits per semester.'),
                          ],
                        ),
                        // R24 Regulation Points
                        ListView(
                          children: [
                            _buildRegulationPoint(context, '1. Relative Grading', 'Introduction of relative grading system based on cohort performance curves.'),
                            _buildRegulationPoint(context, '2. Strict Curfew / Attendance', 'Strict 75% attendance cap. Non-compliance results in automatic detention.'),
                            _buildRegulationPoint(context, '3. Assessment Weight', '40% weightage for continuous internal assessment, 60% weightage for end-sem external exam.'),
                            _buildRegulationPoint(context, '4. Program Credits', '160 total credits required to graduate with an engineering degree.'),
                            _buildRegulationPoint(context, '5. Mandatory Internships', 'Includes 12 compulsory credits for industry internships and research projects.'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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

  Widget _buildRegulationPoint(BuildContext context, String header, String desc) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
          ),
          const Divider(height: 12),
        ],
      ),
    );
  }
}

// --- ADMIN PUBLISH NOTICE VIEW ---
class AdminPublishNoticeView extends StatefulWidget {
  const AdminPublishNoticeView({super.key});

  @override
  State<AdminPublishNoticeView> createState() => _AdminPublishNoticeViewState();
}

class _AdminPublishNoticeViewState extends State<AdminPublishNoticeView> {
  final _titleController = TextEditingController();
  final _snippetController = TextEditingController();
  final _descController = TextEditingController();
  String _category = 'Academic';

  @override
  void dispose() {
    _titleController.dispose();
    _snippetController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submitNotice(WidgetRef ref) {
    final title = _titleController.text.trim();
    final snippet = _snippetController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty || snippet.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields before publishing.')),
      );
      return;
    }

    // 1. Post to riverpod provider
    ref.read(noticesProvider.notifier).postNotice(
          title: title,
          category: _category,
          snippet: snippet,
          description: desc,
        );

    // 2. Show simulation success dialog containing email details
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: const Icon(Icons.mark_email_read, color: Colors.green, size: 48),
          title: const Text('Notice Published & Emailed'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notice successfully posted to student dashboards! Custom email notifications have been triggered automatically.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Text(
                  'Notifications dispatched to:',
                  style: AppTypography.labelSm.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...studentDatabase.values.map((student) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_right, size: 16, color: Colors.green),
                        Text(
                          '${student.name} (${student.email})',
                          style: const TextStyle(fontSize: 12, fontFamily: 'Courier'),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Dismiss'),
            ),
          ],
        );
      },
    );

    // Reset fields
    _titleController.clear();
    _snippetController.clear();
    _descController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer(
      builder: (context, ref, child) {
        return Scaffold(
          backgroundColor: colorScheme.background,
          appBar: AppBar(
            title: const Text('Publish New Circular', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: colorScheme.surface,
            elevation: 0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? colorScheme.surface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compose Notice Detail',
                      style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Notice Title',
                        hintText: 'e.g. Mid-Term exam timetables released',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category dropdown
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: InputDecoration(
                        labelText: 'Notice Category',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: ['Academic', 'Events', 'Placement', 'Administrative'].map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _category = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Snippet (Short Summary)
                    TextField(
                      controller: _snippetController,
                      decoration: InputDecoration(
                        labelText: 'Brief Snippet / Summary',
                        hintText: 'Keep it short (1-2 sentences)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description (Full Details)
                    TextField(
                      controller: _descController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        labelText: 'Full Description',
                        hintText: 'Provide detailed announcement text, schedules, eligibility, dates, contact persons...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Publish button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _submitNotice(ref),
                        icon: const Icon(Icons.send),
                        label: const Text('Publish & Send Emails', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.secondary,
                          foregroundColor: colorScheme.onSecondary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- ADMIN STUDENT DIRECTORY VIEW ---
class AdminStudentDirectoryView extends StatefulWidget {
  const AdminStudentDirectoryView({super.key});

  @override
  State<AdminStudentDirectoryView> createState() => _AdminStudentDirectoryViewState();
}

class _AdminStudentDirectoryViewState extends State<AdminStudentDirectoryView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showStudentDetails(BuildContext context, StudentUser student) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Container(width: 48, height: 4, decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                CircleAvatar(radius: 40, backgroundImage: NetworkImage(student.avatarUrl)),
                const SizedBox(height: 12),
                Text(student.name, style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                Text(student.id, style: AppTypography.labelSm.copyWith(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 20),

                // Details Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Age', '${student.age} Years'),
                      const Divider(height: 20),
                      _buildDetailRow('Semester', student.semester),
                      const Divider(height: 20),
                      _buildDetailRow('Branch / Dept', student.department),
                      const Divider(height: 20),
                      _buildDetailRow('Overall CGPA', student.cgpa),
                      const Divider(height: 20),
                      _buildDetailRow('Last Sem Marks', student.prevSemMarks),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Family & Accommodation Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Parent Guardian', student.parentName),
                      const Divider(height: 20),
                      _buildDetailRow('Parent Contact', student.parentPhone),
                      const Divider(height: 20),
                      _buildDetailRow('Student Phone', student.phone),
                      const Divider(height: 20),
                      _buildDetailRow('Email Address', student.email),
                      const Divider(height: 20),
                      _buildDetailRow('Hostel Block', '${student.hostelBlock} · ${student.roomNo}'),
                      const Divider(height: 20),
                      _buildDetailRow('Library Card', student.libraryCard),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13), textAlign: TextAlign.right)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredStudents = studentDatabase.values.where((student) {
      final nameMatches = student.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final idMatches = student.id.toLowerCase().contains(_searchQuery.toLowerCase());
      return nameMatches || idMatches;
    }).toList();

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Student Directory', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Students',
                  hintText: 'Search by name or ST ID...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ),

            // Students List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: filteredStudents.length,
                itemBuilder: (context, index) {
                  final student = filteredStudents[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 1,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(student.avatarUrl),
                      ),
                      title: Text(student.name, style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text('${student.id} · ${student.department}', style: const TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showStudentDetails(context, student),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ADMIN PROFILE VIEW ---
class AdminProfileView extends ConsumerWidget {
  const AdminProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final admin = authState.adminUser;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('My Admin Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (admin != null) ...[
                CircleAvatar(radius: 48, backgroundImage: NetworkImage(admin.avatarUrl)),
                const SizedBox(height: 16),
                Text(admin.name, style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                Text('Admin ID: ${admin.id}', style: AppTypography.labelSm.copyWith(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 24),

                // Credentials bento card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? colorScheme.surface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      _buildProfileRow('Branch / Field', admin.branch),
                      const Divider(height: 24),
                      _buildProfileRow('Specialization / Dept', admin.dept),
                      const Divider(height: 24),
                      _buildProfileRow('Academic Qualification', admin.qualification),
                      const Divider(height: 24),
                      _buildProfileRow('Administrative Contact', admin.contact),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // Logout Action Button
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13), textAlign: TextAlign.right)),
      ],
    );
  }
}
