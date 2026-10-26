import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/models.dart';
import '../../chats/providers/chats_provider.dart';

/// One chat, derived from [chatsProvider] so both screens stay in sync.
final chatByIdProvider = Provider.family<Chat?, String>((ref, chatId) {
  final chats = ref.watch(chatsProvider).value ?? const [];
  for (final c in chats) {
    if (c.id == chatId) return c;
  }
  return null;
});
