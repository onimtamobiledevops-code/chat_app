const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String formatClock(DateTime t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m ${t.hour < 12 ? 'AM' : 'PM'}';
}

String formatChatTime(DateTime t) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(t.year, t.month, t.day);
  final diff = today.difference(day).inDays;

  if (diff == 0) return formatClock(t);
  if (diff == 1) return 'Yesterday';
  if (diff < 7) return _weekdays[t.weekday - 1];
  return '${t.day}/${t.month}/${t.year % 100}';
}

String formatDayHeader(DateTime t) {
  final label = formatChatTime(t);
  return label.contains(':') ? 'Today' : label;
}
