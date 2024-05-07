import 'dart:math';

import 'package:flame/experimental.dart';
import 'package:flame/sprite.dart';
import 'package:flame/components.dart';
import 'package:provider/provider.dart';

import 'game.dart';
import 'enemy.dart';
import 'friend.dart';

import '../models/enemy_data.dart';
import '../models/friend_data.dart';
import '../models/player_data.dart';

// This component class takes care of spawning new enemy components
// randomly from top of the screen. It uses the HasGameReference mixin so that
// it can add child components.
class EnemyManager extends Component with HasGameReference<SpacescapeGame> {
  // The timer which runs the enemy spawner code at regular interval of time.
  late Timer _timer;

  late Timer friendTimer;

  // Controls for how long EnemyManager should stop spawning new enemies.
  late Timer _freezeTimer;

  // A reference to spriteSheet contains enemy sprites.
  SpriteSheet spriteSheet;

  // Holds an object of Random class to generate random numbers.
  Random random = Random();

  int tickCount = 0;

  void _spawnEntities() {
    tickCount++;
    // print(tickCount);
    if (tickCount % 6 == 0) {
      _spawnFriend();
    } else if (tickCount % 10 == 0) {
      _spawnEnemy();
    } else if (tickCount == 2) {
      _spawnEnemy();
    }
  }

  EnemyManager({required this.spriteSheet}) : super() {
    // Sets the timer to call _spawnEnemy() after every 1 second, until timer is explicitly stops.
    _timer = Timer(1, onTick: _spawnEntities, repeat: true);
    _timer.start();

    // Sets freeze time to 2 seconds. After 2 seconds spawn timers will start again.
    _freezeTimer = Timer(2, onTick: () {
      _timer.start();
    });
  }

  // Spawns a new enemy at random position at the top of the screen.
  void _spawnEnemy() {
    Vector2 initialSize = Vector2(64, 64);

    // random.nextDouble() generates a random number between 0 and 1.
    // Multiplying it by game.fixedResolution.x makes sure that the value remains between 0 and width of screen.
    double xPos = (random.nextDouble() * game.fixedResolution.x) - 150;
    Vector2 position = Vector2(xPos, 0);

    // Clamps the vector such that the enemy sprite remains within the screen.
    position.clamp(
      Vector2.zero() + initialSize / 2,
      game.fixedResolution - initialSize / 2,
    );

    // Make sure that we have a valid BuildContext before using it.
    if (game.buildContext != null) {
      // Get current score and figure out the max level of enemy that
      // can be spawned for this score.
      int currentScore =
          Provider.of<PlayerData>(game.buildContext!, listen: false)
              .currentScore;
      int maxLevel = mapScoreToMaxEnemyLevel(currentScore);

      /// Gets a random [EnemyData] object from the list.
      final enemyData = _enemyDataList.elementAt(random.nextInt(maxLevel * 4));

      Enemy enemy = Enemy(
        sprite: spriteSheet.getSpriteById(enemyData.spriteId),
        size: initialSize,
        position: position,
        enemyData: enemyData,
      );

      // Makes sure that the enemy sprite is centered.
      enemy.anchor = Anchor.center;

      // Add it to components list of game instance, instead of EnemyManager.
      // This ensures the collision detection working correctly.
      game.world.add(enemy);
    }
  }

  //Spawn a Friend at random position at the top of the screen.
  void _spawnFriend() {
    Vector2 initialSize = Vector2(64, 64);

    // random.nextDouble() generates a random number between 0 and 1.
    // Multiplying it by game.fixedResolution.x makes sure that the value remains between 0 and width of screen.
    double xPos = (random.nextDouble() * game.fixedResolution.x) - 150;
    Vector2 position = Vector2(xPos, 0);
    // Clamps the vector such that the enemy sprite remains within the screen.
    position.clamp(
      Vector2.zero() + initialSize / 2,
      game.fixedResolution - initialSize / 2,
    );

    // Make sure that we have a valid BuildContext before using it.
    if (game.buildContext != null) {
      // Get current score and figure out the max level of enemy that
      // can be spawned for this score.
      int currentScore =
          Provider.of<PlayerData>(game.buildContext!, listen: false)
              .currentScore;
      int maxLevel = mapScoreToMaxEnemyLevel(currentScore);

      /// Gets a random [FriendData] object from the list.
      final friendData =
          _friendDataList.elementAt(random.nextInt(maxLevel * 4));

      Friend friend = Friend(
        sprite: spriteSheet.getSpriteById(friendData.spriteId),
        size: initialSize,
        position: position,
        friendData: friendData,
      );

      // Makes sure that the enemy sprite is centered.
      friend.anchor = Anchor.center;

      // Add it to components list of game instance, instead of EnemyManager.
      // This ensures the collision detection working correctly.
      game.world.add(friend);
    }
  }

  // For a given score, this method returns a max level
  // of enemy that can be used for spawning.
  int mapScoreToMaxEnemyLevel(int score) {
    int level = 1;

    if (score > 1500) {
      level = 4;
    } else if (score > 500) {
      level = 3;
    } else if (score > 100) {
      level = 2;
    }

    return level;
  }

  @override
  void onMount() {
    super.onMount();
    // Start the timer as soon as current enemy manager get prepared
    // and added to the game instance.
    _timer.start();
  }

  @override
  void onRemove() {
    super.onRemove();
    // Stop the timer if current enemy manager is getting removed from the
    // game instance.
    _timer.stop();
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Update timers with delta time to make them tick.
    _timer.update(dt);
    _freezeTimer.update(dt);
  }

  // Stops and restarts the timer. Should be called
  // while restarting and exiting the game.
  void reset() {
    _timer.stop();
    _timer.start();
  }

  // Pauses spawn timer for 2 seconds when called.
  void freeze() {
    _timer.stop();
    _freezeTimer.stop();
    _freezeTimer.start();
  }

  /// A private list of all [EnemyData]s.
  static const List<EnemyData> _enemyDataList = [
    EnemyData(
      killPoint: 1,
      speed: 50,
      spriteId: 7,
      level: 1,
      hMove: false,
    ),
    EnemyData(
      killPoint: 2,
      speed: 50,
      spriteId: 9,
      level: 1,
      hMove: false,
    ),
    EnemyData(
      killPoint: 4,
      speed: 50,
      spriteId: 10,
      level: 1,
      hMove: false,
    ),
    EnemyData(
      killPoint: 4,
      speed: 50,
      spriteId: 11,
      level: 1,
      hMove: false,
    ),
    EnemyData(
      killPoint: 6,
      speed: 65,
      spriteId: 12,
      level: 2,
      hMove: false,
    ),
    EnemyData(
      killPoint: 6,
      speed: 65,
      spriteId: 13,
      level: 2,
      hMove: false,
    ),
    EnemyData(
      killPoint: 6,
      speed: 65,
      spriteId: 14,
      level: 2,
      hMove: false,
    ),
    EnemyData(
      killPoint: 6,
      speed: 65,
      spriteId: 15,
      level: 2,
      hMove: true,
    ),
    EnemyData(
      killPoint: 10,
      speed: 88,
      spriteId: 16,
      level: 3,
      hMove: false,
    ),
    EnemyData(
      killPoint: 10,
      speed: 88,
      spriteId: 17,
      level: 3,
      hMove: false,
    ),
    EnemyData(
      killPoint: 10,
      speed: 100,
      spriteId: 18,
      level: 3,
      hMove: true,
    ),
    EnemyData(
      killPoint: 10,
      speed: 100,
      spriteId: 19,
      level: 3,
      hMove: false,
    ),
    EnemyData(
      killPoint: 10,
      speed: 100,
      spriteId: 20,
      level: 4,
      hMove: false,
    ),
    EnemyData(
      killPoint: 50,
      speed: 65,
      spriteId: 21,
      level: 4,
      hMove: true,
    ),
    EnemyData(
      killPoint: 50,
      speed: 65,
      spriteId: 22,
      level: 4,
      hMove: false,
    ),
    EnemyData(
      killPoint: 50,
      speed: 65,
      spriteId: 23,
      level: 4,
      hMove: false,
    )
  ];
  // A private list of all [FriendData]s.
  static const List<FriendData> _friendDataList = [
    FriendData(
      killPoint: 1,
      speed: 50,
      spriteId: 23,
      level: 1,
      hMove: false,
    ),
    FriendData(
      killPoint: 2,
      speed: 50,
      spriteId: 9,
      level: 1,
      hMove: false,
    ),
    FriendData(
      killPoint: 4,
      speed: 50,
      spriteId: 10,
      level: 1,
      hMove: false,
    ),
    FriendData(
      killPoint: 4,
      speed: 50,
      spriteId: 11,
      level: 1,
      hMove: false,
    ),
    FriendData(
      killPoint: 6,
      speed: 65,
      spriteId: 12,
      level: 2,
      hMove: false,
    ),
    FriendData(
      killPoint: 6,
      speed: 65,
      spriteId: 13,
      level: 2,
      hMove: false,
    ),
    FriendData(
      killPoint: 6,
      speed: 65,
      spriteId: 14,
      level: 2,
      hMove: false,
    ),
    FriendData(
      killPoint: 6,
      speed: 65,
      spriteId: 15,
      level: 2,
      hMove: true,
    ),
    FriendData(
      killPoint: 10,
      speed: 88,
      spriteId: 16,
      level: 3,
      hMove: false,
    ),
    FriendData(
      killPoint: 10,
      speed: 88,
      spriteId: 17,
      level: 3,
      hMove: false,
    ),
    FriendData(
      killPoint: 10,
      speed: 100,
      spriteId: 18,
      level: 3,
      hMove: true,
    ),
    FriendData(
      killPoint: 10,
      speed: 100,
      spriteId: 19,
      level: 3,
      hMove: false,
    ),
    FriendData(
      killPoint: 10,
      speed: 100,
      spriteId: 20,
      level: 4,
      hMove: false,
    ),
    FriendData(
      killPoint: 50,
      speed: 65,
      spriteId: 21,
      level: 4,
      hMove: true,
    ),
    FriendData(
      killPoint: 50,
      speed: 65,
      spriteId: 22,
      level: 4,
      hMove: false,
    ),
    FriendData(
      killPoint: 50,
      speed: 65,
      spriteId: 23,
      level: 4,
      hMove: false,
    )
  ];
}