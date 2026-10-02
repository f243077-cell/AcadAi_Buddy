import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../application/quiz/quiz_state.dart';
import '../../../../application/summarize/summarize.dart';
import '../../../../application/summarize/summarize_notifier.dart';
import '../../../../domain/study/entities/study_options.dart';
import '../../../../domain/study/subject_catalogue.dart';
import '../../../core/image_pick.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_snack.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/markdown_view.dart';
import '../../../core/widgets/states.dart';
import '../chat/start_chat.dart';

enum _Mode { text, image }

/// Notes tab: summarize typed notes or a photo of notes.
class SummarizePage extends ConsumerStatefulWidget {
  const SummarizePage({super.key});

  @override
  ConsumerState<SummarizePage> createState() => _SummarizePageState();
}

class _SummarizePageState extends ConsumerState<SummarizePage> {
  final _notes = TextEditingController();
  _Mode _mode = _Mode.text;
  Uint8List? _image;
  SummaryStyle _style = SummaryStyle.keyPoints;

  SummarizeNotifier get _notifier =>
      ref.read(summarizeNotifierProvider.notifier);

  @override
  void initState() {
    super.initState();
    _notes.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  bool get _hasInput => _mode == _Mode.text
      ? _notes.text.trim().isNotEmpty
      : _image != null;

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty) {
      if (mounted) AppSnack.show(context, 'Nothing to paste');
      return;
    }
    final combined = _notes.text.isEmpty ? text : '${_notes.text}\n$text';
    final capped = combined.length > kMaxNoteLength
        ? combined.substring(0, kMaxNoteLength)
        : combined;
    _notes.value = TextEditingValue(
      text: capped,
      selection: TextSelection.collapsed(offset: capped.length),
    );
    if (combined.length > kMaxNoteLength && mounted) {
      AppSnack.show(context,
          'Notes were trimmed to $kMaxNoteLength characters.');
    }
  }

  Future<void> _pickImage() async {
    final bytes = await pickImageBytes(context);
    if (bytes != null && mounted) setState(() => _image = bytes);
  }

  void _summarize() {
    if (!_hasInput) return;
    FocusScope.of(context).unfocus();
    _notifier.summarize(
      text: _mode == _Mode.text ? _notes.text : null,
      imageBytes: _mode == _Mode.image ? _image : null,
      style: _style,
    );
  }

  void _startOver() {
    _notifier.reset();
    setState(() {
      _notes.clear();
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(summarizeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Summarize notes')),
      body: s is SummarizeLoaded
          ? _ResultView(summary: s.summary, onStartOver: _startOver)
          : _form(s),
    );
  }

  Widget _form(SummarizeState s) {
    final loading = s is SummarizeLoading;
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        SegmentedButton<_Mode>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
                value: _Mode.text,
                icon: Icon(Icons.notes_rounded),
                label: Text('Text')),
            ButtonSegment(
                value: _Mode.image,
                icon: Icon(Icons.image_outlined),
                label: Text('Image')),
          ],
          selected: {_mode},
          onSelectionChanged:
              loading ? null : (m) => setState(() => _mode = m.first),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_mode == _Mode.text) ...[
          AppTextField(
            controller: _notes,
            hint: 'Paste or type your lecture notes here…',
            minLines: 8,
            maxLines: 16,
            maxLength: kMaxNoteLength,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            textCapitalization: TextCapitalization.sentences,
            enabled: !loading,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: loading ? null : _paste,
              icon: const Icon(Icons.content_paste_rounded, size: 18),
              label: const Text('Paste'),
            ),
          ),
        ] else
          _ImageInput(
            image: _image,
            onPick: loading ? null : _pickImage,
            onRemove: loading ? null : () => setState(() => _image = null),
          ),
        const SizedBox(height: AppSpacing.lg),
        const SectionHeader(title: 'Style'),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final st in SummaryStyle.values)
              ChoiceChip(
                label: Text(st.label),
                selected: _style == st,
                onSelected: loading ? null : (_) => setState(() => _style = st),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Summarize',
          icon: Icons.auto_awesome_rounded,
          loading: loading,
          onPressed: _hasInput ? _summarize : null,
        ),
        const SizedBox(height: AppSpacing.xl),
        if (loading)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Summarizing your notes…',
                    style: AppText.caption.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: AppSpacing.md),
                const SkeletonParagraph(lines: 5),
                const SkeletonParagraph(lines: 3),
              ],
            ),
          ),
        if (s is SummarizeFailure)
          AppCard(
            borderColor: AppColors.error,
            child: ErrorState(failure: s.failure, onRetry: _summarize),
          ),
      ],
    );
  }
}

class _ImageInput extends StatelessWidget {
  const _ImageInput({
    required this.image,
    required this.onPick,
    required this.onRemove,
  });

  final Uint8List? image;
  final VoidCallback? onPick;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return AppCard(
        onTap: onPick,
        semanticLabel: 'Add a photo of your notes',
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xxxl, horizontal: AppSpacing.card),
        child: ExcludeSemantics(
          child: Column(
            children: [
              const IconBadge(icon: Icons.add_a_photo_outlined, size: 56),
              const SizedBox(height: AppSpacing.md),
              Text('Add a photo of your notes', style: AppText.titleS),
              const SizedBox(height: AppSpacing.xs),
              Text('Camera or gallery',
                  style: AppText.bodyM.copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
      );
    }
    return Stack(
      children: [
        ClipRRect(
          borderRadius: AppRadius.cardAll,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: Image.memory(
              image!,
              width: double.infinity,
              fit: BoxFit.cover,
              semanticLabel: 'Selected notes photo',
            ),
          ),
        ),
        Positioned(
          top: AppSpacing.sm,
          right: AppSpacing.sm,
          child: IconButton.filled(
            tooltip: 'Remove photo',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceAlt,
              foregroundColor: AppColors.textPrimary,
            ),
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded),
          ),
        ),
      ],
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.summary, required this.onStartOver});

  final String summary;
  final VoidCallback onStartOver;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        AppCard(
          child: SelectionArea(child: MarkdownView(data: summary)),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            ActionChip(
              avatar: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Copy'),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: summary));
                if (context.mounted) {
                  AppSnack.show(context, 'Summary copied',
                      tone: SnackTone.success);
                }
              },
            ),
            ActionChip(
              avatar: const Icon(Icons.forum_outlined, size: 18),
              label: const Text('Ask the tutor about this'),
              onPressed: () => startNewChat(
                context,
                subject: kGeneralSubject,
                prefill: 'Here is a summary of my notes. Help me understand '
                    'the hardest parts.\n\n$summary',
              ),
            ),
            ActionChip(
              avatar: const Icon(Icons.quiz_outlined, size: 18),
              label: const Text('Make a quiz from this'),
              onPressed: () => context.push(
                '/quiz/play',
                extra: QuizConfig(
                  subject: 'My notes',
                  count: 5,
                  sourceText: summary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton.ghost(
          label: 'Start over',
          icon: Icons.restart_alt_rounded,
          onPressed: onStartOver,
        ),
      ],
    );
  }
}
