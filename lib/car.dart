
// car.dart
import 'package:flame/components.dart';

enum CarType {
  grey,
  green,
  yellow,
}

class Car extends SpriteComponent { // Updated mixin

  CarType carType;

  Car({
    required Vector2 position,
    required Vector2 size,
    required this.carType,
  }) : super(position: position, size: size);
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Load the car sprite
    // You'll need to add a car image to your assets folder
    sprite = switch (carType) {
      CarType.grey => await Sprite.load('car.png'),
      CarType.green => await Sprite.load('green.png'),
      CarType.yellow => await Sprite.load('yellow.png'),
    };
    
    // Set the anchor to the center for better positioning
    anchor = Anchor.center;
  }

}
