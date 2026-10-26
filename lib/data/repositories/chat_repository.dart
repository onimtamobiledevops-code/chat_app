import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../sources/dummy_chat_source.dart';

/// The contract the UI depends on. Add a `FirebaseChatRepository` (etc.)
/// that implements this and swap it in [chatRepositoryProvider].
abstract class ChatRepository {
  Future<List<Chat>> fetchChats();
  Future<List<User>> fetchOnlineUsers();
  Future<Message> sendMessage(String chatId, String text);
  Future<void> markAsRead(String chatId);
}

class DummyChatRepository implements ChatRepository {
  final DummyChatSource _source;

  DummyChatRepository(this._source);

  static const _latency = Duration(milliseconds: 300);

  @override
  Future<List<Chat>> fetchChats() async {
    await Future.delayed(_latency);
    return _source.chats();
  }

  @override
  Future<List<User>> fetchOnlineUsers() async {
    return DummyChatSource.users.where((u) => u.isOnline).toList();
  }

  @override
  Future<Message> sendMessage(String chatId, String text) async {
    await Future.delayed(_latency);
    return Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
      time: DateTime.now(),
      isMe: true,
      status: MessageStatus.sent,
    );
  }

  @override
  Future<void> markAsRead(String chatId) async {}
}

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => DummyChatRepository(DummyChatSource()),
);
