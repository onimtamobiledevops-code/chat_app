import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double markSize;
  final bool showName;

  const AppLogo({super.key, this.markSize = 40, this.showName = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: markSize,
          height: markSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(markSize * 0.28),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.14),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'asset/chat6.jpeg',
            fit: BoxFit.cover,
            semanticLabel: 'ChatWBee logo',
          ),
        ),
        if (showName) ...[
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
              children: [
                const TextSpan(text: 'Chat'),
                TextSpan(
                  text: 'W',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const TextSpan(text: 'Bee'),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
