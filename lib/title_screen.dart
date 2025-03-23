// title_screen.dart
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flame/palette.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:spotto/ui_button.dart';
import 'package:spotto/car.dart';

class PlayMode {
  final String name;
  final int? durationInSeconds; // null means unlimited
  
  const PlayMode(this.name, this.durationInSeconds);
  
  static const twoMin = PlayMode('2 Minutes', 2 * 60);
  static const fiveMin = PlayMode('5 Minutes', 5 * 60);
  static const tenMin = PlayMode('10 Minutes', 10 * 60);
  static const unlimited = PlayMode('Unlimited', null);
}

class TitleScreen extends PositionComponent with HasGameRef {
  // Title screen properties
  RectangleComponent? _backgroundRect;
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
    
    // Create a gradient background
    _backgroundRect = RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF1E3A8A), // Dark blue background
      priority: 1,
    );
    add(_backgroundRect!);
    
    // Add game title text
    _titleText = TextComponent(
      text: 'SPOTTO',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 64.0,
          color: Colors.yellow,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 10.0,
              color: Colors.black,
              offset: Offset(2.0, 2.0),
            ),
          ],
        ),
      ),
      position: Vector2(size.x / 2, size.y * 0.15),
      anchor: Anchor.center,
      priority: 2,
    );
    add(_titleText!);
    
    // Add instruction text for yellow car
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
          fontSize: 16.0,
          color: Colors.white,
          fontWeight: FontWeight.normal,
        ),
      ),
      position: Vector2(size.x * 0.05, size.y * 0.95),
      anchor: Anchor.bottomLeft,
      priority: 3,
    );
    add(_versionText!);
    
    // Add decorative elements
    _addDecorativeElements();
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
  
  Future<void> _addInstructionSection() async {
    final instructionY = size.y * 0.27;
    final spacing = size.x * 0.025;
    final exampleSize = Vector2(40, 24);
    
    // Row 1: Spotto instruction
    // "When you see a yellow car"
    final yellowInstruction = TextComponent(
      text: 'When you see a yellow car',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 18.0,
          color: Colors.white,
        ),
      ),
      position: Vector2(size.x * 0.25, instructionY),
      anchor: Anchor.centerRight,
      priority: 2,
    );
    add(yellowInstruction);
    
    // Yellow car example
    try {
      final yellowCarSprite = await Sprite.load('yellow.png');
      _yellowCarExample = SpriteComponent(
        sprite: yellowCarSprite,
        size: exampleSize,
        position: Vector2(size.x * 0.25 + spacing, instructionY),
        anchor: Anchor.centerLeft,
        priority: 2,
      );
      add(_yellowCarExample!);
    } catch (e) {
      print('Error loading yellow car sprite: $e');
      // Create a rectangle as fallback
      _yellowCarExample = RectangleComponent(
        size: exampleSize,
        position: Vector2(size.x * 0.25 + spacing, instructionY),
        paint: Paint()..color = Colors.yellow,
        anchor: Anchor.centerLeft,
      );
      add(_yellowCarExample!);
    }
    
    // "press the [spotto button]"
    final spottoButtonText = TextComponent(
      text: 'press the',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 18.0,
          color: Colors.white,
        ),
      ),
      position: Vector2(size.x * 0.25 + spacing + exampleSize.x + spacing, instructionY),
      anchor: Anchor.centerLeft,
      priority: 2,
    );
    add(spottoButtonText);
    
    // Spotto button example
    try {
      final spottoButtonSprite = await Sprite.load('spotto.png');
      _spottoButtonExample = SpriteComponent(
        sprite: spottoButtonSprite,
        size: Vector2(60, 24),
        position: Vector2(size.x * 0.25 + spacing + exampleSize.x + spacing + spottoButtonText.width + spacing, instructionY),
        anchor: Anchor.centerLeft,
        priority: 2,
      );
      add(_spottoButtonExample!);
    } catch (e) {
      print('Error loading spotto button sprite: $e');
      // Create a labeled rectangle as fallback
      final buttonComponent = RectangleComponent(
        size: Vector2(60, 24),
        position: Vector2(size.x * 0.25 + spacing + exampleSize.x + spacing + spottoButtonText.width + spacing, instructionY),
        paint: Paint()..color = Colors.yellow,
        anchor: Anchor.centerLeft,
      );
      
      final buttonLabel = TextComponent(
        text: 'SPOTTO',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 12.0,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: Vector2(30, 12),
        anchor: Anchor.center,
      );
      buttonComponent.add(buttonLabel);
      
      _spottoButtonExample = buttonComponent;
      add(_spottoButtonExample!);
    }
    
    // Row 2: Froggo instruction (positioned below row 1)
    final froggoY = instructionY + 40;
    
    // "When you see a green car"
    final greenInstruction = TextComponent(
      text: 'When you see a green car',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 18.0,
          color: Colors.white,
        ),
      ),
      position: Vector2(size.x * 0.25, froggoY),
      anchor: Anchor.centerRight,
      priority: 2,
    );
    add(greenInstruction);
    
    // Green car example
    try {
      final greenCarSprite = await Sprite.load('green.png');
      _greenCarExample = SpriteComponent(
        sprite: greenCarSprite,
        size: exampleSize,
        position: Vector2(size.x * 0.25 + spacing, froggoY),
        anchor: Anchor.centerLeft,
        priority: 2,
      );
      add(_greenCarExample!);
    } catch (e) {
      print('Error loading green car sprite: $e');
      // Create a rectangle as fallback
      _greenCarExample = RectangleComponent(
        size: exampleSize,
        position: Vector2(size.x * 0.25 + spacing, froggoY),
        paint: Paint()..color = Colors.green,
        anchor: Anchor.centerLeft,
      );
      add(_greenCarExample!);
    }
    
    // "press the [froggo button]"
    final froggoButtonText = TextComponent(
      text: 'press the',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 18.0,
          color: Colors.white,
        ),
      ),
      position: Vector2(size.x * 0.25 + spacing + exampleSize.x + spacing, froggoY),
      anchor: Anchor.centerLeft,
      priority: 2,
    );
    add(froggoButtonText);
    
    // Froggo button example
    try {
      final froggoButtonSprite = await Sprite.load('froggo.png');
      _froggoButtonExample = SpriteComponent(
        sprite: froggoButtonSprite,
        size: Vector2(60, 24),
        position: Vector2(size.x * 0.25 + spacing + exampleSize.x + spacing + froggoButtonText.width + spacing, froggoY),
        anchor: Anchor.centerLeft,
        priority: 2,
      );
      add(_froggoButtonExample!);
    } catch (e) {
      print('Error loading froggo button sprite: $e');
      // Create a labeled rectangle as fallback
      final buttonComponent = RectangleComponent(
        size: Vector2(60, 24),
        position: Vector2(size.x * 0.25 + spacing + exampleSize.x + spacing + froggoButtonText.width + spacing, froggoY),
        paint: Paint()..color = Colors.green,
        anchor: Anchor.centerLeft,
      );
      
      final buttonLabel = TextComponent(
        text: 'FROGGO',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 12.0,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: Vector2(30, 12),
        anchor: Anchor.center,
      );
      buttonComponent.add(buttonLabel);
      
      _froggoButtonExample = buttonComponent;
      add(_froggoButtonExample!);
    }
  }
  
  Future<void> _addPlayButtons() async {
    // Button dimensions
    final buttonWidth = size.x * 0.4;
    final buttonHeight = size.y * 0.08;
    final buttonPadding = size.x * 0.05;
    
    // Button Y positions
    final topRowY = size.y * 0.45;
    final bottomRowY = topRowY + buttonHeight + size.y * 0.02;
    
    // Left column X position
    final leftColX = size.x * 0.5 - buttonWidth - buttonPadding / 2;
    
    // Right column X position
    final rightColX = size.x * 0.5 + buttonPadding / 2;
    
    // Add the four play mode buttons
    // Top left: 2 minutes
    final twoMinButton = UIButton(
      text: 'Play for 2 mins',
      position: Vector2(leftColX, topRowY),
      size: Vector2(buttonWidth, buttonHeight),
      onPressed: () => onStartGame(PlayMode.twoMin),
      color: Colors.blue,
      priority: 3,
    );
    add(twoMinButton);
    _playButtons.add(twoMinButton);
    
    // Top right: 5 minutes
    final fiveMinButton = UIButton(
      text: 'Play for 5 mins',
      position: Vector2(rightColX, topRowY),
      size: Vector2(buttonWidth, buttonHeight),
      onPressed: () => onStartGame(PlayMode.fiveMin),
      color: Colors.blue,
      priority: 3,
    );
    add(fiveMinButton);
    _playButtons.add(fiveMinButton);
    
    // Bottom left: 10 minutes
    final tenMinButton = UIButton(
      text: 'Play for 10 mins',
      position: Vector2(leftColX, bottomRowY),
      size: Vector2(buttonWidth, buttonHeight),
      onPressed: () => onStartGame(PlayMode.tenMin),
      color: Colors.blue,
      priority: 3,
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
    );
    add(unlimitedButton);
    _playButtons.add(unlimitedButton);
  }
  
  void _addScoreDisplay() {
    final scoreY = size.y * 0.65;
    final lastScoreY = scoreY + 30;
    
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
        style: const TextStyle(
          fontSize: 20.0,
          color: Colors.white,
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
        style: const TextStyle(
          fontSize: 20.0,
          color: Colors.white,
        ),
      ),
      position: Vector2(size.x * 0.5, lastScoreY),
      anchor: Anchor.center,
      priority: 3,
    );
    add(_lastScoreText!);
  }
  
  void _addDecorativeElements() {
    // Add top and bottom bands
    final topBand = RectangleComponent(
      position: Vector2(0, size.y * 0.08),
      size: Vector2(size.x, 5),
      paint: Paint()..color = Colors.yellow,
      priority: 2,
    );
    add(topBand);
    
    final bottomBand = RectangleComponent(
      position: Vector2(0, size.y * 0.75),
      size: Vector2(size.x, 5),
      paint: Paint()..color = Colors.yellow,
      priority: 2,
    );
    add(bottomBand);
  }
  
  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    
    // Update component sizes and positions on screen resize
    size = canvasSize;
    
    if (_backgroundRect != null && _backgroundRect!.isMounted) {
      _backgroundRect!.size = canvasSize;
    }
    
    if (_titleText != null && _titleText!.isMounted) {
      _titleText!.position = Vector2(canvasSize.x / 2, canvasSize.y * 0.15);
    }
    
    if (_versionText != null && _versionText!.isMounted) {
      _versionText!.position = Vector2(canvasSize.x * 0.05, canvasSize.y * 0.95);
    }
    
    // Resize play buttons
    _updatePlayButtonsLayout(canvasSize);
    
    // Update score text positions
    if (_highScoreText != null && _highScoreText!.isMounted) {
      _highScoreText!.position = Vector2(canvasSize.x * 0.5, canvasSize.y * 0.65);
    }
    
    if (_lastScoreText != null && _lastScoreText!.isMounted) {
      _lastScoreText!.position = Vector2(canvasSize.x * 0.5, canvasSize.y * 0.65 + 30);
    }
  }
  
  void _updatePlayButtonsLayout(Vector2 canvasSize) {
    if (_playButtons.isEmpty) return;
    
    // Button dimensions
    final buttonWidth = canvasSize.x * 0.4;
    final buttonHeight = canvasSize.y * 0.08;
    final buttonPadding = canvasSize.x * 0.05;
    
    // Button Y positions
    final topRowY = canvasSize.y * 0.45;
    final bottomRowY = topRowY + buttonHeight + canvasSize.y * 0.02;
    
    // Left column X position
    final leftColX = canvasSize.x * 0.5 - buttonWidth - buttonPadding / 2;
    
    // Right column X position
    final rightColX = canvasSize.x * 0.5 + buttonPadding / 2;
    
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
}