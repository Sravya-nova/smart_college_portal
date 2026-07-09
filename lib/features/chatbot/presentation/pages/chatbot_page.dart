import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novau/core/theme/app_colors.dart';
import 'package:novau/core/theme/app_typography.dart';
import 'package:novau/features/chatbot/presentation/providers/chatbot_provider.dart';

class ChatbotPage extends ConsumerStatefulWidget {
  const ChatbotPage({super.key});

  @override
  ConsumerState<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends ConsumerState<ChatbotPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      ref.read(chatbotProvider.notifier).sendMessage(text);
      _inputController.clear();
      _scrollToBottom();
    }
  }

  Widget _buildSuggestionChip(String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return ActionChip(
      label: Text(label),
      labelStyle: AppTypography.labelSm.copyWith(color: colorScheme.onSecondaryContainer, fontSize: 12),
      backgroundColor: colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      onPressed: () {
        ref.read(chatbotProvider.notifier).sendMessage(label);
        _scrollToBottom();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatbotProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Trigger auto-scroll on new messages
    ref.listen<ChatbotState>(chatbotProvider, (prev, next) {
      _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.psychology, color: colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nova Campus AI',
                  style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Online · Student Data Analyzed',
                      style: AppTypography.labelSm.copyWith(color: Colors.green, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear Chat',
            onPressed: () {
              ref.read(chatbotProvider.notifier).clearChat();
            },
          ),
        ],
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Chat history
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final message = state.messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Suggestion chips
          if (!state.isTyping)
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildSuggestionChip("Show today's schedule"),
                  const SizedBox(width: 8),
                  _buildSuggestionChip("Plot CGPA forecast graph"),
                  const SizedBox(width: 8),
                  _buildSuggestionChip("Tell me about BEC college placements"),
                  const SizedBox(width: 8),
                  _buildSuggestionChip("What is my CGPA?"),
                  const SizedBox(width: 8),
                  _buildSuggestionChip("Check my attendance"),
                  const SizedBox(width: 8),
                  _buildSuggestionChip("Where is my hostel room?"),
                  const SizedBox(width: 8),
                  _buildSuggestionChip("Read BEC notices"),
                ],
              ),
            ),

          // Typing indicator
          if (state.isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 8, top: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      'Nova is typing',
                      style: AppTypography.labelSm.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(width: 4),
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
            ),

          // Message input bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: 'Ask anything about your campus profile...',
                      hintStyle: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: colorScheme.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  onPressed: _sendMessage,
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  child: const Icon(Icons.send, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? colorScheme.primary
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isUser ? 16 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: AppTypography.bodyMd.copyWith(
                color: message.isUser ? colorScheme.onPrimary : colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
            if (message.isChart && message.chartData != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.chartTitle != null) ...[
                      Text(
                        message.chartTitle!,
                        style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Bar Chart Row
                    SizedBox(
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(message.chartData!.length, (barIndex) {
                          final value = message.chartData![barIndex];
                          final label = message.chartLabels != null && message.chartLabels!.length > barIndex
                              ? message.chartLabels![barIndex]
                              : "";
                          // Normalize value for height
                          final bool isCGPA = value <= 10;
                          final double maxVal = isCGPA ? 10.0 : 100.0;
                          final double heightFactor = (value / maxVal).clamp(0.1, 1.0);
                          final double barHeight = heightFactor * 65;

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                value.toString(),
                                style: TextStyle(
                                  fontSize: 9, 
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 20,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      colorScheme.primary.withValues(alpha: 0.5),
                                      colorScheme.secondary,
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                label,
                                style: TextStyle(fontSize: 9, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 10,
                  color: message.isUser
                      ? colorScheme.onPrimary.withValues(alpha: 0.6)
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
