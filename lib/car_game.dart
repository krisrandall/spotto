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
  
  // Viewport properties
  static const viewportMinX = 350.0;
  static const viewportMaxX = 650.0;
  static const viewportMinY = 0.0;
  static const viewportMaxY = 500.0;
  
  // Car speed (pixels per second)
  static const carSpeed = 50.0;
  
  // Game state
  final List<Car> cars = [];
  final Random random = Random();
  final GameScore gameScore = GameScore();
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Set up camera to view our 1000x1000 world
    camera.viewfinder.visibleGameSize = Vector2(worldWidth, worldHeight);
    camera.viewfinder.zoom = 1.0;
    camera.moveTo(Vector2(worldWidth / 2, worldHeight / 2));
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
    
    // Update all cars' positions and remove those that have reached the end
    List<Car> carsToRemove = [];
    
    for (final car in cars) {
      // Move the car forward (increasing Y)
      car.worldPosition.y += carSpeed * dt;
      
      // Check if car has reached the end of the world
      if (car.worldPosition.y >= worldHeight) {
        carsToRemove.add(car);
      } else {
        // Update the visual representation of the car
        updateCarProjection(car);
      }
    }
    
    // Remove cars that have reached the end
    for (final car in carsToRemove) {
      car.removeFromParent();
      cars.remove(car);
    }
  }
  
  void _addRandomCar() async {
    // Generate random X position within the viewport range, Y always starts at 0
    final x = viewportMinX + random.nextDouble() * (viewportMaxX - viewportMinX);
    final y = 0.0; // Cars always start at the horizon
    
    // Choose a random car type
    final carTypes = CarType.values;
    final randomType = carTypes[random.nextInt(carTypes.length)];
    
    // Create a new car with world position
    final worldPosition = Vector2(x, y);
    final car = Car(
      position: worldPosition.clone(), // Initial screen position matches world position
      size: Vector2(50, 30),
      carType: randomType,
    );
    
    // Add to our list and to the game
    cars.add(car);
    add(car);
    
    // Immediately update its projection
    updateCarProjection(car);
  }
  
  void updateCarProjection(Car car) {
    // In our world coordinates:
    // - Higher Y values = closer to the viewer (bottom of screen)
    // - Lower Y values = further from viewer (top of screen/horizon)
    
    // Skip cars outside our viewport
    if (car.worldPosition.x < viewportMinX || car.worldPosition.x > viewportMaxX || 
        car.worldPosition.y < viewportMinY || car.worldPosition.y > viewportMaxY) {
      car.isVisible = false;
      return;
    }
    
    car.isVisible = true;
    
    // Calculate perspective values more explicitly
    // closeness: 0.0 = furthest away (at horizon), 1.0 = closest to viewer
    final closeness = car.worldPosition.y / viewportMaxY;
    
    // Convert world X to screen X with perspective
    // - Objects in center stay in center
    // - Objects off-center appear more centered as they get further away
    final screenWidth = size.x;
    final worldCenterX = worldWidth / 2;
    final screenCenterX = screenWidth / 2;
    final xOffsetFromCenter = car.worldPosition.x - worldCenterX;
    // Apply less horizontal offset for distant objects (perspective narrowing)
    final perspectiveAdjustedX = screenCenterX + xOffsetFromCenter * closeness;
    
    // Convert world Y to screen Y with perspective
    // - High Y in world (close) = low Y on screen (bottom)
    // - Low Y in world (far) = high Y on screen (top/horizon)
    final screenHeight = size.y;
    final horizonPosition = screenHeight * 0.4; // Horizon at 20% from top
    final groundPosition = screenHeight * 0.6; // Ground at 90% from top (10% from bottom)
    // Map world Y (0->500) to screen Y (horizon->ground)
    final screenY = horizonPosition + (groundPosition - horizonPosition) * closeness;
    
    // Apply position
    car.position = Vector2(perspectiveAdjustedX, screenY);
    
    // Scale based on distance - closer objects are larger
    // Min scale = 0.2, Max scale = 1.0
    final baseScale = 0.2;
    final scaleRange = 0.8;
    final scale = baseScale + (scaleRange * closeness);
    car.scale = Vector2.all(scale);
    
    // Ensure closer objects render in front of distant objects
    // Higher priority = rendered on top
    car.priority = (1000 * closeness).toInt();
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