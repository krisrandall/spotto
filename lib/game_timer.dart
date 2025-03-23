// game_timer.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class GameTimer extends PositionComponent {
  // Display properties
  final TextPaint _textPaint = TextPaint(
    style: const TextStyle(
      fontSize: 16.0,
      color: Colors.white,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          blurRadius: 3.0,
          color: Colors.black,
          offset: Offset(1.0, 1.0),
        ),
      ],
    ),
  );
  
  // Timer properties
  int? _durationInSeconds; // null means unlimited
  double _elapsedSeconds = 0;
  bool _isCountingDown;
  bool _isActive = true;
  
  // Finish trip button
  FinishTripButton? _finishTripButton;
  final VoidCallback? onFinishPressed;
  
  // Constructor
  GameTimer({
    required Vector2 position,
    required this.onFinishPressed,
    int? durationInSeconds,
    super.priority = 100,
  }) : _durationInSeconds = durationInSeconds,
       _isCountingDown = durationInSeconds != null,
       super(position: position, size: Vector2(80, 20)) {
    _elapsedSeconds = 0;
  }
  
  // Public properties
  int? get durationInSeconds => _durationInSeconds;
  set durationInSeconds(int? value) {
    _durationInSeconds = value;
    _isCountingDown = value != null;
    _elapsedSeconds = 0;
    _isActive = true;
  }
  
  int get elapsedSeconds => _elapsedSeconds.toInt();
  int get remainingSeconds => _durationInSeconds != null ? 
      (_durationInSeconds! - _elapsedSeconds).toInt().clamp(0, _durationInSeconds!) : 
      0;
  
  bool get isCountingDown => _isCountingDown;
  bool get isFinished => _isCountingDown && remainingSeconds <= 0;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Create finish trip button for unlimited mode
    if (!_isCountingDown && onFinishPressed != null) {
      _finishTripButton = FinishTripButton(
        position: Vector2(0, 25),
        size: Vector2(80, 20),
        onPressed: onFinishPressed!,
      );
      add(_finishTripButton!);
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (_isActive) {
      _elapsedSeconds += dt;
      
      // Check if timer has finished
      if (_isCountingDown && remainingSeconds <= 0 && onFinishPressed != null) {
        _isActive = false;
        onFinishPressed!();
      }
    }
  }
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Format timer string
    String timerText;
    if (_isCountingDown) {
      final minutes = (remainingSeconds / 60).floor();
      final seconds = remainingSeconds % 60;
      timerText = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      final minutes = (_elapsedSeconds / 60).floor();
      final seconds = _elapsedSeconds.toInt() % 60;
      timerText = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    
    // Render the timer text
    _textPaint.render(canvas, timerText, Vector2.zero());
  }
}

class FinishTripButton extends PositionComponent {
  final VoidCallback onPressed;
  
  FinishTripButton({
    required Vector2 position,
    required Vector2 size,
    required this.onPressed,
    super.priority,
  }) : super(position: position, size: size);
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add background with border
    final background = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.red.withOpacity(0.7),
    );
    add(background);
    
    // Add border to make the button more visible
    final border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = Colors.white,
    );
    add(border);
    
    // Add label
    final label = TextComponent(
      text: 'Finish Trip',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 12.0,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 1.0,
              color: Colors.black,
              offset: Offset(1.0, 1.0),
            ),
          ],
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
    add(label);
  }
}