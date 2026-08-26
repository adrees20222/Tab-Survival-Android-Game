import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/actor_icon.dart';
import '../../rendering/shape_renderer.dart';

class ItemCard extends StatelessWidget {
  final String title;
  final int price;
  final bool isUnlocked;
  final bool isActive;
  final Color? colorPreview;
  final ActorIcon? iconPreview;
  final Widget? customPreview;
  final String? lockReason;
  final VoidCallback onTap;

  const ItemCard({
    super.key,
    required this.title,
    required this.price,
    required this.isUnlocked,
    required this.isActive,
    required this.onTap,
    this.colorPreview,
    this.iconPreview,
    this.customPreview,
    this.lockReason,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryContainer.withValues(alpha: 0.4)
            : AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.outline.withValues(alpha: 0.3),
          width: isActive ? 2.0 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Preview Area
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Center(
                    child: _buildPreview(),
                  ),
                ),
                const SizedBox(width: 16),

                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isActive ? AppColors.primary : AppColors.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (lockReason != null)
                        Text(
                          lockReason!,
                          style: const TextStyle(
                            color: AppColors.outline,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),

                // Status Button / Badge
                _buildStatusButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (customPreview != null) return customPreview!;

    if (colorPreview != null) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colorPreview,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 2),
        ),
      );
    }

    if (iconPreview != null) {
      if (iconPreview!.type == ActorType.emoji) {
        return Text(
          iconPreview!.emoji,
          style: const TextStyle(fontSize: 32),
        );
      } else {
        return CustomPaint(
          size: const Size(36, 36),
          painter: _IconCardPainter(
            type: iconPreview!.type,
            color: AppColors.primary,
          ),
        );
      }
    }

    return const Icon(Icons.inventory_2, color: AppColors.primary);
  }

  Widget _buildStatusButton() {
    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 16, color: AppColors.onPrimary),
            SizedBox(width: 4),
            Text(
              'ACTIVE',
              style: TextStyle(
                color: AppColors.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (isUnlocked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outline),
        ),
        child: const Text(
          'EQUIP',
          style: TextStyle(
            color: AppColors.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💎 ', style: TextStyle(fontSize: 12)),
          Text(
            '$price',
            style: const TextStyle(
              color: AppColors.onPrimaryContainer,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconCardPainter extends CustomPainter {
  final ActorType type;
  final Color color;

  _IconCardPainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    ShapeRenderer.drawShape(
      canvas: canvas,
      paint: paint,
      type: type,
      x: 0,
      y: 0,
      size: size.width,
    );
  }

  @override
  bool shouldRepaint(covariant _IconCardPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.color != color;
  }
}
