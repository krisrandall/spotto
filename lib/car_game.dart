

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
    
    // Add UI buttons
    final screenWidth = size.x;
    final screenHeight = size.y;
    
    // Add Spotto button (left bottom)
    final spottoButton = UIButton(
      text: 'Spotto',
      position: Vector2(screenWidth * 0.25, screenHeight * 0.9),
      size: Vector2(150, 60),
      onPressed: handleSpottoPressed,
      color: Colors.yellow,
    );
    
    // Add Froggo button (right bottom)
    final froggoButton = UIButton(
      text: 'Froggo',
      position: Vector2(screenWidth * 0.75, screenHeight * 0.9),
      size: Vector2(150, 60),
      onPressed: handleFroggoPressed,
      color: Colors.green,
    );
    
    // Add score display (top left)
    final scoreDisplay = ScoreDisplay(
      position: Vector2(50, 50),
      gameScore: gameScore,
    );
    
    // Add UI components to the camera
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