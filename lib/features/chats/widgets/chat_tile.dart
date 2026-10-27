import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../data/models/models.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/status_ticks.dart';

class ChatTile extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;

  const ChatTile({super.key, required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final last = chat.lastMessage;
    final hasUnread = chat.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Hero(
              tag: 'avatar-${chat.user.id}',
              child: Avatar(user: chat.user),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        formatChatTime(last.time),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: hasUnread
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: hasUnread
                              ? Theme.of(context).colorScheme.primary
                              : context.subtext,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (last.isMe && !chat.isTyping) ...[
                        StatusTicks(status: last.status),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          chat.isTyping ? 'typing…' : last.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: chat.isTyping
                                ? FontStyle.italic
                                : FontStyle.normal,
                            color: chat.isTyping
                                ? Theme.of(context).colorScheme.primary
                                : hasUnread
                                ? Theme.of(context).colorScheme.onSurface
                                : context.subtext,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (chat.isPinned && !hasUnread)
                        Icon(
                          Icons.push_pin_rounded,
                          size: 16,
                          color: context.subtext,
                        ),
                      if (hasUnread)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          constraints: const BoxConstraints(minWidth: 22),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${chat.unreadCount}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
