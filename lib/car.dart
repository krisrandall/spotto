
// car.dart
import 'package:flame/components.dart';

enum CarType {
  grey(
    frontSprite: 'car.png',
    sideSprite: 'car_side.png',
    isFroggo: false,
    isSpotto: false,
  ),
  green(
    frontSprite: 'green.png',
    sideSprite: 'green_side.png',
    isFroggo: true,
    isSpotto: false,
  ),
  yellow(
    frontSprite: 'yellow.png',
    sideSprite: 'yellow_side.png',
    isFroggo: false,
    isSpotto: true,
  );
  
  final String frontSprite;
  final String sideSprite;
  final bool isFroggo;
  final bool isSpotto;
  
  const CarType({
    required this.frontSprite,
    required this.sideSprite,
    required this.isFroggo,
    required this.isSpotto,
  });
}

class Car extends SpriteComponent {
  CarType carType;
  bool spotted = false; // New property to track if this car has been spotted
  
  Car({
    required Vector2 position,
    required Vector2 size,
    required this.carType,
  }) : super(position: position, size: size);
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Load the car sprite using the frontSprite path from CarType
    sprite = await Sprite.load(carType.frontSprite);
    
    // Set the anchor to the center for better positioning
    anchor = Anchor.center;
  }
}