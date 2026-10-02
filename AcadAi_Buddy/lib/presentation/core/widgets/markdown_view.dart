import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;

import '../theme.dart';
import 'app_snack.dart';

/// Markdown renderer for AI answers and summaries: GitHub-flavoured
/// Markdown, LaTeX ($…$, $$…$$, \(…\), \[…\]), code blocks with a language
/// label and Copy, and horizontally scrolling tables.
class MarkdownView extends StatelessWidget {
  const MarkdownView({super.key, required this.data, this.baseStyle});

  final String data;
  final TextStyle? baseStyle;

  @override
  Widget build(BuildContext context) {
    final body = baseStyle ?? AppText.bodyL;
    return MarkdownBody(
      data: data,
      extensionSet: md.ExtensionSet.gitHubFlavored,
      inlineSyntaxes: [
        _MathSyntax(r'\$\$([\s\S]+?)\$\$', display: true),
        _MathSyntax(r'\\\[([\s\S]+?)\\\]', display: true),
        _MathSyntax(r'\\\((.+?)\\\)', display: false),
        _MathSyntax(r'\$(?![\s$])((?:[^$\n\\]|\\.)+?)(?<!\s)\$(?!\d)',
            display: false),
      ],
      builders: {
        'pre': _CodeBlockBuilder(),
        'math': _MathBuilder(display: false),
        'mathblock': _MathBuilder(display: true),
      },
      styleSheet: markdownStyleSheet(body),
    );
  }
}

MarkdownStyleSheet markdownStyleSheet(TextStyle body) {
  final secondary = body.copyWith(color: AppColors.textSecondary);
  return MarkdownStyleSheet(
    p: body,
    pPadding: EdgeInsets.zero,
    h1: AppText.titleM,
    h1Padding: const EdgeInsets.only(top: AppSpacing.sm),
    h2: AppText.titleS,
    h2Padding: const EdgeInsets.only(top: AppSpacing.sm),
    h3: AppText.titleS,
    h4: AppText.titleS,
    h5: AppText.label,
    h6: AppText.label,
    strong: body.copyWith(fontWeight: FontWeight.w600),
    em: body.copyWith(fontStyle: FontStyle.italic),
    a: body.copyWith(
      color: AppColors.accent,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.accent,
    ),
    code: AppText.code.copyWith(
      backgroundColor: AppColors.surfaceAlt,
      color: AppColors.accent,
    ),
    blockSpacing: AppSpacing.md,
    listIndent: AppSpacing.xxl,
    listBullet: body.copyWith(color: AppColors.textSecondary),
    listBulletPadding: const EdgeInsets.only(right: AppSpacing.xs),
    blockquote: secondary,
    blockquotePadding: const EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.xs, AppSpacing.xs, AppSpacing.xs),
    blockquoteDecoration: const BoxDecoration(
      border: Border(left: BorderSide(color: AppColors.accent, width: 3)),
    ),
    tableHead: AppText.label,
    tableBody: AppText.bodyM,
    tableBorder: TableBorder.all(color: AppColors.border),
    tableCellsPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
    tableColumnWidth: const IntrinsicColumnWidth(),
    tableHeadAlign: TextAlign.left,
    horizontalRuleDecoration: const BoxDecoration(
      border: Border(top: BorderSide(color: AppColors.border)),
    ),
  );
}

class _MathSyntax extends md.InlineSyntax {
  _MathSyntax(super.pattern, {required this.display});

  final bool display;

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(
        md.Element.text(display ? 'mathblock' : 'math', match[1]!.trim()));
    return true;
  }
}

class _MathBuilder extends MarkdownElementBuilder {
  _MathBuilder({required this.display});

  final bool display;

  @override
  Widget? visitElementAfterWithContext(BuildContext context,
      md.Element element, TextStyle? preferredStyle, TextStyle? parentStyle) {
    final tex = element.textContent;
    final style = parentStyle ?? AppText.bodyL;
    final math = Math.tex(
      tex,
      mathStyle: display ? MathStyle.display : MathStyle.text,
      textStyle: style,
      onErrorFallback: (_) => Text(
        display ? '\$\$$tex\$\$' : '\$$tex\$',
        style: AppText.code,
      ),
    );
    // Long formulas scroll sideways instead of overflowing the line.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: display
          ? const EdgeInsets.symmetric(vertical: AppSpacing.sm)
          : EdgeInsets.zero,
      child: math,
    );
  }
}

class _CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  bool isBlockElement() => true;

  @override
  Widget? visitElementAfterWithContext(BuildContext context,
      md.Element element, TextStyle? preferredStyle, TextStyle? parentStyle) {
    var language = '';
    final first = element.children?.isNotEmpty == true
        ? element.children!.first
        : null;
    if (first is md.Element && first.tag == 'code') {
      final cls = first.attributes['class'];
      if (cls != null && cls.startsWith('language-')) {
        language = cls.substring('language-'.length);
      }
    }
    final code = element.textContent.replaceFirst(RegExp(r'\n$'), '');
    return CodeBlock(code: code, language: language);
  }
}

/// Fenced code block with a language label and a Copy button.
class CodeBlock extends StatelessWidget {
  const CodeBlock({super.key, required this.code, this.language = ''});

  final String code;
  final String language;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.inputAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(left: AppSpacing.md),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    language.isEmpty ? 'code' : language,
                    style: AppText.caption.copyWith(color: AppColors.textMuted),
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: code));
                    if (context.mounted) {
                      AppSnack.show(context, 'Code copied',
                          tone: SnackTone.success);
                    }
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy'),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(code, style: AppText.code),
          ),
        ],
      ),
    );
  }
}
