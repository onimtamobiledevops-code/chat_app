import 'package:flutter/material.dart';

class ChatDoodlePattern extends StatelessWidget {
  const ChatDoodlePattern({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IgnorePointer(
      child: CustomPaint(
        painter: _ChatDoodlePainter(
          primary: colorScheme.primary,
          accent: colorScheme.secondary,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _ChatDoodlePainter extends CustomPainter {
  final Color primary;
  final Color accent;

  const _ChatDoodlePainter({required this.primary, required this.accent});

  static const _icons = [
    Icons.chat_bubble_outline_rounded,
    Icons.favorite_border_rounded,
    Icons.star_outline_rounded,
    Icons.emoji_emotions_outlined,
    Icons.music_note_rounded,
    Icons.call_outlined,
    Icons.wb_sunny_outlined,
    Icons.local_cafe_outlined,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const spacingX = 94.0;
    const spacingY = 88.0;
    const iconSize = 24.0;

    final rows = (size.height / spacingY).ceil() + 1;
    final columns = (size.width / spacingX).ceil() + 1;

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        final index = (row * 3 + column * 5) % _icons.length;
        final icon = _icons[index];
        final x = column * spacingX + (row.isEven ? 14 : 52);
        final y = row * spacingY + (column.isEven ? 12 : 42);
        final color = index.isEven ? primary : accent;
        final rotation = ((row + column) % 3 - 1) * 0.12;

        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(rotation);

        final painter = TextPainter(
          text: TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(
              fontFamily: icon.fontFamily,
              package: icon.fontPackage,
              fontSize: iconSize,
              color: color.withValues(alpha: 0.14),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        painter.paint(
          canvas,
          Offset(-painter.width / 2, -painter.height / 2),
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ChatDoodlePainter oldDelegate) =>
      oldDelegate.primary != primary || oldDelegate.accent != accent;
}
