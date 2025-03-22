// car_game.dart
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:spotto/tree.dart';
import 'package:spotto/world_object.dart';
import 'package:spotto/title_screen.dart';
import 'car.dart';
import 'game_score.dart';
import 'ui_button.dart';
import 'score_display.dart';

// Enum to track the current game state
enum GameState {
  titleScreen,
  playing,
  gameOver,
}

class CarGame extends FlameGame with TapCallbacks {
  // World size properties
  static const worldWidth = 1000.0;
  static const worldHeight = 1000.0;
  
  // Viewport properties
  static const viewportMinX = 0;
  static const viewportMaxX = 1000;
  static const viewportMinY = 0;
  static const viewportMaxY = 600;
  
  // Car speed (pixels per second)
  static const carSpeed = 200.0;
  static const treeSpeed = 100.0;

  // Game state
  GameState _gameState = GameState.titleScreen;
  final List<Car> cars = [];
  final List<Tree> trees = [];
  final Random random = Random();
  final GameScore gameScore = GameScore();
  
  // Background elements
  late RectangleComponent skyBackground;
  late GradientRectangleComponent roadBackground;
  late SpriteComponent windscreen;
  
  // Title screen component
  TitleScreen? titleScreen;
  
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
    
    // Pre-verify asset loading for required resources
    await _preloadCoreAssets();
    
    // Mark that the game has been loaded
    hasBeenLoaded = true;
    
    // Load the title screen first
    await _loadTitleScreen();
  }
  
  // Method to preload core assets and handle errors gracefully
  Future<void> _preloadCoreAssets() async {
    try {
      // Preload critical images
      await images.loadAll([
        'windscreen.png',
        'wrong.png',
        'spotto.png',
        'froggo.png',
      ]);
    } catch (e) {
      print('Warning: Some assets failed to load: $e');
      // Continue anyway, we'll handle missing assets gracefully
    }
  }
  
  // Method to load the title screen
  Future<void> _loadTitleScreen() async {
    // Create the title screen
    titleScreen = TitleScreen(
      onStartGame: _startGame,
    );
    
    // Add it to the camera's viewport, not the world
    camera.viewport.add(titleScreen!);
    
    // Update game state
    _gameState = GameState.titleScreen;
  }
  
  // Method to start the game (called when start button is pressed)
  void _startGame() {
    // Change game state to playing first (prevents resizing issues)
    _gameState = GameState.playing;
    
    // Remove the title screen
    if (titleScreen != null) {
      print('Removing title screen');
      titleScreen!.removeFromParent();
      titleScreen = null;
    }
    
    // Load the game elements
    _loadGameElements();
  }
  
  // Load all game elements
  Future<void> _loadGameElements() async {
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

    // Add initial cars and trees
    for (int i = 0; i < 5; i++) {
      _addRandomCar();
      _addRandomTree();
    }
    
    // Add UI elements (buttons and score display)
    _setupUIElements();
  }
  
  void _setupUIElements() {
    // Button dimensions based on screen size
    final buttonWidth = size.x * 0.3; // 30% of screen width
    final buttonHeight = size.y * 0.08; // 8% of screen height
    final bottomPadding = size.y * 0.05; // 5% of screen height from bottom
    final sidePadding = size.x * 0.05; // 5% padding from sides
    
    // Create UI buttons and score display
    final spottoButton = UIButton(
      position: Vector2(sidePadding, size.y - buttonHeight - bottomPadding),
      size: Vector2(buttonWidth, buttonHeight),
      onPressed: handleSpottoPressed,
      spritePath: 'spotto.png',
      priority: 100,
    );

    final froggoButton = UIButton(
      position: Vector2(size.x - buttonWidth - sidePadding, size.y - buttonHeight - bottomPadding),
      size: Vector2(buttonWidth, buttonHeight),
      onPressed: handleFroggoPressed,
      spritePath: 'froggo.png',
      priority: 100,
    );

    final scoreDisplay = ScoreDisplay(
      position: Vector2(size.x * 0.05, size.y * 0.05),
      gameScore: gameScore,
      priority: 100,
    );
    
    // Add UI components to the camera viewport
    camera.viewport.add(spottoButton);
    camera.viewport.add(froggoButton);
    camera.viewport.add(scoreDisplay);
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    
    // If in title screen state, just let the components handle themselves
    if (_gameState == GameState.titleScreen) {
      // Don't set up game UI elements, but we still need to continue
      // to let the title screen handle its own resizing
    }
    
    // Clear any existing UI components first (for screen rotation)
    camera.viewport.children.whereType<UIButton>().forEach((button) => button.removeFromParent());
    camera.viewport.children.whereType<ScoreDisplay>().forEach((display) => display.removeFromParent());
    
    // Update background elements on resize only if they've been initialized
    if (hasBeenLoaded && _gameState == GameState.playing) {
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
      
      // Re-setup UI elements
      _setupUIElements();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Only update game logic if in playing state
    if (_gameState != GameState.playing) {
      return;
    }
    
    // 1 in 50 chance to add a new car
    if (random.nextInt(50) == 0) {
      _addRandomCar();
    }

    // 1 in 110 chance to add a new tree
    if (random.nextInt(110) == 0) {
      _addRandomTree();
    }
    
    // Update all cars' positions and remove those that have reached the end
    List<Car> carsToRemove = [];
    List<Tree> treesToRemove = [];

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
        carsToRemove.add(car);
      } else {
        // Update the visual representation of the car
        updateWorldObjectProjection(car);
      }
    }
    
    // Remove cars that have reached the end
    for (final car in carsToRemove) {
      car.removeFromParent();
      cars.remove(car);
    }

    // Update all trees' positions and remove those that have reached the end
    for (final tree in trees) {
      tree.worldPosition.y += treeSpeed * dt;
      
      if (tree.worldPosition.y >= worldHeight) {
        treesToRemove.add(tree);  
      } else {
        // Update the visual representation of the tree
        updateWorldObjectProjection(tree);
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
    // Generate random X position within the viewport range, Y always starts at 0
    const howFarFromSides = ((viewportMaxX - viewportMinX) / 2)- 50;
    final x = random.nextDouble() < 0.5 ? 
      viewportMinX + random.nextDouble() * howFarFromSides : 
      viewportMaxX - random.nextDouble() * howFarFromSides;
    const y = 0.0; // Cars always start at the horizon
    
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
    updateWorldObjectProjection(car);
  }

  void _addRandomTree() async {
    // Generate random X position within the viewport range, Y always starts at 0
    const howFarFromSides = ((viewportMaxX - viewportMinX) / 2)- 100;
    final x = random.nextDouble() < 0.5 ? 
      viewportMinX + random.nextDouble() * howFarFromSides : 
      viewportMaxX - random.nextDouble() * howFarFromSides;
    final y = 0.0; // Trees always start at the horizon
    
    final worldPosition = Vector2(x, y);
    final tree = Tree(
      position: worldPosition.clone(),
      size: Vector2(250, 250),
    );
    
    // Add to our list and to the game
    trees.add(tree);
    add(tree);
    
    // Immediately update its projection
    updateWorldObjectProjection(tree);
  }
    
  void updateWorldObjectProjection(WorldObject item) {
    // Calculate perspective values 
    // Normalize the Y position between 0 (furthest) and 1 (closest)
    final normalizedDepth = item.worldPosition.y / viewportMaxY;
    
    // Apply exponential transformation for stronger depth effect
    // Using power function for exponential growth: y^2 gives a mild effect, y^3 stronger
    final exponentialDepth = pow(normalizedDepth, 2.5).toDouble();
    
    // Set priority for rendering order
    // Use a range between 0-40 so cars are above background but below windscreen
    item.priority = (40 * exponentialDepth).toInt();

    // Calculate screen X with perspective narrowing
    final screenWidth = size.x;
    final worldCenterX = worldWidth / 2;
    final screenCenterX = screenWidth / 2;
    final xOffsetFromCenter = item.worldPosition.x - worldCenterX;
    
    // Apply exponential horizontal spread - cars move away from center more dramatically as they approach
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
    item.position = Vector2(perspectiveAdjustedX, screenY);
    
    // Scale with exponential growth for more dramatic size increase as cars approach
    // Minimum scale is 0.2, maximum is 1.0
    final baseScale = 0.2;
    final scaleRange = 2.8;
    final scale = baseScale + (scaleRange * exponentialDepth);
    item.scale = Vector2.all(scale);
    
    // Set priority for rendering order
    item.priority = (1000 * exponentialDepth).toInt();
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