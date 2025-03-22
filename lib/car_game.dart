// car_game.dart
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'car.dart';
import 'game_score.dart';
import 'ui_button.dart';
import 'score_display.dart';

class CarGame extends FlameGame with TapCallbacks {
  // World size properties
  static const worldWidth = 1000.0;
  static const worldHeight = 1000.0;
  
  // Game state
  final List<Car> cars = [];
  final Random random = Random();
  final GameScore gameScore = GameScore();
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Set up camera to view our 1000x1000 world
    camera.viewfinder.visibleGameSize = Vector2(worldWidth, worldHeight);
    
    // Adjust the camera's zoom so the world fits on the screen nicely
    camera.viewfinder.zoom = 0.5;
    
    // Center the camera on the world
    camera.moveTo(Vector2(worldWidth / 2, worldHeight / 2));
    
    // Set up responsive UI that will be added once we know the screen size
    // Adding them in onGameResize ensures they're positioned correctly
    // for the current screen size and orientation
  }
  
  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    
    // Clear any existing UI components first (for screen rotation)
    camera.viewport.children.whereType<UIButton>().forEach((button) => button.removeFromParent());
    camera.viewport.children.whereType<ScoreDisplay>().forEach((display) => display.removeFromParent());
    
    // Button dimensions based on screen size - max 30% of screen width
    final buttonWidth = canvasSize.x * 0.3; // 30% of screen width
    final buttonHeight = canvasSize.y * 0.08; // 8% of screen height
    final bottomPadding = canvasSize.y * 0.05; // 5% of screen height from bottom
    final sidePadding = canvasSize.x * 0.05; // 5% padding from sides
    
    // Add Spotto button (left bottom)
    final spottoButton = UIButton(
      text: 'Spotto',
      // Position from left edge with padding
      position: Vector2(sidePadding, canvasSize.y - buttonHeight - bottomPadding),
      size: Vector2(buttonWidth, buttonHeight),
      onPressed: handleSpottoPressed,
      color: Colors.yellow,
    );
    
    // Add Froggo button (right bottom)
    final froggoButton = UIButton(
      text: 'Froggo',
      // Position from right edge with padding
      position: Vector2(canvasSize.x - buttonWidth - sidePadding, canvasSize.y - buttonHeight - bottomPadding),
      size: Vector2(buttonWidth, buttonHeight),
      onPressed: handleFroggoPressed,
      color: Colors.green,
    );
    
    // Add score display (top left with padding)
    final scoreDisplay = ScoreDisplay(
      position: Vector2(canvasSize.x * 0.05, canvasSize.y * 0.05),
      gameScore: gameScore,
    );
    
    // Add UI components to the camera viewport
    camera.viewport.add(spottoButton);
    camera.viewport.add(froggoButton);
    camera.viewport.add(scoreDisplay);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // 1 in 100 chance to add a new car
    if (random.nextInt(100) == 0) {
      _addRandomCar();
    }
    
    // 1 in 100 chance to remove a car if there are any
    if (cars.isNotEmpty && random.nextInt(100) == 0) {
      _removeRandomCar();
    }
  }
  
  void _addRandomCar() async {
    // Generate random position within the world
    final x = random.nextDouble() * worldWidth;
    final y = random.nextDouble() * worldHeight;
    
    // Choose a random car type
    final carTypes = CarType.values;
    final randomType = carTypes[random.nextInt(carTypes.length)];
    
    // Create a new car
    final car = Car(
      position: Vector2(x, y),
      size: Vector2(50, 30),
      carType: randomType,
    );
    
    // Add to our list and to the game
    cars.add(car);
    add(car);
  }
  
  void _removeRandomCar() {
    if (cars.isEmpty) return;
    
    // Select a random car to remove
    final index = random.nextInt(cars.length);
    final car = cars[index];
    
    // Remove from both the list and the game
    cars.removeAt(index);
    car.removeFromParent();
  }
  
  void handleSpottoPressed() {
    // Find the first unspotted Spotto car
    try {
      final spottoCar = cars.firstWhere(
        (car) => car.carType.isSpotto && !car.spotted,
      );
      
      // Mark as spotted and update score for correct spotting
      spottoCar.spotted = true;
      gameScore.numCorrectSpottos++;
    } catch (e) {
      // No unspotted Spotto cars found, count as wrong
      gameScore.numWrongSpottos++;
    }
  }
  
  void handleFroggoPressed() {
    // Find the first unspotted Froggo car
    try {
      final froggoCar = cars.firstWhere(
        (car) => car.carType.isFroggo && !car.spotted,
      );
      
      // Mark as spotted and update score for correct froggo
      froggoCar.spotted = true;
      gameScore.numCorrectFroggos++;
    } catch (e) {
      // No unspotted Froggo cars found, count as wrong
      gameScore.numWrongFroggos++;
    }
  }
}