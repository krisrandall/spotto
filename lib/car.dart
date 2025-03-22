// car.dart
import 'package:flame/components.dart';
import 'dart:ui';

import 'package:spotto/world_object.dart'; // Add this import for Canvas



enum CarType {
  grey(
    frontSprite: 'grey.png',
    sideSprite: 'car_side.png',
    isFroggo: false,
    isSpotto: false,
  ),
  purple(
    frontSprite: 'purple.png',
    sideSprite: 'purple_side.png',
    isFroggo: false,
    isSpotto: false,
  ),
  red(
    frontSprite: 'red.png',
    sideSprite: 'red_side.png',
    isFroggo: false,
    isSpotto: false,
  ),
  blue(
    frontSprite: 'blue.png',
    sideSprite: 'blue_side.png',
    isFroggo: false,
    isSpotto: false,
  ),
  pink(
    frontSprite: 'pink.png',
    sideSprite: 'pink_side.png',
    isFroggo: false,
    isSpotto: false,
  ),
  white(
    frontSprite: 'white.png',
    sideSprite: 'white_side.png',
    isFroggo: false,
    isSpotto: false,
  ),
  black(
    frontSprite: 'black.png',
    sideSprite: 'black_side.png',
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

class Car extends WorldObject {
  CarType carType;
  bool _spotted = false;
  late SpriteComponent carSprite;
  SpriteComponent? spottedOverlay;
  
  
  // Control visibility with a boolean
  bool _isVisible = true;
  
  Car({
    required Vector2 position,
    required Vector2 size,
    required this.carType,
  }) : super(position: position, size: size) {
    // Set anchor to center for the container component
    anchor = Anchor.center;
  }
  
  // Getter and setter for visibility
  bool get isVisible => _isVisible;
  set isVisible(bool value) {
    _isVisible = value;
    // When visibility changes, update the component's render state
    if (value) {
      // Make visible - ensure not removed from parent
      if (parent != null) {
        parent!.children.register();
      }
    } else {
      // Make invisible - can be achieved by not calling render
      // No direct removal needed since we'll just skip rendering
    }
  }
  
  @override
  void render(Canvas canvas) {
    // Only render if visible
    if (_isVisible) {
      super.render(canvas);
    }
  }
  
  // Getter for the spotted property
  bool get spotted => _spotted;
  
  // Setter for spotted property that adds the overlay when set to true
  set spotted(bool value) {
    if (value == true && _spotted == false) {
      _addSpottedOverlay();
    }
    _spotted = value;
  }
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Create a sprite component for the car instead of being one
    final sprite = await Sprite.load(carType.frontSprite);
    
    // Calculate the aspect ratio of the sprite to avoid distortion
    final spriteWidth = sprite.srcSize.x;
    final spriteHeight = sprite.srcSize.y;
    final aspectRatio = spriteWidth / spriteHeight;
    
    // Use the container's size but maintain sprite aspect ratio
    final spriteSize = Vector2(
      size.x, 
      size.x / aspectRatio
    );
    
    // Create car sprite component
    carSprite = SpriteComponent(
      sprite: sprite,
      size: spriteSize,
      anchor: Anchor.center,
    );
    
    // Center the sprite within the container
    carSprite.position = size / 2;
    
    // Add the car sprite as a child
    add(carSprite);
  }
  
  // Add the spotted overlay sprite
  Future<void> _addSpottedOverlay() async {
    // Load the spotted overlay sprite
    final spotSprite = await Sprite.load('spotted.png');
    
    // Create the overlay component with the same size as the car sprite
    spottedOverlay = SpriteComponent(
      sprite: spotSprite,
      size: carSprite.size,
      position: carSprite.position,
      anchor: Anchor.center,
    );
    
    // Set higher priority to render on top
    spottedOverlay!.priority = 10;
    
    // Add the overlay as a child component
    add(spottedOverlay!);
  }
}
