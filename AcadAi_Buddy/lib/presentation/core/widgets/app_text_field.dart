import 'package:flutter/material.dart';

import '../theme.dart';

/// Labelled text field with the app's input styling.
///
/// The label sits above the field; errors appear below it and are announced
/// by screen readers. With [obscure] a visibility toggle is shown.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffix,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool autofocus;
  final TextCapitalization textCapitalization;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      obscureText: widget.obscure && _hidden,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      minLines: widget.obscure ? 1 : widget.minLines,
      maxLines: widget.obscure ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      textCapitalization: widget.textCapitalization,
      style: AppText.bodyL,
      decoration: InputDecoration(
        hintText: widget.hint,
        errorText: widget.errorText,
        helperText: widget.helperText,
        errorMaxLines: 3,
        prefixIcon:
            widget.prefixIcon == null ? null : Icon(widget.prefixIcon, size: 20),
        suffixIcon: widget.obscure
            ? IconButton(
                tooltip: _hidden ? 'Show password' : 'Hide password',
                icon: Icon(_hidden
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded),
                onPressed: () => setState(() => _hidden = !_hidden),
              )
            : widget.suffix,
      ),
    );

    if (widget.label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label!,
          style: AppText.label.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        field,
      ],
    );
  }
}
