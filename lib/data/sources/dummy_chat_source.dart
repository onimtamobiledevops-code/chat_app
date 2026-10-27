import '../models/models.dart';

/// Hardcoded sample data. Swap this for a Firebase / REST source later.
class DummyChatSource {
  final _now = DateTime.now();

  DateTime _ago({int days = 0, int hours = 0, int minutes = 0}) =>
      _now.subtract(Duration(days: days, hours: hours, minutes: minutes));

  static const users = [
    User(id: '1', name: 'Nimali Perera', isOnline: true),
    User(id: '2', name: 'Kasun Silva', isOnline: true),
    User(id: '3', name: 'Dilini Fernando'),
    User(id: '4', name: 'Ruwan Jayasinghe', isOnline: true),
    User(id: '5', name: 'Sachini Wickrama'),
    User(id: '6', name: 'Team Ballys', isOnline: true),
    User(id: '7', name: 'Amila Bandara'),
  ];

  List<Chat> chats() => [
    Chat(
      id: 'c1',
      user: users[0],
      unreadCount: 2,
      isPinned: true,
      messages: [
        Message(
          id: 'm1',
          text: 'Hi! Oyata kohomada? 😊',
          time: _ago(minutes: 42),
          isMe: false,
        ),
        Message(
          id: 'm2',
          text: 'Mama hondin, oyata?',
          time: _ago(minutes: 40),
          isMe: true,
        ),
        Message(
          id: 'm3',
          text: 'Hondai. Ada meeting eka 3.00 ta neda?',
          time: _ago(minutes: 38),
          isMe: false,
        ),
        Message(
          id: 'm4',
          text: 'Ow, 3.00 ta. Mama slides tika ready karannam.',
          time: _ago(minutes: 30),
          isMe: true,
        ),
        Message(
          id: 'm5',
          text: 'Supiri! Design eka balala feedback ekak denna puluwanda?',
          time: _ago(minutes: 5),
          isMe: false,
        ),
        Message(
          id: 'm6',
          text: 'Thanks 🙏',
          time: _ago(minutes: 4),
          isMe: false,
        ),
      ],
    ),
    Chat(
      id: 'c6',
      user: users[5],
      isPinned: true,
      isTyping: true,
      messages: [
        Message(
          id: 'm7',
          text: 'New release eka deploy kala 🚀',
          time: _ago(minutes: 20),
          isMe: false,
        ),
        Message(
          id: 'm8',
          text: 'Great work everyone!',
          time: _ago(minutes: 18),
          isMe: true,
          status: MessageStatus.delivered,
        ),
      ],
    ),
    Chat(
      id: 'c2',
      user: users[1],
      unreadCount: 5,
      messages: [
        Message(
          id: 'm9',
          text: 'Machan, match eka balanna enawada?',
          time: _ago(hours: 1),
          isMe: false,
        ),
      ],
    ),
    Chat(
      id: 'c3',
      user: users[2],
      messages: [
        Message(
          id: 'm10',
          text: 'Photos tika email kala.',
          time: _ago(hours: 3),
          isMe: true,
        ),
      ],
    ),
    Chat(
      id: 'c4',
      user: users[3],
      messages: [
        Message(
          id: 'm11',
          text: 'Ok, heta kathaa karamu.',
          time: _ago(days: 1),
          isMe: false,
        ),
      ],
    ),
    Chat(
      id: 'c5',
      user: users[4],
      messages: [
        Message(
          id: 'm12',
          text: 'Happy birthday! 🎉🎂',
          time: _ago(days: 2),
          isMe: true,
          status: MessageStatus.sent,
        ),
      ],
    ),
    Chat(
      id: 'c7',
      user: users[6],
      messages: [
        Message(
          id: 'm13',
          text: 'Invoice eka attach kara thiyenawa.',
          time: _ago(days: 5),
          isMe: false,
        ),
      ],
    ),
  ];
}
