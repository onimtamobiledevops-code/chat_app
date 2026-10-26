import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../auth/providers/auth_provider.dart';

/// Single source of truth for every chat and its messages.
class ChatsNotifier extends AsyncNotifier<List<Chat>> {
  @override
  Future<List<Chat>> build() async {
    // Refetch whenever the signed-in user changes; nothing to show when out.
    final repo = ref.watch(chatRepositoryProvider);
    final userId = await ref.watch(authProvider.selectAsync((u) => u?.id));
    if (userId == null) return const [];
    return repo.fetchChats();
  }

  void _updateChat(String chatId, Chat Function(Chat) update) {
    final chats = state.value;
    if (chats == null) return;
    state = AsyncData([for (final c in chats) c.id == chatId ? update(c) : c]);
  }

  /// Optimistically shows the message as "sending", then swaps in the
  /// server copy once the repository confirms it.
  Future<void> sendMessage(String chatId, String text) async {
    final pending = Message(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      text: text,
      time: DateTime.now(),
      isMe: true,
      status: MessageStatus.sending,
    );
    _updateChat(chatId, (c) => c.copyWith(messages: [...c.messages, pending]));

    final sent = await ref
        .read(chatRepositoryProvider)
        .sendMessage(chatId, text);
    _updateChat(
      chatId,
      (c) => c.copyWith(
        messages: [for (final m in c.messages) m.id == pending.id ? sent : m],
      ),
    );
  }

  Future<void> markAsRead(String chatId) async {
    _updateChat(chatId, (c) => c.copyWith(unreadCount: 0));
    await ref.read(chatRepositoryProvider).markAsRead(chatId);
  }
}

final chatsProvider = AsyncNotifierProvider<ChatsNotifier, List<Chat>>(
  ChatsNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

/// Chats filtered by the search query, pinned first, then newest first.
final filteredChatsProvider = Provider<AsyncValue<List<Chat>>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  return ref.watch(chatsProvider).whenData((chats) {
    final list = chats
        .where((c) => c.user.name.toLowerCase().contains(query))
        .toList();
    list.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.lastMessage.time.compareTo(a.lastMessage.time);
    });
    return list;
  });
});

final totalUnreadProvider = Provider<int>((ref) {
  final chats = ref.watch(chatsProvider).value ?? const [];
  return chats.fold(0, (sum, c) => sum + c.unreadCount);
});

final onlineUsersProvider = FutureProvider<List<User>>(
  (ref) => ref.watch(chatRepositoryProvider).fetchOnlineUsers(),
);
