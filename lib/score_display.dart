
// score_display.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'game_score.dart';

class ScoreDisplay extends PositionComponent {
  final GameScore gameScore;
  final TextPaint textPaint = TextPaint(
    style: const TextStyle(
      fontSize: 32.0,
      color: Colors.white,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          blurRadius: 3.0,
          color: Colors.black,
          offset: Offset(2.0, 2.0),
        ),
      ],
    ),
  );
  
  ScoreDisplay({
    required Vector2 position,
    required this.gameScore,
  }) : super(position: position);
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final scoreText = 'Score: ${gameScore.totalScore}';
    textPaint.render(canvas, scoreText, Vector2.zero());
  }
}
