import 'package:intl/intl.dart';

/// "just now", "5 min ago", "3 h ago", "Yesterday", "4 days ago", "12 Mar".
String relativeTime(DateTime t, [DateTime? now]) {
  final n = now ?? DateTime.now();
  final diff = n.difference(t);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  final today = DateTime(n.year, n.month, n.day);
  final day = DateTime(t.year, t.month, t.day);
  final days = today.difference(day).inDays;
  if (days == 0) return '${diff.inHours} h ago';
  if (days == 1) return 'Yesterday';
  if (days < 7) return '$days days ago';
  if (t.year == n.year) return DateFormat('d MMM').format(t);
  return DateFormat('d MMM y').format(t);
}

/// Today / Yesterday / Earlier bucket for grouped lists.
String dayGroup(DateTime t, [DateTime? now]) {
  final n = now ?? DateTime.now();
  final today = DateTime(n.year, n.month, n.day);
  final day = DateTime(t.year, t.month, t.day);
  final days = today.difference(day).inDays;
  if (days <= 0) return 'Today';
  if (days == 1) return 'Yesterday';
  return 'Earlier';
}
