import 'package:flutter/material.dart';

import '../../../domain/study/subject_catalogue.dart';
import '../subject_icons.dart';
import '../theme.dart';
import 'app_card.dart';
import 'app_text_field.dart';

/// Searchable subject picker: recents, catalogue by category, and a custom
/// subject when the search matches nothing exactly.
class SubjectSheet extends StatefulWidget {
  const SubjectSheet({super.key, this.current, this.recents = const []});

  final String? current;
  final List<String> recents;

  /// Opens the sheet; resolves to the chosen subject name, or null.
  static Future<String?> show(
    BuildContext context, {
    String? current,
    List<String> recents = const [],
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => SubjectSheet(current: current, recents: recents),
    );
  }

  @override
  State<SubjectSheet> createState() => _SubjectSheetState();
}

class _SubjectSheetState extends State<SubjectSheet> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _pick(String name) => Navigator.of(context).pop(name.trim());

  List<Subject> get _matches {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return kSubjects;
    return kSubjects
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.category.toLowerCase().contains(q) ||
            s.topics.any((t) => t.toLowerCase().contains(q)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim();
    final matches = _matches;
    final exact = q.isNotEmpty && subjectByName(q) != null;

    final children = <Widget>[];
    if (q.isEmpty && widget.recents.isNotEmpty) {
      children
        ..add(const SectionHeader(title: 'Recent'))
        ..add(const SizedBox(height: AppSpacing.sm))
        ..add(Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final r in widget.recents)
              ActionChip(
                avatar: Icon(iconForSubject(r),
                    size: 18, color: AppColors.accent),
                label: Text(r),
                onPressed: () => _pick(r),
              ),
          ],
        ))
        ..add(const SizedBox(height: AppSpacing.section));
    }

    if (q.isNotEmpty && !exact) {
      children.add(_SubjectTile(
        icon: Icons.add_rounded,
        title: 'Use "$q"',
        subtitle: 'Custom subject',
        selected: false,
        onTap: () => _pick(q),
      ));
    }

    if (q.isEmpty) {
      for (final category in kSubjectCategories) {
        children
          ..add(Padding(
            padding: const EdgeInsets.only(
                top: AppSpacing.lg, bottom: AppSpacing.xs),
            child: SectionHeader(title: category),
          ))
          ..addAll(subjectsInCategory(category).map(_tileFor));
      }
    } else {
      children.addAll(matches.map(_tileFor));
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, controller) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Choose a subject', style: AppText.titleM),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _search,
                    hint: 'Search subjects or topics',
                    prefixIcon: Icons.search_rounded,
                    textInputAction: TextInputAction.search,
                    onChanged: (v) => setState(() => _query = v),
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) {
                        _pick(subjectByName(v)?.name ?? v);
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0,
                    AppSpacing.screen, AppSpacing.xxl),
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tileFor(Subject s) => _SubjectTile(
        icon: iconForKey(s.iconKey),
        title: s.name,
        subtitle: s.category,
        selected: s.name == widget.current,
        onTap: () => _pick(s.name),
      );
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: IconBadge(icon: icon),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: AppColors.accent)
          : null,
      selected: selected,
      onTap: onTap,
    );
  }
}

/// Pill showing the current subject; tapping it opens [SubjectSheet].
class SubjectChip extends StatelessWidget {
  const SubjectChip({
    super.key,
    required this.subject,
    required this.onPressed,
  });

  final String subject;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      hint: 'Change subject',
      child: ActionChip(
        avatar: Icon(iconForSubject(subject), size: 18, color: AppColors.accent),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(subject,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.expand_more_rounded,
                size: 18, color: AppColors.textSecondary),
          ],
        ),
        onPressed: onPressed,
      ),
    );
  }
}
