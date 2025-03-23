// title_screen.dart - Updated with better orientation handling
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:spotto/ui_button.dart';

class PlayMode {
  final String name;
  final int? durationInSeconds; // null means unlimited
  
  const PlayMode(this.name, this.durationInSeconds);
  
  static const oneMin = PlayMode('1 Minute', 1 * 60);
  static const threeMin = PlayMode('3 Minutes', 3 * 60);
  static const tenMin = PlayMode('10 Minutes', 10 * 60);
  static const unlimited = PlayMode('Unlimited', null);
}

class TitleScreen extends PositionComponent with HasGameRef {
  // Title screen properties
  PositionComponent? _backgroundRect;
  TextComponent? _titleText;
  TextComponent? _versionText;
  
  // Car examples
  PositionComponent? _yellowCarExample;
  PositionComponent? _greenCarExample;
  PositionComponent? _spottoButtonExample;
  PositionComponent? _froggoButtonExample;
  
  // Play mode buttons
  List<UIButton> _playButtons = [];
  
  // Score display
  TextComponent? _highScoreText;
  TextComponent? _lastScoreText;
  
  // Version number
  String _versionNumber = "1.0.0";
  
  // Callback for when the game should start
  final Function(PlayMode) onStartGame;
  
  // Scoring data
  int _highScore = 0;
  int _highScoreDuration = 0; // in seconds
  bool _highScoreIsUnlimited = false;
  int _lastScore = 0;
  int _lastScoreDuration = 0; // in seconds
  bool _lastScoreIsUnlimited = false;
  
  // Constructor
  TitleScreen({
    required this.onStartGame,
    super.priority = 100,
  });
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Load high score and last score from local storage
    await _loadScores();
    
    // Load app version
    await _loadAppVersion();
    
    // Take up the entire screen
    size = gameRef.size;
    
    // Create the background
    _createBackground();
    
    // Load all UI elements
    await _createUIElements();
  }
  
  void _createBackground() {
    gameRef.images.load('title_bg.png').then((image) {
      final bgSprite = Sprite(image);
      
      // Calculate scale to fill width or height while maintaining aspect ratio
      final imageRatio = image.width / image.height;
      final screenRatio = size.x / size.y;
      
      final scale = imageRatio > screenRatio 
          ? size.y / image.height  // Height-constrained
          : size.x / image.width;  // Width-constrained
      
      final scaledWidth = image.width * scale;
      final scaledHeight = image.height * scale;
      
      // Center the image
      final x = (size.x - scaledWidth) / 2;
      final y = (size.y - scaledHeight) / 2;
      
      _backgroundRect = SpriteComponent(
        sprite: bgSprite,
        position: Vector2(x, y),
        size: Vector2(scaledWidth, scaledHeight),
        priority: 1,
      );
      
      add(_backgroundRect!);
    });
  }
  
  Future<void> _createUIElements() async {
    // Create title
    _titleText = TextComponent(
      text: 'SPOTTO',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 80.0,
          color: Colors.yellow, // bright yellow
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 5.0,
              color: Colors.black26,
              offset: Offset(2.0, 2.0),
            ),
          ],
        ),
      ),
      position: Vector2(size.x / 2, size.y * 0.12),
      anchor: Anchor.center,
      priority: 2,
    );
    add(_titleText!);
    
    // Add decorative bands
    _addDecorativeElements();
    
    // Add instruction text for yellow and green cars
    await _addInstructionSection();
    
    // Add play buttons
    await _addPlayButtons();
    
    // Add score displays
    _addScoreDisplay();
    
    // Add version text
    _versionText = TextComponent(
      text: 'v$_versionNumber',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 14.0,
          color: Colors.black54,
          fontWeight: FontWeight.normal,
        ),
      ),
      position: Vector2(size.x * 0.05, size.y * 0.95),
      anchor: Anchor.bottomLeft,
      priority: 3,
    );
    add(_versionText!);
  }
  
  Future<void> _loadScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _highScore = prefs.getInt('highScore') ?? 0;
      _highScoreDuration = prefs.getInt('highScoreDuration') ?? 0;
      _highScoreIsUnlimited = prefs.getBool('highScoreIsUnlimited') ?? false;
      
      _lastScore = prefs.getInt('lastScore') ?? 0;
      _lastScoreDuration = prefs.getInt('lastScoreDuration') ?? 0;
      _lastScoreIsUnlimited = prefs.getBool('lastScoreIsUnlimited') ?? false;
    } catch (e) {
      print('Error loading scores: $e');
      // Continue with default values if there's an error
    }
  }
  
  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _versionNumber = packageInfo.version;
    } catch (e) {
      print('Error loading app version: $e');
      // Keep default version if there's an error
    }
  }
  
  bool get isPortrait => size.y > size.x;
  
// Part of title_screen.dart - Update the instruction section

Future<void> _addInstructionSection() async {
  // Calculate positions based on current size and orientation
  final bool portrait = isPortrait;
  final instructionY = portrait ? size.y * 0.22 : size.y * 0.27;
  final spacing = size.x * (portrait ? 0.01 : 0.02);
  final exampleSize = Vector2(portrait ? 30 : 40, portrait ? 18 : 24);
  
  // Calculate font size based on screen size
  final instructionFontSize = portrait ? 12.0 : 16.0;
  
  // Create simpler instruction text to avoid cut-off
  // First row - Yellow car instruction
  final yellowText = TextComponent(
    text: 'See yellow car:',
    textRenderer: TextPaint(
      style: TextStyle(
        fontSize: instructionFontSize,
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
    ),
    position: Vector2(size.x * 0.1, instructionY),
    anchor: Anchor.centerLeft,
    priority: 2,
  );
  add(yellowText);
  
  // Yellow car example
  try {
    final yellowCarSprite = await Sprite.load('yellow.png');
    _yellowCarExample = SpriteComponent(
      sprite: yellowCarSprite,
      size: exampleSize,
      position: Vector2(yellowText.x + yellowText.width + spacing, instructionY),
      anchor: Anchor.centerLeft,
      priority: 2,
    );
    add(_yellowCarExample!);
  } catch (e) {
    print('Error loading yellow car sprite: $e');
    // Create a rectangle as fallback
    _yellowCarExample = RectangleComponent(
      size: exampleSize,
      position: Vector2(yellowText.x + yellowText.width + spacing, instructionY),
      paint: Paint()..color = Colors.yellow,
      anchor: Anchor.centerLeft,
    );
    add(_yellowCarExample!);
  }
  
  // "press the [spotto button]"
  final pressText = TextComponent(
    text: 'press:',
    textRenderer: TextPaint(
      style: TextStyle(
        fontSize: instructionFontSize,
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
    ),
    position: Vector2(_yellowCarExample!.position.x + exampleSize.x + spacing, instructionY),
    anchor: Anchor.centerLeft,
    priority: 2,
  );
  add(pressText);
  
  // Spotto button example
  try {
    final spottoButtonSprite = await Sprite.load('spotto.png');
    _spottoButtonExample = SpriteComponent(
      sprite: spottoButtonSprite,
      size: Vector2(portrait ? 45 : 60, portrait ? 18 : 24),
      position: Vector2(pressText.position.x + pressText.width + spacing, instructionY),
      anchor: Anchor.centerLeft,
      priority: 2,
    );
    add(_spottoButtonExample!);
  } catch (e) {
    print('Error loading spotto button sprite: $e');
    // Create a labeled rectangle as fallback
    final buttonComponent = RectangleComponent(
      size: Vector2(portrait ? 45 : 60, portrait ? 18 : 24),
      position: Vector2(pressText.position.x + pressText.width + spacing, instructionY),
      paint: Paint()..color = Colors.yellow,
      anchor: Anchor.centerLeft,
    );
    
    final labelFontSize = portrait ? 10.0 : 12.0;
    final buttonLabel = TextComponent(
      text: 'SPOTTO',
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: labelFontSize,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(buttonComponent.size.x / 2, buttonComponent.size.y / 2),
      anchor: Anchor.center,
    );
    buttonComponent.add(buttonLabel);
    
    _spottoButtonExample = buttonComponent;
    add(_spottoButtonExample!);
  }
  
  // Second row - Green car instruction
  final froggoY = instructionY + (portrait ? 25 : 35);
  
  // "See green car"
  final greenText = TextComponent(
    text: 'See green car:',
    textRenderer: TextPaint(
      style: TextStyle(
        fontSize: instructionFontSize,
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
    ),
    position: Vector2(size.x * 0.1, froggoY),
    anchor: Anchor.centerLeft,
    priority: 2,
  );
  add(greenText);
  
  // Green car example
  try {
    final greenCarSprite = await Sprite.load('green.png');
    _greenCarExample = SpriteComponent(
      sprite: greenCarSprite,
      size: exampleSize,
      position: Vector2(greenText.x + greenText.width + spacing, froggoY),
      anchor: Anchor.centerLeft,
      priority: 2,
    );
    add(_greenCarExample!);
  } catch (e) {
    print('Error loading green car sprite: $e');
    // Create a rectangle as fallback
    _greenCarExample = RectangleComponent(
      size: exampleSize,
      position: Vector2(greenText.x + greenText.width + spacing, froggoY),
      paint: Paint()..color = Colors.green,
      anchor: Anchor.centerLeft,
    );
    add(_greenCarExample!);
  }
  
  // "press the [froggo button]"
  final pressFroggoText = TextComponent(
    text: 'press:',
    textRenderer: TextPaint(
      style: TextStyle(
        fontSize: instructionFontSize,
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
    ),
    position: Vector2(_greenCarExample!.position.x + exampleSize.x + spacing, froggoY),
    anchor: Anchor.centerLeft,
    priority: 2,
  );
  add(pressFroggoText);
  
  // Froggo button example
  try {
    final froggoButtonSprite = await Sprite.load('froggo.png');
    _froggoButtonExample = SpriteComponent(
      sprite: froggoButtonSprite,
      size: Vector2(portrait ? 45 : 60, portrait ? 18 : 24),
      position: Vector2(pressFroggoText.position.x + pressFroggoText.width + spacing, froggoY),
      anchor: Anchor.centerLeft,
      priority: 2,
    );
    add(_froggoButtonExample!);
  } catch (e) {
    print('Error loading froggo button sprite: $e');
    // Create a labeled rectangle as fallback
    final buttonComponent = RectangleComponent(
      size: Vector2(portrait ? 45 : 60, portrait ? 18 : 24),
      position: Vector2(pressFroggoText.position.x + pressFroggoText.width + spacing, froggoY),
      paint: Paint()..color = Colors.green,
      anchor: Anchor.centerLeft,
    );
    
    final labelFontSize = portrait ? 10.0 : 12.0;
    final buttonLabel = TextComponent(
      text: 'FROGGO',
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: labelFontSize,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(buttonComponent.size.x / 2, buttonComponent.size.y / 2),
      anchor: Anchor.center,
    );
    buttonComponent.add(buttonLabel);
    
    _froggoButtonExample = buttonComponent;
    add(_froggoButtonExample!);
  }
}
  
  Future<void> _addPlayButtons() async {
    // Calculate positions based on current size and orientation
    final bool portrait = isPortrait;
    
    // Button dimensions - adjust based on orientation with smaller buttons for portrait
    final buttonWidth = portrait ? size.x * 0.38 : size.x * 0.35;
    final buttonHeight = size.y * (portrait ? 0.06 : 0.07);
    final buttonPadding = portrait ? size.x * 0.04 : size.x * 0.05;
    
    // Button Y positions - more space between sections
    final topRowY = portrait ? size.y * 0.36 : size.y * 0.45;
    final verticalGap = portrait ? size.y * 0.02 : size.y * 0.035;
    final bottomRowY = topRowY + buttonHeight + verticalGap;
    
    // Left column X position
    final leftColX = size.x * 0.5 - buttonWidth - buttonPadding / 2;
    
    // Right column X position
    final rightColX = size.x * 0.5 + buttonPadding / 2;
    
    // Add the four play mode buttons with text size relative to button size
    final buttonTextSize = portrait ? 14.0 : 18.0;
    
    // Top left: 1 minute
    final oneMinButton = UIButton(
      text: 'Play for 1 min',
      position: Vector2(leftColX, topRowY),
      size: Vector2(buttonWidth, buttonHeight),
      onPressed: () => onStartGame(PlayMode.oneMin),
      color: Colors.blue,
      priority: 3,
      textSize: buttonTextSize,
    );
    add(oneMinButton);
    _playButtons.add(oneMinButton);
    
    // Top right: 3 minutes
    final threeMinButton = UIButton(
      text: 'Play for 3 mins',
      position: Vector2(rightColX, topRowY),
      size: Vector2(buttonWidth, buttonHeight),
      onPressed: () => onStartGame(PlayMode.threeMin),
      color: Colors.blue,
      priority: 3,
      textSize: buttonTextSize,
    );
    add(threeMinButton);
    _playButtons.add(threeMinButton);
    
    // Bottom left: 10 minutes
    final tenMinButton = UIButton(
      text: 'Play for 10 mins',
      position: Vector2(leftColX, bottomRowY),
      size: Vector2(buttonWidth, buttonHeight),
      onPressed: () => onStartGame(PlayMode.tenMin),
      color: Colors.blue,
      priority: 3,
      textSize: buttonTextSize,
    );
    add(tenMinButton);
    _playButtons.add(tenMinButton);
    
    // Bottom right: Unlimited
    final unlimitedButton = UIButton(
      text: 'Unlimited Play',
      position: Vector2(rightColX, bottomRowY),
      size: Vector2(buttonWidth, buttonHeight),
      onPressed: () => onStartGame(PlayMode.unlimited),
      color: Colors.green,
      priority: 3,
      textSize: buttonTextSize,
    );
    add(unlimitedButton);
    _playButtons.add(unlimitedButton);
  }
  
  void _addScoreDisplay() {
    // Calculate positions based on current size and orientation
    final bool portrait = isPortrait;
    
    // Position score display with more spacing from buttons
    final scoreY = portrait ? size.y * 0.54 : size.y * 0.65;
    final scorePadding = portrait ? 22.0 : 30.0;
    final lastScoreY = scoreY + scorePadding;
    
    // Adjust font size based on orientation
    final scoreFontSize = portrait ? 14.0 : 18.0;
    
    // Format high score text
    String highScoreText = 'High Score: $_highScore';
    if (_highScore > 0) {
      if (_highScoreIsUnlimited) {
        final minutes = _highScoreDuration ~/ 60;
        final seconds = _highScoreDuration % 60;
        highScoreText += ' (in ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} of play)';
      } else {
        final minutes = _highScoreDuration ~/ 60;
        highScoreText += ' (in $minutes mins of play)';
      }
    }
    
    // Format last score text
    String lastScoreText = 'Last Score: $_lastScore';
    if (_lastScore > 0) {
      if (_lastScoreIsUnlimited) {
        final minutes = _lastScoreDuration ~/ 60;
        final seconds = _lastScoreDuration % 60;
        lastScoreText += ' (in ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} of play)';
      } else {
        final minutes = _lastScoreDuration ~/ 60;
        lastScoreText += ' (in $minutes mins of play)';
      }
    }
    
    // Add high score component
    _highScoreText = TextComponent(
      text: highScoreText,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: scoreFontSize,
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x * 0.5, scoreY),
      anchor: Anchor.center,
      priority: 3,
    );
    add(_highScoreText!);
    
    // Add last score component
    _lastScoreText = TextComponent(
      text: lastScoreText,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: scoreFontSize,
          color: Colors.black87,
        ),
      ),
      position: Vector2(size.x * 0.5, lastScoreY),
      anchor: Anchor.center,
      priority: 3,
    );
    add(_lastScoreText!);
  }
  
  void _addDecorativeElements() {
    // Calculate positions based on current size and orientation
    final bool portrait = isPortrait;
    
    // Add top and bottom bands with adjusted positions
    final topBand = RectangleComponent(
      position: Vector2(0, portrait ? size.y * 0.001 : size.y * 0.001),
      size: Vector2(size.x, 3),
      paint: Paint()..color =  Colors.yellow,
      priority: 2,
    );
    add(topBand);
    final reallBottomBand = RectangleComponent(
      position: Vector2(0, portrait ? size.y * 0.995 : size.y * 0.995),
      size: Vector2(size.x, 3),
      paint: Paint()..color =  Colors.yellow,
      priority: 2,
    );
    add(reallBottomBand);
    
    final bottomBand = RectangleComponent(
      position: Vector2(0, portrait ? size.y * 0.65 : size.y * 0.75),
      size: Vector2(size.x, 3),
      paint: Paint()..color =  Colors.yellow,
      priority: 2,
    );
    add(bottomBand);
  }
  
  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    
    // Store the old size for comparison
    final Vector2 oldSize = size.clone();
    final bool wasPortrait = oldSize.y > oldSize.x;
    
    // Update to new size
    size = canvasSize;
    final bool isPortraitNow = size.y > size.x;
    
    // Check if orientation changed
    final bool orientationChanged = wasPortrait != isPortraitNow;
    
    if (orientationChanged) {
      // For orientation changes, remove everything and rebuild from scratch
      removeAll(children);
      _playButtons.clear(); // Clear the buttons list
      
      // Re-initialize components with the new size/orientation
      _createBackground();
      // Wait for next frame before creating UI elements to ensure clean state
      Future.delayed(Duration.zero, () async {
        await _createUIElements();
      });
      
      return;
    }
    
    // For same orientation but different size, just adjust positions
    
    // Update background
    if (_backgroundRect != null && _backgroundRect!.isMounted) {
      _backgroundRect!.size = canvasSize;
    }
    
    // Update title position
    if (_titleText != null && _titleText!.isMounted) {
      _titleText!.position = Vector2(canvasSize.x / 2, canvasSize.y * 0.12);
    }
    
    // Update version position
    if (_versionText != null && _versionText!.isMounted) {
      _versionText!.position = Vector2(canvasSize.x * 0.05, canvasSize.y * 0.95);
    }
    
    // Update button layout
    _updateButtonLayout();
    
    // Update score text positions
    _updateScorePositions();
  }
  
  void _updateButtonLayout() {
    if (_playButtons.isEmpty) return;
    
    final bool portrait = isPortrait;
    
    // Button dimensions with adjusted sizes
    final buttonWidth = portrait ? size.x * 0.38 : size.x * 0.35;
    final buttonHeight = size.y * (portrait ? 0.06 : 0.07);
    final buttonPadding = portrait ? size.x * 0.04 : size.x * 0.05;
    
    // Button Y positions
    final topRowY = portrait ? size.y * 0.36 : size.y * 0.45;
    final verticalGap = portrait ? size.y * 0.02 : size.y * 0.035;
    final bottomRowY = topRowY + buttonHeight + verticalGap;
    
    // Column X positions
    final leftColX = size.x * 0.5 - buttonWidth - buttonPadding / 2;
    final rightColX = size.x * 0.5 + buttonPadding / 2;
    
    // Update button positions and sizes
    if (_playButtons.length >= 1 && _playButtons[0].isMounted) {
      _playButtons[0].position = Vector2(leftColX, topRowY);
      _playButtons[0].size = Vector2(buttonWidth, buttonHeight);
    }
    
    if (_playButtons.length >= 2 && _playButtons[1].isMounted) {
      _playButtons[1].position = Vector2(rightColX, topRowY);
      _playButtons[1].size = Vector2(buttonWidth, buttonHeight);
    }
    
    if (_playButtons.length >= 3 && _playButtons[2].isMounted) {
      _playButtons[2].position = Vector2(leftColX, bottomRowY);
      _playButtons[2].size = Vector2(buttonWidth, buttonHeight);
    }
    
    if (_playButtons.length >= 4 && _playButtons[3].isMounted) {
      _playButtons[3].position = Vector2(rightColX, bottomRowY);
      _playButtons[3].size = Vector2(buttonWidth, buttonHeight);
    }
  }
  
  void _updateScorePositions() {
    final bool portrait = isPortrait;
    
    // Calculate score positions
    final scoreY = portrait ? size.y * 0.54 : size.y * 0.65;
    final scorePadding = portrait ? 22.0 : 30.0;
    final lastScoreY = scoreY + scorePadding;
    
    // Update high score position
    if (_highScoreText != null && _highScoreText!.isMounted) {
      _highScoreText!.position = Vector2(size.x * 0.5, scoreY);
    }
    
    // Update last score position
    if (_lastScoreText != null && _lastScoreText!.isMounted) {
      _lastScoreText!.position = Vector2(size.x * 0.5, lastScoreY);
    }
  }
}