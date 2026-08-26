enum ActorType {
  square,
  circle,
  triangle,
  hexagon,
  diamond,
  heart,
  pentagon,
  emoji,
}

class ActorIcon {
  final String id;
  final String name;
  final ActorType type;
  final String emoji;
  final int price;
  final int unlockLevel;
  bool unlocked;

  ActorIcon({
    required this.id,
    required this.name,
    required this.type,
    this.emoji = '',
    this.price = 0,
    this.unlockLevel = 1,
    this.unlocked = false,
  });

  static List<ActorIcon> getInitialIcons(int currentLevel) {
    return [
      ActorIcon(id: 'default', name: 'Square', type: ActorType.square, unlocked: true),
      ActorIcon(id: 'circle', name: 'Circle', type: ActorType.circle, unlocked: true),
      ActorIcon(id: 'triangle', name: 'Triangle', type: ActorType.triangle, unlocked: true),
      ActorIcon(id: 'girl', name: 'Girl', type: ActorType.emoji, emoji: '👧', unlockLevel: 2, unlocked: currentLevel >= 2),
      ActorIcon(id: 'boy', name: 'Boy', type: ActorType.emoji, emoji: '👦', unlockLevel: 3, unlocked: currentLevel >= 3),
      ActorIcon(id: 'rocket', name: 'Rocket', type: ActorType.emoji, emoji: '🚀', unlockLevel: 4, unlocked: currentLevel >= 4),
      ActorIcon(id: 'alien', name: 'Alien', type: ActorType.emoji, emoji: '👾', unlockLevel: 5, unlocked: currentLevel >= 5),
      ActorIcon(id: 'robot', name: 'Robot', type: ActorType.emoji, emoji: '🤖', unlockLevel: 6, unlocked: currentLevel >= 6),
      ActorIcon(id: 'car', name: 'Car', type: ActorType.emoji, emoji: '🚗', unlockLevel: 7, unlocked: currentLevel >= 7),
      ActorIcon(id: 'gem', name: 'Gem', type: ActorType.emoji, emoji: '💎', unlockLevel: 8, unlocked: currentLevel >= 8),
      ActorIcon(id: 'crown', name: 'Crown', type: ActorType.emoji, emoji: '👑', unlockLevel: 9, unlocked: currentLevel >= 9),
      ActorIcon(id: 'cat', name: 'Cat', type: ActorType.emoji, emoji: '🐱', unlockLevel: 10, unlocked: currentLevel >= 10),
      ActorIcon(id: 'dog', name: 'Dog', type: ActorType.emoji, emoji: '🐶', unlockLevel: 11, unlocked: currentLevel >= 11),
      ActorIcon(id: 'sun', name: 'Sun', type: ActorType.emoji, emoji: '☀️', unlockLevel: 12, unlocked: currentLevel >= 12),
      ActorIcon(id: 'lion', name: 'Lion', type: ActorType.emoji, emoji: '🦁', unlockLevel: 13, unlocked: currentLevel >= 13),
      ActorIcon(id: 'tiger', name: 'Tiger', type: ActorType.emoji, emoji: '🐯', unlockLevel: 14, unlocked: currentLevel >= 14),
      ActorIcon(id: 'panda', name: 'Panda', type: ActorType.emoji, emoji: '🐼', unlockLevel: 15, unlocked: currentLevel >= 15),
      ActorIcon(id: 'koala', name: 'Koala', type: ActorType.emoji, emoji: '🐨', unlockLevel: 16, unlocked: currentLevel >= 16),
      ActorIcon(id: 'frog', name: 'Frog', type: ActorType.emoji, emoji: '🐸', unlockLevel: 17, unlocked: currentLevel >= 17),
      ActorIcon(id: 'octopus', name: 'Octopus', type: ActorType.emoji, emoji: '🐙', unlockLevel: 18, unlocked: currentLevel >= 18),
    ];
  }

  static List<ActorIcon> getObstacleShapes() {
    return [
      ActorIcon(id: 'square', name: 'Square', type: ActorType.square, price: 0, unlocked: true),
      ActorIcon(id: 'circle', name: 'Circle', type: ActorType.circle, price: 0, unlocked: true),
      ActorIcon(id: 'triangle', name: 'Triangle', type: ActorType.triangle, price: 0, unlocked: true),
      ActorIcon(id: 'hex', name: 'Hexagon', type: ActorType.hexagon, price: 50, unlocked: false),
      ActorIcon(id: 'diamond', name: 'Diamond', type: ActorType.diamond, price: 60, unlocked: false),
      ActorIcon(id: 'heart', name: 'Heart', type: ActorType.heart, price: 70, unlocked: false),
      ActorIcon(id: 'pentagon', name: 'Pentagon', type: ActorType.pentagon, price: 80, unlocked: false),
    ];
  }
}
