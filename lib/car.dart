
// car.dart
import 'package:flame/components.dart';
import 'package:flame/events.dart'; // Updated import

class Car extends SpriteComponent with TapCallbacks { // Updated mixin
  Car({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Load the car sprite
    // You'll need to add a car image to your assets folder
    sprite = await Sprite.load('car.png');
    
    // Set the anchor to the center for better positioning
    anchor = Anchor.center;
  }
  
  // Updated tap handler with modern Flame API
  @override
  void onTapDown(TapDownEvent event) {
    // Optional: Implement what happens when a car is tapped
    // For example, you could change its color or make it move
    super.onTapDown(event);
  }
}
