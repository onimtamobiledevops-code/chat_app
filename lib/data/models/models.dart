import 'dart:typed_data';

class User {
  final String id;
  final String name;
  final bool isOnline;
  final String? email;
  final String? membershipNumber;
  final String? mobileNumber;
  final String? remarks;
  final Uint8List? photoBytes;

  const User({
    required this.id,
    required this.name,
    this.isOnline = false,
    this.email,
    this.membershipNumber,
    this.mobileNumber,
    this.remarks,
    this.photoBytes,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

class SignUpRequest {
  final String name;
  final String membershipNumber;
  final String mobileNumber;
  final String? remarks;
  final Uint8List? photoBytes;

  const SignUpRequest({
    required this.name,
    required this.membershipNumber,
    required this.mobileNumber,
    this.remarks,
    this.photoBytes,
  });
}

enum MessageStatus { sending, sent, delivered, read }

class Message {
  final String id;
  final String text;
  final DateTime time;
  final bool isMe;
  final MessageStatus status;

  const Message({
    required this.id,
    required this.text,
    required this.time,
    required this.isMe,
    this.status = MessageStatus.read,
  });

  Message copyWith({MessageStatus? status}) => Message(
    id: id,
    text: text,
    time: time,
    isMe: isMe,
    status: status ?? this.status,
  );
}

class Chat {
  final String id;
  final User user;
  final List<Message> messages;
  final int unreadCount;
  final bool isPinned;
  final bool isTyping;

  const Chat({
    required this.id,
    required this.user,
    required this.messages,
    this.unreadCount = 0,
    this.isPinned = false,
    this.isTyping = false,
  });

  Message get lastMessage => messages.last;

  Chat copyWith({
    List<Message>? messages,
    int? unreadCount,
    bool? isPinned,
    bool? isTyping,
  }) => Chat(
    id: id,
    user: user,
    messages: messages ?? this.messages,
    unreadCount: unreadCount ?? this.unreadCount,
    isPinned: isPinned ?? this.isPinned,
    isTyping: isTyping ?? this.isTyping,
  );
}
