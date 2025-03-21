
// car_game.dart
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart'; // Updated import for tap events
import 'car.dart';

class CarGame extends FlameGame with TapCallbacks { // Updated mixin
  // World size properties
  static const worldWidth = 1000.0;
  static const worldHeight = 1000.0;
  
  // Game state
  final List<Car> cars = [];
  final Random random = Random();
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Set up camera to view our 1000x1000 world
    camera.viewfinder.visibleGameSize = Vector2(worldWidth, worldHeight); // Updated viewport setup
    
    // Adjust the camera's zoom so the world fits on the screen nicely
    camera.viewfinder.zoom = 0.5; // Updated zoom property
    
    // Center the camera on the world
    camera.moveTo(Vector2(worldWidth / 2, worldHeight / 2));
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // 1 in 100 chance to add a new car
    if (random.nextInt(50) == 0) {
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
    final carType = CarType.values[random.nextInt(CarType.values.length)];
    
    // Create a new car
    final car = Car(
      position: Vector2(x, y),
      size: Vector2(50, 30), // Size of the car sprite
      carType: carType,
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
}
