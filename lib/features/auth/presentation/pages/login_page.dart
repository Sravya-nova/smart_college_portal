import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novau/core/theme/app_typography.dart';
import 'package:novau/features/auth/presentation/providers/auth_provider.dart';
import 'package:novau/features/shell/presentation/pages/shell_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isStudent = true;
  String? _errorMessage;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final id = _idController.text.trim();
    final password = _passwordController.text.trim();

    if (id.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your Campus ID';
      });
      return;
    }

    final success = ref.read(authProvider.notifier).login(id, password);
    if (success) {
      setState(() {
        _errorMessage = null;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ShellPage()),
      );
    } else {
      setState(() {
        _errorMessage = 'Invalid ID or Role. Please check credentials.';
      });
    }
  }

  void _prefill(String id) {
    setState(() {
      _idController.text = id;
      _passwordController.text = 'password123';
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Badge Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.school_outlined, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                'Nova Campus',
                style: AppTypography.displayLg.copyWith(
                  fontSize: 32,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Bapatla Engineering College',
                style: AppTypography.labelMd.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 32),

              // Login Glass Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                      offset: const Offset(0, 10),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Sign In',
                      style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Role Tabs
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Student')),
                            selected: _isStudent,
                            onSelected: (val) {
                              setState(() {
                                _isStudent = true;
                                _idController.clear();
                                _errorMessage = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Admin/Faculty')),
                            selected: !_isStudent,
                            onSelected: (val) {
                              setState(() {
                                _isStudent = false;
                                _idController.clear();
                                _errorMessage = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Error Message
                    if (_errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: colorScheme.error, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ID Field
                    TextField(
                      controller: _idController,
                      decoration: InputDecoration(
                        labelText: _isStudent ? 'Student Roll Number' : 'Admin/Faculty ID',
                        hintText: _isStudent ? 'e.g. ST-202301' : 'e.g. AD-101',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onSubmitted: (_) => _handleLogin(),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 2,
                        ),
                        child: const Text('Log In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Prefill Quick Suggestions Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Simulation Accounts:',
                      style: AppTypography.labelSm.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (_isStudent) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildPrefillChip('ST-202301', 'Alex'),
                          _buildPrefillChip('ST-202302', 'Beatrice'),
                          _buildPrefillChip('ST-202303', 'Cassius'),
                          _buildPrefillChip('ST-202304', 'Diana'),
                          _buildPrefillChip('ST-202305', 'Ethan'),
                        ],
                      ),
                    ] else ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildPrefillChip('AD-101', 'Dr. Chen'),
                          _buildPrefillChip('AD-102', 'Dr. Jenkins'),
                          _buildPrefillChip('AD-103', 'Prof. Kumar'),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrefillChip(String id, String name) {
    final colorScheme = Theme.of(context).colorScheme;
    return ActionChip(
      label: Text('$name ($id)'),
      labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      backgroundColor: colorScheme.secondaryContainer.withValues(alpha: 0.6),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      onPressed: () => _prefill(id),
    );
  }
}
