// title_screen.dart
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flame/palette.dart';
import 'package:spotto/ui_button.dart';

class TitleScreen extends PositionComponent with HasGameRef {
  // Title screen properties
  RectangleComponent? _backgroundRect;
  TextComponent? _titleText;
  UIButton? _startButton;
  TextComponent? _versionText;
  
  // Callback for when the game should start
  final VoidCallback onStartGame;
  
  // Constructor
  TitleScreen({
    required this.onStartGame,
    super.priority = 100,
  });
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Take up the entire screen
    size = gameRef.size;
    
    // Create a gradient background instead of using an image
    _backgroundRect = RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF1E3A8A), // Dark blue background
      priority: 1,
    );
    add(_backgroundRect!);
    
    // Add game title text instead of logo image
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
      position: Vector2(size.x / 2, size.y * 0.3),
      anchor: Anchor.center,
      priority: 2,
    );
    add(_titleText!);
    
    // Create start button
    _startButton = UIButton(
      text: 'START GAME',
      position: Vector2(size.x / 2 - (size.x * 0.3) / 2, size.y * 0.6),
      size: Vector2(size.x * 0.3, size.y * 0.08),
      onPressed: onStartGame,
      color: Colors.green,
      priority: 3,
    );
    add(_startButton!);
    
    // Add subtitle text
    final subtitleText = TextComponent(
      text: 'The ultimate spotting game!',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24.0,
          color: Colors.white,
          fontWeight: FontWeight.normal,
        ),
      ),
      position: Vector2(size.x / 2, size.y * 0.4),
      anchor: Anchor.center,
      priority: 2,
    );
    add(subtitleText);
    
    // Add version text
    _versionText = TextComponent(
      text: 'v1.0.0',
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
  
  void _addDecorativeElements() {
    // Add a few car silhouettes or other decorative elements
    final topBand = RectangleComponent(
      position: Vector2(0, size.y * 0.1),
      size: Vector2(size.x, 10),
      paint: Paint()..color = Colors.yellow,
      priority: 2,
    );
    add(topBand);
    
    final bottomBand = RectangleComponent(
      position: Vector2(0, size.y * 0.9),
      size: Vector2(size.x, 10),
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
      _titleText!.position = Vector2(canvasSize.x / 2, canvasSize.y * 0.3);
    }
    
    if (_startButton != null && _startButton!.isMounted) {
      _startButton!.position = Vector2(canvasSize.x / 2 - (canvasSize.x * 0.3) / 2, canvasSize.y * 0.6);
      _startButton!.size = Vector2(canvasSize.x * 0.3, canvasSize.y * 0.08);
    }
    
    if (_versionText != null && _versionText!.isMounted) {
      _versionText!.position = Vector2(canvasSize.x * 0.05, canvasSize.y * 0.95);
    }
  }
}