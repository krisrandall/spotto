

import 'package:flame/components.dart';

abstract class WorldObject extends PositionComponent {

  // Store the original world position, separate from the screen position
  Vector2 worldPosition;

  WorldObject({
    required Vector2 position,
    required Vector2 size,
  }) : worldPosition = position.clone(),
       super(position: position, size: size);
}