import 'package:flutter/material.dart';

import '../../../domain/core/failures.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_snack.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/logo_mark.dart';
import '../../core/widgets/markdown_view.dart';
import '../../core/widgets/score_ring.dart';
import '../../core/widgets/states.dart';
import '../../core/widgets/subject_sheet.dart';
import '../../core/widgets/typing_dots.dart';

/// Debug-only catalogue of the shared widgets, with a 1.0x / 1.3x text
/// scale toggle for checking layouts.
class WidgetGalleryPage extends StatefulWidget {
  const WidgetGalleryPage({super.key});

  @override
  State<WidgetGalleryPage> createState() => _WidgetGalleryPageState();
}

class _WidgetGalleryPageState extends State<WidgetGalleryPage> {
  double _scale = 1.0;
  String _subject = 'Data Structures & Algorithms';

  static const _sampleMarkdown = r'''
## Recursion
A function that calls itself. The **base case** stops it; inline math $T(n) = 2T(n/2) + n$.

$$\sum_{i=1}^{n} i = \frac{n(n+1)}{2}$$

```python
def fact(n):
    return 1 if n <= 1 else n * fact(n - 1)
```

| Case | Cost | Notes |
|------|------|-------|
| Best | O(1) | base case reached immediately |
| Worst | O(n) | one frame per call on the stack |
''';

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(_scale)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Widget gallery'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: SegmentedButton<double>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 1.0, label: Text('1.0x')),
                  ButtonSegment(value: 1.3, label: Text('1.3x')),
                ],
                selected: {_scale},
                onSelectionChanged: (s) => setState(() => _scale = s.first),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: [
            const Row(children: [
              LogoMark(),
              SizedBox(width: AppSpacing.lg),
              LogoMark(size: 64),
            ]),
            const SizedBox(height: AppSpacing.section),
            const SectionHeader(title: 'Type'),
            Text('Display 32', style: AppText.display),
            Text('Title L 24', style: AppText.titleL),
            Text('Title M 20', style: AppText.titleM),
            Text('Title S 16', style: AppText.titleS),
            Text('Body L 16', style: AppText.bodyL),
            Text('Body M 14', style: AppText.bodyM),
            Text('Label 13', style: AppText.label),
            Text('Caption 12', style: AppText.caption),
            Text('OVERLINE 11', style: AppText.overline),
            Text('code 13', style: AppText.code),
            const SizedBox(height: AppSpacing.section),
            const SectionHeader(title: 'Buttons', actionLabel: 'Action'),
            AppButton(label: 'Primary', icon: Icons.bolt_rounded, onPressed: () {}),
            const SizedBox(height: AppSpacing.md),
            AppButton(label: 'Loading', loading: true, onPressed: () {}),
            const SizedBox(height: AppSpacing.md),
            AppButton.secondary(label: 'Secondary', onPressed: () {}),
            const SizedBox(height: AppSpacing.md),
            AppButton.ghost(label: 'Ghost', onPressed: () {}),
            const SizedBox(height: AppSpacing.md),
            const AppButton(label: 'Disabled', onPressed: null),
            const SizedBox(height: AppSpacing.section),
            const SectionHeader(title: 'Fields'),
            const AppTextField(
              label: 'Email',
              hint: 'you@university.edu.pk',
              prefixIcon: Icons.mail_outline_rounded,
            ),
            const SizedBox(height: AppSpacing.md),
            const AppTextField(label: 'Password', obscure: true),
            const SizedBox(height: AppSpacing.md),
            const AppTextField(
              label: 'With error',
              errorText: 'Enter a valid email address',
            ),
            const SizedBox(height: AppSpacing.section),
            const SectionHeader(title: 'Cards'),
            AppCard(
              accentBar: true,
              onTap: () {},
              child: Row(children: [
                const IconBadge(icon: Icons.forum_rounded),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text('Card with accent bar', style: AppText.titleS)),
                const Icon(Icons.chevron_right_rounded),
              ]),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(spacing: AppSpacing.sm, children: [
              SubjectChip(
                subject: _subject,
                onPressed: () async {
                  final s = await SubjectSheet.show(context,
                      current: _subject, recents: const ['Calculus', 'Physics']);
                  if (s != null) setState(() => _subject = s);
                },
              ),
              const IconBadge(icon: Icons.check_rounded, color: AppColors.success),
              const IconBadge(icon: Icons.close_rounded, color: AppColors.error),
              const IconBadge(icon: Icons.info_outline_rounded, color: AppColors.info),
            ]),
            const SizedBox(height: AppSpacing.section),
            const SectionHeader(title: 'States'),
            const SizedBox(
              height: 260,
              child: EmptyState(
                icon: Icons.forum_rounded,
                title: 'No chats yet',
                message: 'Start a session with the tutor.',
                actionLabel: 'New chat',
              ),
            ),
            SizedBox(
              height: 280,
              child: ErrorState(failure: AiFailure.offline, onRetry: () {}),
            ),
            const SkeletonParagraph(),
            const SkeletonTile(),
            const SizedBox(height: AppSpacing.md),
            const TypingDots(),
            const SizedBox(height: AppSpacing.section),
            const Center(child: ScoreRing(score: 7, total: 10)),
            const SizedBox(height: AppSpacing.section),
            AppButton.secondary(
              label: 'Show snackbar',
              onPressed: () => AppSnack.show(context, 'Saved',
                  tone: SnackTone.success, actionLabel: 'Undo', onAction: () {}),
            ),
            const SizedBox(height: AppSpacing.section),
            const SectionHeader(title: 'Markdown'),
            const MarkdownView(data: _sampleMarkdown),
            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }
}
