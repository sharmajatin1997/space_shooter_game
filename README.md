# Ultimate Space War 🚀

A premium, arcade-style space shooter game built with Flutter. Protect the galaxy from swarms of alien bugs using an evolving fighter jet! 

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

## Features 🎮

- **Evolving Spaceship**: 
  - **Base Ship**: A sleek fighter with twin cannons.
  - **Double Power (2x)**: Transforms into a medium swept-wing fighter with twin heavy cannons and twin engine flames.
  - **Triple Power (3x)**: Morphs into a massive heavy bomber with delta wings, golden armor, and three devastating cannons.
- **Dynamic Enemies (Alien Bugs)**: Detailed vector-drawn alien bugs with glowing gems, moving wings, and antennas. Difficulty scales up by increasing their HP instead of just making them impossibly fast.
- **Power-Ups**:
  - ⚡ **Double Shot**: Boosts firepower and upgrades your ship.
  - ⚡ **Triple Shot**: Ultimate firepower and a massive ship upgrade.
  - 💣 **Bomb**: Collect and store bombs. Deploy to clear the screen of all enemies!
- **Level Progression**: 5 distinct difficulty levels (Rookie, Pilot, Ace, Legend, Deity) with balanced wave progression.
- **Stunning Graphics**: Built entirely using Flutter's `CustomPaint` canvas. Zero external image assets required for enemies or the player, ensuring buttery-smooth 60+ FPS performance.

## Installation 🛠️

1. Ensure you have [Flutter](https://flutter.dev/docs/get-started/install) installed.
2. Clone this repository or download the source code.
3. Navigate to the project directory:
   ```bash
   cd space_shooter_game
   ```
4. Get dependencies:
   ```bash
   flutter pub get
   ```
5. Run the app:
   ```bash
   flutter run
   ```

## How to Play 🕹️

- **Move**: Drag your finger across the screen to move the spaceship. The ship fires automatically.
- **Collect Power-ups**: Catch the glowing items that fall from the top to upgrade your weapons.
- **Use Bombs**: If you collect a Bomb, tap the Bomb button on the top right to instantly wipe out all enemies on the screen.
- **Survive**: Don't let the alien bugs crash into your ship or pass the bottom of the screen. You have 3 lives!

## Development 💻

- **UI & Graphics**: Fully vector-based graphics rendered using `CustomPainter` (`lib/painters/painters.dart`).
- **Game Loop**: Managed within `game_screen.dart` using a `Timer` for physics and rendering.
- **Developer**: Made by Jatin Sharma.

## License 📄

This project is open-source and available for personal use.
