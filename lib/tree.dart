
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:spotto/world_object.dart';

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

class Tree extends WorldObject {

  late SpriteComponent treeSprite;

  Vector2 worldPosition;

  Tree({
    required Vector2 position,
    required Vector2 size,
  }) : worldPosition = position.clone(),
       super(position: position, size: size) {
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final treeType = TreeType.values[Random().nextInt(TreeType.values.length)];
    
    final sprite = await Sprite.load(treeType.sprite);

    final spriteWidth = sprite.srcSize.x;
    final spriteHeight = sprite.srcSize.y;
    final aspectRatio = spriteWidth / spriteHeight;

    treeSprite = SpriteComponent(
      sprite: sprite,
      size: Vector2(size.x, size.x / aspectRatio),
    );

    treeSprite.position = size / 2;
    // make the tree have its base at the bottom of the screen
    treeSprite.position.y -= size.y ;

    // add the tree to the scene
    add(treeSprite);
  }

}
