import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../data/models/models.dart';
import '../../../shared/widgets/status_ticks.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final double fontSize;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  const MessageBubble({
    super.key,
    required this.message,
    this.fontSize = 15,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    const r = Radius.circular(20);
    const small = Radius.circular(6);

    final radius = BorderRadius.only(
      topLeft: isMe || isFirstInGroup ? r : small,
      bottomLeft: isMe || isLastInGroup ? r : small,
      topRight: !isMe || isFirstInGroup ? r : small,
      bottomRight: !isMe || isLastInGroup ? r : small,
    );

    final textColor = isMe
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    final metaColor = isMe ? Colors.white70 : context.subtext;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 64 : 0,
          right: isMe ? 0 : 64,
          top: isFirstInGroup ? 8 : 2,
        ),
        padding: const EdgeInsets.fromLTRB(14, 10, 12, 8),
        decoration: BoxDecoration(
          gradient: isMe
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Color.lerp(
                      Theme.of(context).colorScheme.primary,
                      Colors.black,
                      0.22,
                    )!,
                  ],
                )
              : null,
          color: isMe ? null : context.incomingBubble,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: context.isDark ? 0 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 8,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                height: 1.3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatClock(message.time),
                    style: TextStyle(color: metaColor, fontSize: 11),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 3),
                    StatusTicks(status: message.status, color: metaColor),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
