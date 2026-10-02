import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/image_pick.dart';
import '../../../../core/theme.dart';
import '../../../../core/widgets/subject_sheet.dart';

/// Message composer: subject chip, optional image preview, attach button,
/// a 1-6 line field and a gold send button.
///
/// The field stays enabled while a reply is generating (so the keyboard
/// stays up); only sending is blocked. Enter inserts a newline.
class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.subject,
    required this.sending,
    required this.onSend,
    required this.onSubjectTap,
  });

  final TextEditingController controller;
  final String subject;
  final bool sending;
  final void Function(String text, Uint8List? image) onSend;
  final VoidCallback onSubjectTap;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final _focus = FocusNode();
  Uint8List? _image;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_rebuild);
    widget.controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(ChatComposer old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_rebuild);
      widget.controller.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    _focus.dispose();
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  bool get _canSend =>
      !widget.sending &&
      (widget.controller.text.trim().isNotEmpty || _image != null);

  Future<void> _attach() async {
    final bytes = await pickImageBytes(context);
    if (bytes != null && mounted) setState(() => _image = bytes);
  }

  void _send() {
    if (!_canSend) return;
    widget.onSend(widget.controller.text, _image);
    widget.controller.clear();
    setState(() => _image = null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(AppSpacing.chatScreen, AppSpacing.xs,
          AppSpacing.chatScreen, AppSpacing.sm),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubjectChip(subject: widget.subject, onPressed: widget.onSubjectTap),
            if (_image != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: AppRadius.inputAll,
                      child: Image.memory(_image!,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          semanticLabel: 'Image to send'),
                    ),
                    Positioned(
                      right: -16,
                      top: -16,
                      child: IconButton(
                        tooltip: 'Remove image',
                        onPressed: () => setState(() => _image = null),
                        icon: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceAlt,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(Icons.close_rounded, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Attach image',
                  onPressed: _attach,
                  icon: const Icon(Icons.add_rounded),
                ),
                Expanded(
                  child: AnimatedContainer(
                    duration: AppMotion.of(context, AppMotion.fast),
                    constraints: const BoxConstraints(minHeight: 48),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.sheetAll,
                      border: Border.all(
                        color: _focus.hasFocus
                            ? AppColors.borderStrong
                            : AppColors.border,
                      ),
                    ),
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focus,
                      minLines: 1,
                      maxLines: 6,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      textCapitalization: TextCapitalization.sentences,
                      style: AppText.bodyL,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Ask about ${widget.subject}…',
                        hintStyle:
                            AppText.bodyL.copyWith(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: Semantics(
                      button: true,
                      enabled: _canSend,
                      label: widget.sending ? 'Waiting for reply' : 'Send',
                      child: Material(
                        color: _canSend ? AppColors.accent : AppColors.surfaceAlt,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _canSend ? _send : null,
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(
                              child: widget.sending
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : Icon(
                                      Icons.arrow_upward_rounded,
                                      color: _canSend
                                          ? AppColors.onAccent
                                          : AppColors.textMuted,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
