import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../game/game_controller.dart';
import '../widgets/custom_action_button.dart';
import '../widgets/item_card.dart';

class SettingsView extends StatefulWidget {
  final GameController controller;

  const SettingsView({super.key, required this.controller});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
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
            child: const Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CHARACTER SELECT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Customize your avatar & preferences!',
                      style: TextStyle(color: AppColors.secondary, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                _buildTab('ACTORS', 0),
                _buildTab('COLORS', 1),
                _buildTab('PREFS', 2),
              ],
            ),
          ),

          // Content
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
              fontSize: 13,
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
      case 0: // Actors
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: controller.allIcons.length,
          itemBuilder: (context, index) {
            final icon = controller.allIcons[index];
            final lockText = !icon.unlocked ? 'Unlocks at Level ${icon.unlockLevel}' : null;
            return ItemCard(
              title: icon.name,
              price: icon.price,
              isUnlocked: icon.unlocked,
              isActive: icon.id == controller.currentIcon.id,
              iconPreview: icon,
              lockReason: lockText,
              onTap: () => controller.selectActorIcon(icon),
            );
          },
        );

      case 1: // Colors
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: controller.playerColors.length,
          itemBuilder: (context, index) {
            final color = controller.playerColors[index];
            return ItemCard(
              title: color.name,
              price: color.price,
              isUnlocked: color.unlocked,
              isActive: color.id == controller.currentTheme.id,
              colorPreview: color.color,
              onTap: () => controller.selectPlayerTheme(color),
            );
          },
        );

      case 2: // Prefs
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              _buildPreferenceTile(
                title: 'MUSIC',
                icon: Icons.music_note,
                isEnabled: controller.audio.musicEnabled,
                onToggle: () => controller.toggleMusic(),
              ),
              const SizedBox(height: 16),
              _buildPreferenceTile(
                title: 'SFX SOUNDS',
                icon: Icons.volume_up,
                isEnabled: controller.audio.soundEnabled,
                onToggle: () => controller.toggleSound(),
              ),
              const SizedBox(height: 16),
              _buildPreferenceTile(
                title: 'VIBRATION / HAPTICS',
                icon: Icons.vibration,
                isEnabled: controller.audio.vibrationEnabled,
                onToggle: () => controller.toggleVibration(),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPreferenceTile({
    required String title,
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled ? AppColors.primary : AppColors.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, color: isEnabled ? AppColors.primary : AppColors.outline, size: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: isEnabled,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primaryContainer,
            onChanged: (_) => onToggle(),
          ),
        ],
      ),
    );
  }
}
