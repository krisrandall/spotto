// car_game.dart
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'car.dart';
import 'tree.dart';
import 'game_score.dart';
import 'ui_button.dart';
import 'score_display.dart';

class CarGame extends FlameGame with TapCallbacks {
  // World size properties
  static const worldWidth = 1000.0;
  static const worldHeight = 1000.0;
  
  // Viewport properties
  static const viewportMinX = 0;
  static const viewportMaxX = 1000.0;
  static const viewportMinY = 0.0;
  static const viewportMaxY = 500.0;
  
  // Car and tree speeds (pixels per second)
  static const carSpeed = 120.0;
  static const treeSpeed = 60.0; // Half the car speed
  
  // Game state
  final List<Car> cars = [];
  final List<Tree> trees = [];
  final Random random = Random();
  final GameScore gameScore = GameScore();
  
  // Background elements
  late RectangleComponent skyBackground;
  late GradientRectangleComponent roadBackground;
  late SpriteComponent windscreen;
  
  // Wrong answer indicator
  SpriteComponent? wrongIndicator;
  double wrongDisplayTime = 0;
  static const wrongDisplayDuration = 0.5; // Show for half a second

  bool hasBeenLoaded = false;
  
 @override
Future<void> onLoad() async {
  await super.onLoad();
  
  // Set up camera to view our 1000x1000 world
  camera.viewfinder.visibleGameSize = Vector2(worldWidth, worldHeight);
  camera.viewfinder.zoom = 1.0;
  camera.moveTo(Vector2(worldWidth / 2, worldHeight / 2));
  
  // Create sky background (light blue above horizon)
  skyBackground = RectangleComponent(
    position: Vector2(0, 0),
    size: Vector2(size.x, size.y * 0.3), // Horizon at 30% from top
    paint: Paint()..color = const Color(0xFF87CEEB), // Light blue
    priority: -2, // Ensure this is a very low number
  );
  
  // Create road gradient background
  roadBackground = GradientRectangleComponent(
    position: Vector2(0, size.y * 0.3), // Start at horizon line
    size: Vector2(size.x, size.y * 0.7), // Cover rest of screen
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
         Color(0xFF333333), // Dark grey
         Color(0xFFAAAAAA), // Light grey
      ],
    ),
    priority: -1, // Just above sky but still below everything else
  );
  
  // Load windscreen overlay
  final windscreenSprite = await Sprite.load('windscreen.png');
  
  // Create windscreen overlay that fills the screen
  // while maintaining aspect ratio
  final aspectRatio = windscreenSprite.srcSize.x / windscreenSprite.srcSize.y;
  Vector2 windscreenSize;
  
  // Determine if we should fit to width or height
  if (size.x / size.y > aspectRatio) {
    // Screen is wider than windscreen, fit to width
    windscreenSize = Vector2(size.x, size.x / aspectRatio);
  } else {
    // Screen is taller than windscreen, fit to height
    windscreenSize = Vector2(size.y * aspectRatio, size.y);
  }
  
  windscreen = SpriteComponent(
    sprite: windscreenSprite,
    position: Vector2(size.x / 2, size.y / 2), // Center on screen
    size: windscreenSize,
    anchor: Anchor.center,
    priority: 50, // Above cars but below UI elements
  );
  
  // Add background elements to the game world
  add(skyBackground);
  add(roadBackground);
  
  // Add windscreen to the viewport instead of game world
  camera.viewport.add(windscreen);
  
  // Pre-load the wrong indicator sprite
  await images.load('wrong.png');
  
  // Pre-load tree sprites
  await images.load('tree1.png');
  await images.load('tree2.png');
  await images.load('tree3.png');
  await images.load('tree4.png');

  
  
  // Mark that the game has been loaded
  hasBeenLoaded = true;
}

  @override
void onGameResize(Vector2 canvasSize) {
  super.onGameResize(canvasSize);
  
  // Clear any existing UI components first (for screen rotation)
  camera.viewport.children.whereType<UIButton>().forEach((button) => button.removeFromParent());
  camera.viewport.children.whereType<ScoreDisplay>().forEach((display) => display.removeFromParent());
  
  // Update background elements on resize only if they've been initialized
  if (hasBeenLoaded) {  // Add this check instead of skyBackground.isMounted
    skyBackground.size = Vector2(canvasSize.x, canvasSize.y * 0.3);
    roadBackground.position = Vector2(0, canvasSize.y * 0.3);
    roadBackground.size = Vector2(canvasSize.x, canvasSize.y * 0.7);
    
    // Update windscreen size and position
    final windscreenSprite = windscreen.sprite!;
    final aspectRatio = windscreenSprite.srcSize.x / windscreenSprite.srcSize.y;
    Vector2 windscreenSize;
    
    if (canvasSize.x / canvasSize.y > aspectRatio) {
      windscreenSize = Vector2(canvasSize.x, canvasSize.x / aspectRatio);
    } else {
      windscreenSize = Vector2(canvasSize.y * aspectRatio, canvasSize.y);
    }
    
    windscreen.size = windscreenSize;
    windscreen.position = Vector2(canvasSize.x / 2, canvasSize.y / 2);
  }
  
  // Button dimensions based on screen size - max 30% of screen width
  final buttonWidth = canvasSize.x * 0.3; // 30% of screen width
  final buttonHeight = canvasSize.y * 0.08; // 8% of screen height
  final bottomPadding = canvasSize.y * 0.05; // 5% of screen height from bottom
  final sidePadding = canvasSize.x * 0.05; // 5% padding from sides
  
// When creating UI buttons and score display
final spottoButton = UIButton(
  position: Vector2(sidePadding, canvasSize.y - buttonHeight - bottomPadding),
  size: Vector2(buttonWidth, buttonHeight),
  onPressed: handleSpottoPressed,
  spritePath: 'spotto.png',
  priority: 100, // Highest priority - UI elements on top
);

final froggoButton = UIButton(
  position: Vector2(canvasSize.x - buttonWidth - sidePadding, canvasSize.y - buttonHeight - bottomPadding),
  size: Vector2(buttonWidth, buttonHeight),
  onPressed: handleFroggoPressed,
  spritePath: 'froggo.png',
  priority: 100, // Highest priority - UI elements on top
);

final scoreDisplay = ScoreDisplay(
  position: Vector2(canvasSize.x * 0.05, canvasSize.y * 0.05),
  gameScore: gameScore,
  priority: 100, // Highest priority - UI elements on top
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
    
    // 1 in 120 chance to add a new tree (slightly less frequent than cars)
    if (random.nextInt(120) == 0) {
      _addRandomTree();
    }
    
    // Update all cars' positions and remove those that have reached the end
    List<Car> carsToRemove = [];
    
    for (final car in cars) {
      // Move the car forward (increasing Y)
      car.worldPosition.y += carSpeed * dt;
      
      // Check if car has reached the end of the world
      if (car.worldPosition.y >= worldHeight) {
        carsToRemove.add(car);
      } else if (car.worldPosition.x < viewportMinX || 
        car.worldPosition.x > viewportMaxX || 
        car.worldPosition.y < viewportMinY || 
        car.worldPosition.y > viewportMaxY) 
      {
        // this is a hack - but the AIs (and me) have no fucking idea how to 
        // make a sprite disappear properly.
        // so we'll just remove it from the list and it will be removed from the screen
        // after the current frame is rendered.
        // The whole "isVisible" logic is terrible actually - will need to be reworked 
        // when/if we add the left and right view ports 
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
    
    // Update all trees' positions and remove those that have reached the end
    List<Tree> treesToRemove = [];
    
    for (final tree in trees) {
      // Move the tree forward (increasing Y) at half the car speed
      tree.worldPosition.y += treeSpeed * dt;
      
      // Check if tree has reached the end of the world
      if (tree.worldPosition.y >= worldHeight) {
        treesToRemove.add(tree);
      } else if (tree.worldPosition.x < viewportMinX || 
        tree.worldPosition.x > viewportMaxX || 
        tree.worldPosition.y < viewportMinY || 
        tree.worldPosition.y > viewportMaxY) 
      {
        treesToRemove.add(tree);
      } else {
        // Update the visual representation of the tree
        updateTreeProjection(tree);
      }
    }
    
    // Remove trees that have reached the end
    for (final tree in treesToRemove) {
      tree.removeFromParent();
      trees.remove(tree);
    }
    
    // Update the wrong indicator if it's displayed
    if (wrongIndicator != null && wrongDisplayTime > 0) {
      wrongDisplayTime -= dt;
      if (wrongDisplayTime <= 0) {
        wrongIndicator!.removeFromParent();
        wrongIndicator = null;
      }
    }
  }
  
  void _addRandomCar() async {
    // Generate random X position on either left or right side
    final x = random.nextBool()
        ? random.nextDouble() * 400  // Left side: 0 to 400
        : 600 + random.nextDouble() * 400;  // Right side: 600 to 1000
    
    final y = 0.0; // Cars always start at the horizon
    
    // Choose a random car type
    final carTypes = CarType.values;
    final randomType = carTypes[random.nextInt(carTypes.length)];
    
    // Create a new car with world position
    final worldPosition = Vector2(x, y);
    final car = Car(
      position: worldPosition.clone(),
      size: Vector2(300, 180),
      carType: randomType,
    );
    
    // Add to our list and to the game
    cars.add(car);
    add(car);
    
    // Immediately update its projection
    updateCarProjection(car);
  }
  
void _addRandomTree() async {
  // Make sure trees appear within the viewport
  final x = random.nextBool()
      ? viewportMinX + random.nextDouble() * 50  // Left side
      : viewportMaxX - random.nextDouble() * 50; // Right side
  
  final y = 0.0; // Trees always start at the horizon
  
  // Choose a random tree type
  final treeTypes = TreeType.values;
  final randomType = treeTypes[random.nextInt(treeTypes.length)];
  
  // Create a new tree with world position - make it larger
  final worldPosition = Vector2(x, y);
  final tree = Tree(
    position: worldPosition.clone(),
    size: Vector2(300, 600), // Bigger trees that are easier to see
    treeType: randomType,
  );
  
  // Add to our list and to the game
  trees.add(tree);
  add(tree);
  //print("Added tree at position: $x, $y"); // Debug print
  
  // Immediately update its projection
  updateTreeProjection(tree);
}

    
  void updateCarProjection(Car car) {
    // Check viewport bounds - if outside viewport (including past viewportMaxY), don't render
    if (car.worldPosition.x < viewportMinX || 
        car.worldPosition.x > viewportMaxX || 
        car.worldPosition.y < viewportMinY || 
        car.worldPosition.y > viewportMaxY) {
      car.isVisible = false;
      return;
    }
    
    car.isVisible = true;

    
    
    // Calculate perspective values 
    // Normalize the Y position between 0 (furthest) and 1 (closest)
    final normalizedDepth = car.worldPosition.y / viewportMaxY;
    
    // Apply exponential transformation for stronger depth effect
    // Using power function for exponential growth: y^2 gives a mild effect, y^3 stronger
    final exponentialDepth = pow(normalizedDepth, 2.5).toDouble();
    

    // In the updateCarProjection method
    // Set priority for rendering order
    // Use a range between 0-40 so cars are above background but below windscreen
    car.priority = (40 * exponentialDepth).toInt();

    // Calculate screen X with perspective narrowing
    final screenWidth = size.x;
    final worldCenterX = worldWidth / 2;
    final screenCenterX = screenWidth / 2;
    final xOffsetFromCenter = car.worldPosition.x - worldCenterX;
    
    // NEW: Apply exponential horizontal spread - cars move away from center more dramatically as they approach
    // Use a higher exponent than for the depth to make this more pronounced
    final horizontalSpreadFactor = pow(normalizedDepth, 2.8).toDouble();
    
    // Adjust the X position more strongly as cars get closer
    // The closer to viewportMaxY, the more the X offset is amplified
    final perspectiveAdjustedX = screenCenterX + xOffsetFromCenter * (1.0 + horizontalSpreadFactor * 6.2);
    
    // Calculate screen Y with exponential acceleration
    final screenHeight = size.y;
    final horizonPosition = screenHeight * 0.3; // Horizon at 30% from top
    final groundPosition = screenHeight * 0.6; // Ground at 90% from top
    
    // Apply exponential positioning for Y axis too
    final screenY = horizonPosition + (groundPosition - horizonPosition) * exponentialDepth;
    
    // Apply position
    car.position = Vector2(perspectiveAdjustedX, screenY);
    
    // Scale with exponential growth for more dramatic size increase as cars approach
    // Minimum scale is 0.2, maximum is 1.0
    final baseScale = 0.2;
    final scaleRange = 2.8;
    final scale = baseScale + (scaleRange * exponentialDepth);
    car.scale = Vector2.all(scale);
    
    // Set priority for rendering order
    car.priority = (1000 * exponentialDepth).toInt();
  }
  
  void updateTreeProjection(Tree tree) {
    // Check viewport bounds - if outside viewport (including past viewportMaxY), don't render
    if (tree.worldPosition.x < viewportMinX || 
        tree.worldPosition.x > viewportMaxX || 
        tree.worldPosition.y < viewportMinY || 
        tree.worldPosition.y > viewportMaxY) {
      tree.isVisible = false;
      return;
    }
    
    tree.isVisible = true;
    
    // Calculate perspective values 
    // Normalize the Y position between 0 (furthest) and 1 (closest)
    final normalizedDepth = tree.worldPosition.y / viewportMaxY;
    
    // Apply exponential transformation for stronger depth effect
    // Using power function for exponential growth: y^2 gives a mild effect, y^3 stronger
    final exponentialDepth = pow(normalizedDepth, 2.5).toDouble();
    
    // Set priority for rendering order
    // Use a range between 0-40 so trees are above background but below windscreen
    tree.priority = (40 * exponentialDepth).toInt();

    // Calculate screen X with perspective narrowing
    final screenWidth = size.x;
    final worldCenterX = worldWidth / 2;
    final screenCenterX = screenWidth / 2;
    final xOffsetFromCenter = tree.worldPosition.x - worldCenterX;
    
    // Apply exponential horizontal spread - trees move away from center more dramatically as they approach
    final horizontalSpreadFactor = pow(normalizedDepth, 2.8).toDouble();
    
    // Adjust the X position more strongly as trees get closer
    final perspectiveAdjustedX = screenCenterX + xOffsetFromCenter * (1.0 + horizontalSpreadFactor * 6.2);
    
    // Calculate screen Y with exponential acceleration
    final screenHeight = size.y;
    final horizonPosition = screenHeight * 0.3; // Horizon at 30% from top
    final groundPosition = screenHeight * 0.6; // Ground at 90% from top
    
    // Apply exponential positioning for Y axis too
    final screenY = horizonPosition + (groundPosition - horizonPosition) * exponentialDepth;
    
    // Apply position
    tree.position = Vector2(perspectiveAdjustedX, screenY);
    
    // Scale with exponential growth for more dramatic size increase as trees approach
    // Minimum scale is 0.2, maximum is 1.0
    final baseScale = 0.2;
    final scaleRange = 2.8;
    final scale = baseScale + (scaleRange * exponentialDepth);
    tree.scale = Vector2.all(scale);
    
    // Set priority for rendering order - trees should be behind cars
    tree.priority = (800 * exponentialDepth).toInt();
  }

  // Helper method to get only visible cars
  List<Car> getVisibleCars() {
    return cars.where((car) => 
      car.isVisible && 
      car.worldPosition.x >= viewportMinX && 
      car.worldPosition.x <= viewportMaxX &&
      car.worldPosition.y >= viewportMinY && 
      car.worldPosition.y <= viewportMaxY
    ).toList();
  }
  
  // Show the wrong indicator sprite
  void showWrongIndicator() async {
    // Remove any existing wrong indicator
    if (wrongIndicator != null) {
      wrongIndicator!.removeFromParent();
    }
    
    // Create and add the wrong indicator
    wrongIndicator = SpriteComponent(
      sprite: await Sprite.load('wrong.png'),
      position: Vector2(size.x / 2, size.y / 2),
      size: Vector2(size.x * 0.5, size.y * 0.5), // 50% of screen size
      anchor: Anchor.center,
      priority: 150, // Above everything else
    );
    
    camera.viewport.add(wrongIndicator!);
    wrongDisplayTime = wrongDisplayDuration;
  }
  
  void handleSpottoPressed() {
    // Get only visible cars
    final visibleCars = getVisibleCars();
    
    // Find the first unspotted Spotto car that is visible
    try {
      final spottoCar = visibleCars.firstWhere(
        (car) => car.carType.isSpotto && !car.spotted,
      );
      
      // Mark as spotted and update score for correct spotting
      spottoCar.spotted = true;
      gameScore.numCorrectSpottos++;
    } catch (e) {
      // No unspotted Spotto cars found in the visible area, count as wrong
      gameScore.numWrongSpottos++;
      showWrongIndicator();
    }
  }
  
  void handleFroggoPressed() {
    // Get only visible cars
    final visibleCars = getVisibleCars();
    
    // Find the first unspotted Froggo car that is visible
    try {
      final froggoCar = visibleCars.firstWhere(
        (car) => car.carType.isFroggo && !car.spotted,
      );
      
      // Mark as spotted and update score for correct froggo
      froggoCar.spotted = true;
      gameScore.numCorrectFroggos++;
    } catch (e) {
      // No unspotted Froggo cars found in the visible area, count as wrong
      gameScore.numWrongFroggos++;
      showWrongIndicator();
    }
  }
}

// Custom component for gradient rectangle
class GradientRectangleComponent extends PositionComponent {
  late Paint _paint;
  final LinearGradient gradient;
  
  GradientRectangleComponent({
    required Vector2 position,
    required Vector2 size,
    required this.gradient,
    int? priority,
  }) : super(position: position, size: size, priority: priority) {
    _paint = Paint();
  }
  
  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    _paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, _paint);
  }
}