import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/widgets/subject_sheet.dart';

/// Opens a brand-new chat. Without [subject] the subject sheet is shown
/// first. [prefill] is placed in the composer (not sent).
Future<void> startNewChat(
  BuildContext context, {
  String? subject,
  List<String> recents = const [],
  String? prefill,
}) async {
  final chosen = subject ?? await SubjectSheet.show(context, recents: recents);
  if (chosen == null || !context.mounted) return;
  openChat(context, const Uuid().v4(), subject: chosen, prefill: prefill);
}

/// Opens an existing (or new) chat by id.
void openChat(
  BuildContext context,
  String chatId, {
  String? subject,
  String? prefill,
}) {
  final query =
      subject == null ? '' : '?subject=${Uri.encodeQueryComponent(subject)}';
  context.push('/chat/$chatId$query', extra: prefill);
}
