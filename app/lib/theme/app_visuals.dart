import 'package:flutter/material.dart';

abstract final class AppVisuals {
  static const textBlue = Color(0xFF245A9A);
  static const actionBlue = Color(0xFF6B9FDD);
  static const learningGreen = Color(0xFF147346);
  static const activityEmeraldLight = Color(0xFF7BE0A7);
  static const activityEmeraldDark = Color(0xFF126B40);
  static const translucentCard = Color(0xD9FFFFFF);

  static const actionButtonGradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [
      Color(0xFF173F9D),
      Color(0xFF2078C8),
      Color(0xFF39B9F2),
    ],
    stops: [0, 0.5, 1],
  );

  static const screenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFDCEFFA), Color(0xFFFFE4B5)],
  );

  static Widget screenBackground({required Widget child}) => DecoratedBox(
        decoration: const BoxDecoration(gradient: screenGradient),
        child: child,
      );
}
