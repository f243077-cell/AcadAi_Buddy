import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

import '../../../../../domain/study/entities/chat_message.dart';
import '../../../../core/theme.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  bool get _isUser => message.role == MessageRole.user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // AI avatar — left side
          if (!_isUser) ...[
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8, bottom: 18),
              decoration: BoxDecoration(
                color: AppColors.accent.withAlpha((0.12 * 255).round()),
                shape: BoxShape.circle,
                border: const Border(
                  top: BorderSide(color: AppColors.accent, width: 1),
                ),
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 14)),
              ),
            ),
          ],

          // Bubble
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              child: GestureDetector(
                onLongPress: () => _copyToClipboard(context),
                child: Column(
                  crossAxisAlignment: _isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    // Image (if any)
                    if (message.imageUrl != null &&
                        message.imageUrl!.isNotEmpty)
                      _ImageAttachment(
                        imageUrl: message.imageUrl!,
                        isUser: _isUser,
                      ),

                    // Bubble body
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _isUser
                            ? AppColors.accent
                            : const Color(0xFF1A2B3C),
                        borderRadius: _isUser
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(4),
                              )
                            : const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                        border: _isUser
                            ? null
                            : Border.all(color: AppColors.divider),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.12 * 255).round()),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _isUser
                          ? Text(
                              message.content,
                              style: const TextStyle(
                                color: AppColors.background,
                                fontSize: 14,
                                fontFamily: 'Georgia',
                                height: 1.5,
                              ),
                            )
                          : _MarkdownContent(content: message.content),
                    ),

                    // Timestamp
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 2, right: 2),
                      child: Text(
                        _formatTimestamp(message.timestamp),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontFamily: 'Georgia',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Spacer for user messages to not sit at the very edge
          if (_isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.copy_rounded, color: AppColors.accent, size: 16),
            SizedBox(width: 8),
            Text(
              'Copied to clipboard',
              style: TextStyle(
                  color: AppColors.textPrimary, fontFamily: 'Georgia'),
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceAlt,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return DateFormat('h:mm a').format(timestamp);
    return DateFormat('MMM d, h:mm a').format(timestamp);
  }
}

// ---------------------------------------------------------------------------
// Markdown content for AI messages
// ---------------------------------------------------------------------------

class _MarkdownContent extends StatelessWidget {
  final String content;

  const _MarkdownContent({required this.content});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: content,
      selectable: false,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontFamily: 'Georgia',
          height: 1.55,
        ),
        strong: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontFamily: 'Georgia',
        ),
        em: const TextStyle(
          color: AppColors.textPrimary,
          fontStyle: FontStyle.italic,
          fontFamily: 'Georgia',
        ),
        code: const TextStyle(
          color: AppColors.accent,
          fontFamily: 'monospace',
          fontSize: 13,
          backgroundColor: Color(0xFF0D1B2A),
        ),
        codeblockDecoration: BoxDecoration(
          color: const Color(0xFF0D1B2A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        codeblockPadding: const EdgeInsets.all(12),
        blockquote: const TextStyle(
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
          fontFamily: 'Georgia',
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: AppColors.accent.withAlpha((0.5 * 255).round()),
              width: 3,
            ),
          ),
        ),
        blockquotePadding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
        h1: const TextStyle(
          color: AppColors.accent,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Georgia',
        ),
        h2: const TextStyle(
          color: AppColors.accent,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Georgia',
        ),
        h3: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          fontFamily: 'Georgia',
        ),
        listBullet: const TextStyle(
          color: AppColors.accent,
          fontFamily: 'Georgia',
        ),
        horizontalRuleDecoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
        ),
        tableHead: const TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.bold,
          fontFamily: 'Georgia',
          fontSize: 13,
        ),
        tableBody: const TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'Georgia',
          fontSize: 13,
        ),
        tableBorder: TableBorder.all(color: AppColors.divider),
        tableHeadAlign: TextAlign.center,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Image attachment
// ---------------------------------------------------------------------------

class _ImageAttachment extends StatelessWidget {
  final String imageUrl;
  final bool isUser;

  const _ImageAttachment({required this.imageUrl, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          width: 220,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 220,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 2,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 220,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image_outlined,
                      color: AppColors.textSecondary, size: 28),
                  SizedBox(height: 6),
                  Text(
                    'Image unavailable',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Georgia',
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
