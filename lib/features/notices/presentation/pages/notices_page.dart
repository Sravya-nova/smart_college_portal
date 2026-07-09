import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novau/core/theme/app_typography.dart';
import 'package:novau/features/auth/presentation/providers/auth_provider.dart';
import 'package:novau/features/notices/data/models/notice.dart';
import 'package:novau/features/notices/presentation/providers/notices_provider.dart';

class NoticesPage extends ConsumerWidget {
  const NoticesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(noticesProvider);
    final filteredNotices = ref.watch(filteredNoticesProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authProvider);
    final isAdmin = authState.role == UserRole.admin;

    return Scaffold(
      backgroundColor: colorScheme.background,
      floatingActionButton: isAdmin
          ? Padding(
              padding: const EdgeInsets.only(bottom: 72), // Space for navigation bar
              child: FloatingActionButton(
                heroTag: 'notices_post_fab',
                onPressed: () => ref.read(noticesProvider.notifier).togglePostNoticeForm(true),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: const CircleBorder(),
                elevation: 6,
                child: const Icon(Icons.add, size: 28),
              ),
            )
          : null,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header & Filters
                SliverToBoxAdapter(
                  child: _buildHeader(context, ref, state),
                ),
                // Bento Grid List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final notice = filteredNotices[index];
                        final isFeatured = notice.id == '1';

                        if (isFeatured && state.selectedCategory == 'All') {
                          return _buildFeaturedNoticeCard(context, ref, notice);
                        } else {
                          return _buildStandardNoticeCard(context, ref, notice);
                        }
                      },
                      childCount: filteredNotices.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
            ),

            // Detail Modal Overlay
            if (state.selectedNoticeDetail != null)
              _buildDetailModal(context, ref, state.selectedNoticeDetail!),

            // Post Notice Form Modal Overlay
            if (isAdmin && state.isPostNoticeFormOpen)
              _buildPostFormModal(context, ref),
          ],
        ),
      ),
    );
  }


  Widget _buildHeader(BuildContext context, WidgetRef ref, NoticesState state) {
    final categories = ['All', 'Academic', 'Events', 'Placement', 'Administrative'];
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notice Board',
            style: AppTypography.headlineLgMobile.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Stay updated with the latest institutional announcements, academic schedules, and campus events.',
            style: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          // Category chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: categories.map((category) {
                final isSelected = state.selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(noticesProvider.notifier).setCategory(category);
                    },
                    selectedColor: colorScheme.primary,
                    disabledColor: isDark ? colorScheme.surfaceVariant : const Color(0xFFF1F5F9),
                    backgroundColor: isDark ? colorScheme.surfaceVariant : const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide.none,
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedNoticeCard(BuildContext context, WidgetRef ref, Notice notice) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              offset: const Offset(0, 4),
              blurRadius: 16,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notice Image banner
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Image.network(
                notice.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: colorScheme.surfaceVariant,
                  child: Icon(Icons.broken_image, color: colorScheme.outline, size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          notice.category.toUpperCase(),
                          style: AppTypography.labelSm.copyWith(
                            color: colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Text(
                        'Featured',
                        style: AppTypography.labelSm.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    notice.title,
                    style: AppTypography.titleLarge.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notice.snippet,
                    style: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          ref.read(noticesProvider.notifier).openNoticeDetail(notice);
                        },
                        child: Row(
                          children: [
                            Text(
                              'Read Details',
                              style: AppTypography.labelMd.copyWith(color: colorScheme.secondary, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward, color: colorScheme.secondary, size: 16),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardNoticeCard(BuildContext context, WidgetRef ref, Notice notice) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color tagColor = colorScheme.secondaryContainer;
    Color textColor = colorScheme.onSecondaryContainer;

    if (notice.category.toLowerCase() == 'academic') {
      tagColor = colorScheme.primaryContainer;
      textColor = colorScheme.onPrimaryContainer;
    } else if (notice.category.toLowerCase() == 'placement') {
      tagColor = colorScheme.tertiaryContainer;
      textColor = colorScheme.onTertiaryContainer;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            ref.read(noticesProvider.notifier).openNoticeDetail(notice);
          },
          child: Padding(
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
                        color: tagColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        notice.category.toUpperCase(),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'Just Now',
                      style: AppTypography.labelSm.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  notice.title,
                  style: AppTypography.titleLarge.copyWith(color: colorScheme.primary, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  notice.snippet,
                  style: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Read',
                          style: AppTypography.labelMd.copyWith(color: colorScheme.secondary, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.arrow_forward, color: colorScheme.secondary, size: 16),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailModal(BuildContext context, WidgetRef ref, Notice notice) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Semi-transparent backdrop blur
        GestureDetector(
          onTap: () => ref.read(noticesProvider.notifier).closeNoticeDetail(),
          child: Container(
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
        // Modal Sheet Card
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              decoration: BoxDecoration(
                color: isDark ? colorScheme.surface : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 10),
                    blurRadius: 30,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Header bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            notice.category.toUpperCase(),
                            style: AppTypography.labelSm.copyWith(
                              color: colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => ref.read(noticesProvider.notifier).closeNoticeDetail(),
                          icon: Icon(Icons.close, color: colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                  // Content Scroll View
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notice.title,
                            style: AppTypography.headlineLgMobile.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            notice.description,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Footer action bar
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3))),
                      color: isDark ? colorScheme.surfaceVariant : const Color(0xFFF8FAFC),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => ref.read(noticesProvider.notifier).closeNoticeDetail(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Acknowledge Notice'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Notice link copied to clipboard.')),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            side: BorderSide(color: colorScheme.outline),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          child: const Icon(Icons.share),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostFormModal(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String category = 'Academic';
    String snippet = '';
    String description = '';

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        GestureDetector(
          onTap: () => ref.read(noticesProvider.notifier).togglePostNoticeForm(false),
          child: Container(
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: isDark ? colorScheme.surface : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 10),
                    blurRadius: 30,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3))),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Post Campus Notice',
                            style: AppTypography.titleLarge.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () => ref.read(noticesProvider.notifier).togglePostNoticeForm(false),
                            icon: Icon(Icons.close, color: colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              initialValue: category,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                              ),
                              items: ['Academic', 'Events', 'Placement', 'Administrative']
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                  .toList(),
                              onChanged: (val) => category = val ?? 'Academic',
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Notice Title',
                                border: OutlineInputBorder(),
                                hintText: 'Enter short descriptive title',
                              ),
                              validator: (val) => val == null || val.isEmpty ? 'Title is required' : null,
                              onSaved: (val) => title = val ?? '',
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Summary Snippet',
                                border: OutlineInputBorder(),
                                hintText: 'Enter brief one-sentence preview',
                              ),
                              validator: (val) => val == null || val.isEmpty ? 'Snippet is required' : null,
                              onSaved: (val) => snippet = val ?? '',
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              maxLines: 5,
                              decoration: const InputDecoration(
                                labelText: 'Detailed Description',
                                border: OutlineInputBorder(),
                                hintText: 'Write all necessary information regarding the notice...',
                              ),
                              validator: (val) => val == null || val.isEmpty ? 'Description is required' : null,
                              onSaved: (val) => description = val ?? '',
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3))),
                        color: isDark ? colorScheme.surfaceVariant : const Color(0xFFF8FAFC),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => ref.read(noticesProvider.notifier).togglePostNoticeForm(false),
                            child: Text('Cancel', style: TextStyle(color: colorScheme.outline)),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                formKey.currentState!.save();
                                ref.read(noticesProvider.notifier).postNotice(
                                      title: title,
                                      category: category,
                                      snippet: snippet,
                                      description: description,
                                    );
                                ref.read(noticesProvider.notifier).togglePostNoticeForm(false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Notice posted successfully!')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            ),
                            child: const Text('Post Announcement'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
