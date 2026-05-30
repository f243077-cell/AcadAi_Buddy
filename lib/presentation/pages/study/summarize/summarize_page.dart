// lib/presentation/pages/study/summarize/summarize_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../application/summarize/summarize_notifier.dart';
import '../../../../application/summarize/summarize.dart';

// ── Base colors ──────────────────────────────────────────────────────────────
const _bg = Color(0xFF0D1B2A);
const _accent = Color(0xFFF4C430);
const _card = Color(0xFF162336);
const _surface = Color(0xFF1E2F45);

// ── Pre-declared opacity variants (no withOpacity anywhere) ──────────────────
const _accent08 = Color(0x14F4C430); // accent  8%
const _accent10 = Color(0x1AF4C430); // accent 10%
const _accent15 = Color(0x26F4C430); // accent 15%
const _accent20 = Color(0x33F4C430); // accent 20%
const _accent30 = Color(0x4DF4C430); // accent 30%
const _accent35 = Color(0x59F4C430); // accent 35%
const _accent40 = Color(0x66F4C430); // accent 40%
const _accent90 = Color(0xE6F4C430); // accent 90%
const _white08 = Color(0x14FFFFFF); // white   8%
const _white15 = Color(0x26FFFFFF); // white  15%
const _white25 = Color(0x40FFFFFF); // white  25%
const _white30 = Color(0x4DFFFFFF); // white  30%
const _white45 = Color(0x73FFFFFF); // white  45%
const _white55 = Color(0x8CFFFFFF); // white  55%
const _white70 = Color(0xB3FFFFFF); // white  70%
const _white75 = Color(0xBFFFFFFF); // white  75%
const _black25 = Color(0x40000000); // black  25%

// ── Page ─────────────────────────────────────────────────────────────────────
class SummarizePage extends ConsumerStatefulWidget {
  const SummarizePage({super.key});

  @override
  ConsumerState<SummarizePage> createState() => _SummarizePageState();
}

class _SummarizePageState extends ConsumerState<SummarizePage> {
  final _controller = TextEditingController();
  final _picker = ImagePicker();

  late final _notifier = ref.read(summarizeNotifierProvider.notifier);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (!mounted) return;
    _notifier.summarizeImage(bytes);
  }

  void _summarizeText() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _notifier.summarizeText(text);
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: _accent, size: 18),
            SizedBox(width: 10),
            Text('Copied!',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: _surface,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(summarizeNotifierProvider);

    var child2 = switch (state) {
      SummarizeInitial() => _InputScreen(
          key: const ValueKey('input'),
          controller: _controller,
          onSummarizeText: _summarizeText,
          onPickImage: _pickImage,
        ),
      SummarizeLoading() => const _LoadingScreen(key: ValueKey('loading')),
      SummarizeLoaded(:final summary) => _ResultScreen(
          key: const ValueKey('result'),
          summary: summary,
          onCopy: _copyToClipboard,
          onReset: () {
            _controller.clear();
            _notifier.reset();
          },
        ),
      SummarizeFailure(:final error) => _FailureScreen(
          key: const ValueKey('failure'),
          error: error,
          onRetry: _notifier.reset,
        ),
      SummarizeState() => throw UnimplementedError(),
    };
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _accent),
          onPressed: () {
            _notifier.reset();
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Summarize Notes 📄',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.04),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        ),
        child: child2,
      ),
    );
  }
}

// ── Input Screen ─────────────────────────────────────────────────────────────
class _InputScreen extends StatefulWidget {
  const _InputScreen({
    super.key,
    required this.controller,
    required this.onSummarizeText,
    required this.onPickImage,
  });

  final TextEditingController controller;
  final VoidCallback onSummarizeText;
  final VoidCallback onPickImage;

  @override
  State<_InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<_InputScreen> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _hasText = widget.controller.text.trim().isNotEmpty;
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hint banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _accent08,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _accent20),
            ),
            child: const Row(
              children: [
                Text('💡', style: TextStyle(fontSize: 18)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Paste your notes or upload an image — AcadAI will distill it into a clear summary.',
                    style:
                        TextStyle(color: _white70, fontSize: 13, height: 1.5),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Text input
          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _accent20),
            ),
            child: TextField(
              controller: widget.controller,
              maxLines: 8,
              minLines: 6,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, height: 1.6),
              decoration: const InputDecoration(
                hintText: 'Paste your notes here...',
                hintStyle: TextStyle(color: _white30, fontSize: 15),
                contentPadding: EdgeInsets.all(18),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // OR divider
          const Row(
            children: [
              Expanded(child: Divider(color: _white15, height: 1)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(
                      color: _white45,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5),
                ),
              ),
              Expanded(child: Divider(color: _white15, height: 1)),
            ],
          ),

          const SizedBox(height: 20),

          // Upload image button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: widget.onPickImage,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: _white25, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon:
                  const Icon(Icons.image_outlined, color: _accent90, size: 22),
              label: const Text(
                'Upload Notes Image',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    letterSpacing: 0.3),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Summarize button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _hasText ? widget.onSummarizeText : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: _bg,
                disabledBackgroundColor: _card,
                disabledForegroundColor: _white30,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: _hasText ? 6 : 0,
                shadowColor: _accent40,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Summarize',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Loading Screen ────────────────────────────────────────────────────────────
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _accent, strokeWidth: 3),
            SizedBox(height: 20),
            Text(
              'AcadAI is reading your notes... 🤖',
              style: TextStyle(
                  color: Colors.white70, fontSize: 16, letterSpacing: 0.3),
            ),
          ],
        ),
      );
}

// ── Result Screen ─────────────────────────────────────────────────────────────
class _ResultScreen extends StatelessWidget {
  const _ResultScreen({
    super.key,
    required this.summary,
    required this.onCopy,
    required this.onReset,
  });

  final String summary;
  final ValueChanged<String> onCopy;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary label chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _accent15,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: _accent30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('✨', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 6),
                      Text(
                        'Summary',
                        style: TextStyle(
                            color: _accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Summary content card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _accent15),
                    boxShadow: const [
                      BoxShadow(
                          color: _black25,
                          blurRadius: 12,
                          offset: Offset(0, 4)),
                    ],
                  ),
                  child: MarkdownBody(
                    data: summary,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                          color: Colors.white, fontSize: 15, height: 1.65),
                      h1: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.5),
                      h2: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.5),
                      h3: const TextStyle(
                          color: _accent90,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.5),
                      strong: const TextStyle(
                          color: _accent, fontWeight: FontWeight.w700),
                      em: const TextStyle(
                          color: _white75, fontStyle: FontStyle.italic),
                      code: const TextStyle(
                          color: _accent,
                          backgroundColor: _accent10,
                          fontSize: 13,
                          fontFamily: 'monospace'),
                      codeblockDecoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      blockquoteDecoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(color: _accent35, width: 3),
                        ),
                      ),
                      listBullet: const TextStyle(color: _accent, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // Sticky bottom action bar
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: const BoxDecoration(
            color: _bg,
            border: Border(top: BorderSide(color: _white08)),
          ),
          child: Row(
            children: [
              // Copy button
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => onCopy(summary),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: _accent40, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.content_copy_rounded,
                        size: 17, color: _accent),
                    label: const Text('Copy',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Summarize Again button
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: onReset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: _bg,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                      shadowColor: _accent35,
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text(
                      'Summarize Again',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 0.3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Failure Screen ────────────────────────────────────────────────────────────
class _FailureScreen extends StatelessWidget {
  const _FailureScreen({super.key, required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 16),
              const Text(
                'Summarization failed',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Text(
                error,
                style:
                    const TextStyle(color: _white55, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: _bg,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                  shadowColor: _accent40,
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      );
}
