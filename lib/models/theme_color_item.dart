import 'package:flutter/material.dart';

class ThemeColorItem {
  final String id;
  final String name;
  final Color color;
  final int price;
  bool unlocked;

  ThemeColorItem({
    required this.id,
    required this.name,
    required this.color,
    this.price = 0,
    this.unlocked = false,
  });

  static List<ThemeColorItem> getPlayerThemes() {
    return [
      ThemeColorItem(id: 'default', name: 'Cyan', color: const Color(0xFF00E5FF), price: 0, unlocked: true),
      ThemeColorItem(id: 'ruby', name: 'Ruby', color: const Color(0xFFFF1744), price: 50, unlocked: false),
      ThemeColorItem(id: 'gold', name: 'Gold', color: const Color(0xFFFFD600), price: 75, unlocked: false),
      ThemeColorItem(id: 'purple', name: 'Purple', color: const Color(0xFFAA00FF), price: 60, unlocked: false),
      ThemeColorItem(id: 'white', name: 'White', color: const Color(0xFFFFFFFF), price: 100, unlocked: false),
      ThemeColorItem(id: 'neon_green', name: 'Neon', color: const Color(0xFF39FF14), price: 80, unlocked: false),
    ];
  }

  static List<ThemeColorItem> getObstacleColors() {
    return [
      ThemeColorItem(id: 'danger_red', name: 'Danger Red', color: const Color(0xFFFF1744), price: 0, unlocked: true),
      ThemeColorItem(id: 'frost_blue', name: 'Frost Blue', color: const Color(0xFF1E88E5), price: 40, unlocked: false),
      ThemeColorItem(id: 'acid_green', name: 'Acid Green', color: const Color(0xFF43A047), price: 40, unlocked: false),
      ThemeColorItem(id: 'void_purple', name: 'Void Purple', color: const Color(0xFFAA00FF), price: 60, unlocked: false),
      ThemeColorItem(id: 'sunset', name: 'Sunset', color: const Color(0xFFFF5722), price: 50, unlocked: false),
    ];
  }

  static List<ThemeColorItem> getSkins() {
    return [
      ThemeColorItem(id: 'default', name: 'Classic Space', color: const Color(0xFF1C1B1F), price: 0, unlocked: true),
      ThemeColorItem(id: 'neon', name: 'Neon City', color: const Color(0xFF000000), price: 100, unlocked: false),
      ThemeColorItem(id: 'sunset_skin', name: 'Deep Sunset', color: const Color(0xFF210002), price: 150, unlocked: false),
      ThemeColorItem(id: 'matrix', name: 'Digital Rain', color: const Color(0xFF001000), price: 200, unlocked: false),
    ];
  }
}
