import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';

class Avatar extends StatelessWidget {
  final User user;
  final double size;
  final bool showOnline;
  final bool ring;

  const Avatar({
    super.key,
    required this.user,
    this.size = 52,
    this.showOnline = true,
    this.ring = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors
        .avatarPalette[user.id.hashCode % AppColors.avatarPalette.length];
    final dot = size * 0.28;

    Widget circle = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, Color.lerp(color, Colors.black, 0.25)!],
        ),
      ),
      child: Text(
        user.initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.36,
        ),
      ),
    );

    if (ring) {
      circle = Container(
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.primary,
            ],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: circle,
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        circle,
        if (showOnline && user.isOnline)
          Positioned(
            right: ring ? 4 : 0,
            bottom: ring ? 4 : 0,
            child: Container(
              width: dot,
              height: dot,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
