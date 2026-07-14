# Tab-Survival-Android-Game
**Tap Survival** is a minimalist, fast-paced top-down endless runner built for Android. Navigate through lanes, dodge increasingly difficult obstacles, and collect gems to unlock a vast array of customizations.

![Tap Survival Logo](logo.png)

## ✨ Features

- **Dynamic Gameplay & Balanced Progression**: Difficulty scales gradually in real-time as your score increases, with obstacle speeds adjusting dynamically (+1.0 speed every 12 seconds) for a balanced play curve.
- **Material 3 Design & Aesthetics**: A premium UI experience utilizing Material Design 3 color palettes, rounded card elements, and smooth typography (`sans-serif-condensed` / `sans-serif-medium`).
- **Butter-Smooth Performance**: Dynamic frame-rate pacing locking a solid, stutter-free **60 FPS** alongside preallocated graphics allocations to prevent garbage-collection latency.
- **Android Immersive Fullscreen Mode**: Runs in Sticky Immersive fullscreen mode, hiding navigation and status bars to avoid gesture navigation overlays.
- **Power-up System**:
  - 🛡️ **Shield**: Survive a single crash (features an animated outer glow expanding ripple).
  - 🧲 **Magnet**: Attract stars and gems from a distance (10-second duration).
  - 👻 **Ghost Mode**: Become temporarily invulnerable (10-second duration).
  - 🔥 **Fever Mode**: Triggered by collecting stars; turns all obstacles into rewards!
- **Deep Customization**:
  - **Actors**: Unlock various player icons including shapes and emojis (Alien, Robot, Rocket, etc.). First 3 shapes (Square, Circle, Triangle) are free and pre-unlocked!
  - **Obstacle Shop**: Customize the look of your enemies with different shapes (Heart, Hexagon, Diamond) and colors.
  - **Skins**: Change the entire game environment (Neon City, Digital Rain, Deep Sunset).
- **Juicy Audio & Haptics**:
  - Loopable retro synthwave background music (BGM).
  - Split audio preferences menu (**MUSIC** and **SFX** toggles).
  - Tactile physical haptic tap vibrations on menu button presses.
  - Custom colored particle burst explosions on collecting items.
  - Vertical canvas slide transitions when moving between menu screens.
- **Leveling System**: Progress through levels to unlock new items and challenges.

## 🛠️ Tech Stack

- **Platform**: Android
- **Language**: Java / Kotlin
- **UI Framework**: Native Android (SurfaceView)
- **Design System**: Material Design 3 (M3)
- **Build System**: Gradle (Kotlin DSL)

## 🚀 Getting Started

### Prerequisites
- Android Studio Ladybug (or newer)
- Android SDK 35
- Minimum API Level: 24 (Android 7.0)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/adrees20222/Tab-Survival-Android-Game.git
   ```
2. Open the project in Android Studio.
3. Build and run on an emulator or a physical device.
