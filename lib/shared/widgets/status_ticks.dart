import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';

class StatusTicks extends StatelessWidget {
  final MessageStatus status;
  final Color? color;

  const StatusTicks({super.key, required this.status, this.color});

  @override
  Widget build(BuildContext context) {
    final base = color ?? context.subtext;
    return Icon(
      switch (status) {
        MessageStatus.sending => Icons.schedule_rounded,
        MessageStatus.sent => Icons.done_rounded,
        _ => Icons.done_all_rounded,
      },
      size: status == MessageStatus.sending ? 13 : 16,
      color: status == MessageStatus.read ? const Color(0xFF38BDF8) : base,
    );
  }
}
