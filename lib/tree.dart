// tree.dart
import 'package:flame/components.dart';
import 'dart:ui';

enum TreeType {
  tree1(
    sprite: 'tree1.png',
  ),
  tree2(
    sprite: 'tree2.png',
  ),
  tree3(
    sprite: 'tree3.png',
  ),
  tree4(
    sprite: 'tree4.png',
  );
  
  final String sprite;
  
  const TreeType({
    required this.sprite,
  });
}

class Tree extends PositionComponent {
  TreeType treeType;
  late SpriteComponent treeSprite;
  
  // Store the original world position, separate from the screen position
  Vector2 worldPosition;
  
  // Control visibility with a boolean
  bool _isVisible = true;
  
  Tree({
    required Vector2 position,
    required Vector2 size,
    required this.treeType,
  }) : worldPosition = position.clone(),
       super(position: position, size: size) {
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
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Create a sprite component for the tree
    final sprite = await Sprite.load(treeType.sprite);
    
    // Calculate the aspect ratio of the sprite to avoid distortion
    final spriteWidth = sprite.srcSize.x;
    final spriteHeight = sprite.srcSize.y;
    final aspectRatio = spriteWidth / spriteHeight;
    
    // Use the container's size but maintain sprite aspect ratio
    final spriteSize = Vector2(
      size.x, 
      size.x / aspectRatio
    );
    
    // Create tree sprite component
    treeSprite = SpriteComponent(
      sprite: sprite,
      size: spriteSize,
      anchor: Anchor.center,
    );
    
    // Center the sprite within the container
    treeSprite.position = size / 2;
    // make the tree have its base at the bottom of the sprite
    treeSprite.position.y -= treeSprite.size.y / 2;
    
    // Add the tree sprite as a child
    add(treeSprite);
  }
}
