import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../game/game_controller.dart';
import '../widgets/custom_action_button.dart';
import '../widgets/item_card.dart';

class ShopView extends StatefulWidget {
  final GameController controller;

  const ShopView({super.key, required this.controller});

  @override
  State<ShopView> createState() => _ShopViewState();
}

class _ShopViewState extends State<ShopView> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return SafeArea(
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6750A4), Color(0xFF381E72)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OBSTACLE SHOP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Customize the blocks you avoid!',
                      style: TextStyle(color: AppColors.secondary, fontSize: 13),
                    ),
                  ],
                ),

                // Gems Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outline.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Text('💎 ', style: TextStyle(fontSize: 16)),
                      Text(
                        '${controller.gems}',
                        style: const TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Segmented Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                _buildTab('SHAPES', 0),
                _buildTab('COLORS', 1),
                _buildTab('SKINS', 2),
                _buildTab('BULLETS', 3),
              ],
            ),
          ),

          // Scrollable Items List
          Expanded(
            child: _buildTabContent(),
          ),

          // Bottom Back Button
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CustomActionButton(
              text: 'BACK',
              isPrimary: false,
              height: 48,
              widthPercent: 0.6,
              onPressed: () => controller.switchState(GameState.mainMenu),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    final controller = widget.controller;

    switch (_selectedTab) {
      case 0: // Obstacle Shapes
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: controller.obstacleShapes.length,
          itemBuilder: (context, index) {
            final shape = controller.obstacleShapes[index];
            return ItemCard(
              title: shape.name,
              price: shape.price,
              isUnlocked: shape.unlocked,
              isActive: shape.id == controller.currentObstacleShape.id,
              iconPreview: shape,
              onTap: () => controller.buyObstacleShape(shape),
            );
          },
        );

      case 1: // Obstacle Colors
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: controller.obstacleColors.length,
          itemBuilder: (context, index) {
            final color = controller.obstacleColors[index];
            return ItemCard(
              title: color.name,
              price: color.price,
              isUnlocked: color.unlocked,
              isActive: color.id == controller.currentObstacleColor.id,
              colorPreview: color.color,
              onTap: () => controller.buyObstacleColor(color),
            );
          },
        );

      case 2: // Skins
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: controller.allSkins.length,
          itemBuilder: (context, index) {
            final skin = controller.allSkins[index];
            return ItemCard(
              title: skin.name,
              price: skin.price,
              isUnlocked: skin.unlocked,
              isActive: skin.id == controller.currentSkin.id,
              colorPreview: skin.color,
              onTap: () => controller.buySkin(skin),
            );
          },
        );

      case 3: // Bullets
        if (controller.currentLevel < 5) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 48, color: AppColors.outline),
                SizedBox(height: 12),
                Text(
                  'Bullets Unlock at Level 5',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            ItemCard(
              title: '1 Bullet',
              price: 10,
              isUnlocked: false,
              isActive: false,
              customPreview: const Text('🔫', style: TextStyle(fontSize: 28)),
              lockReason: 'In Inventory: ${controller.bullets}',
              onTap: () => controller.buyBullets(),
            ),
            if (controller.currentLevel >= 10)
              ItemCard(
                title: 'Screen Clear Bomb',
                price: 15,
                isUnlocked: false,
                isActive: false,
                customPreview: const Text('🧨', style: TextStyle(fontSize: 28)),
                lockReason: 'In Inventory: ${controller.superBullets}',
                onTap: () => controller.buySuperBullets(),
              )
            else
              const ItemCard(
                title: 'Screen Clear (Locked)',
                price: 15,
                isUnlocked: false,
                isActive: false,
                customPreview: Text('🔒', style: TextStyle(fontSize: 28)),
                lockReason: 'Unlocks at Level 10',
                onTap: _doNothing,
              ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  static void _doNothing() {}
}
