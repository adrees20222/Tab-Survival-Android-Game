class FloatingTextItem {
  final String text;
  double x;
  double y;
  double alpha;
  final double vy;

  FloatingTextItem({
    required this.x,
    required this.y,
    required this.text,
    this.alpha = 1.0,
    this.vy = -2.5,
  });

  void update() {
    y += vy;
    alpha -= 0.03;
  }

  bool get isDead => alpha <= 0;
}
