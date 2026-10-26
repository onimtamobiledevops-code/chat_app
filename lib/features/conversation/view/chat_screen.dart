import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../core/utils/format.dart';
import '../../../data/models/models.dart';
import '../../../shared/widgets/avatar.dart';
import '../../chats/providers/chats_provider.dart';
import '../providers/conversation_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

class ChatScreen extends ConsumerWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chat = ref.watch(chatByIdProvider(chatId));
    if (chat == null) {
      return const Scaffold(body: Center(child: Text('Chat not found')));
    }

    final user = chat.user;
    final wallpaper = ref.watch(chatWallpaperProvider);
    final messageFontSize = ref.watch(messageFontSizeProvider);
    // Reversed so the list starts at the bottom (newest message).
    final reversed = chat.messages.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.surface,
        titleSpacing: 0,
        title: Row(
          children: [
            Hero(
              tag: 'avatar-${user.id}',
              child: Avatar(user: user, size: 40),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    chat.isTyping
                        ? 'typing…'
                        : user.isOnline
                            ? 'Online'
                            : 'Last seen recently',
                    style: TextStyle(
                      fontSize: 12,
                      color: user.isOnline || chat.isTyping
                          ? AppColors.accent
                          : context.subtext,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.videocam_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.call_outlined)),
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.more_vert_rounded)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: wallpaper.gradient),
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                itemCount: reversed.length,
                itemBuilder: (_, i) {
                  final m = reversed[i];
                  final Message? newer = i > 0 ? reversed[i - 1] : null;
                  final Message? older =
                      i < reversed.length - 1 ? reversed[i + 1] : null;

                  final showDay =
                      older == null || !_sameDay(older.time, m.time);
                  final first = showDay || older.isMe != m.isMe;
                  final last = newer == null ||
                      newer.isMe != m.isMe ||
                      !_sameDay(newer.time, m.time);

                  return Column(
                    children: [
                      if (showDay) _DayChip(label: formatDayHeader(m.time)),
                      MessageBubble(
                        key: ValueKey(m.id),
                        message: m,
                        fontSize: messageFontSize,
                        isFirstInGroup: first,
                        isLastInGroup: last,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          MessageInput(
            onSend: (text) =>
                ref.read(chatsProvider.notifier).sendMessage(chatId, text),
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;

  const _DayChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.subtext)),
      ),
    );
  }
}
