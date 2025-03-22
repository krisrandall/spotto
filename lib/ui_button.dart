// ui_button.dart
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class UIButton extends PositionComponent with TapCallbacks {
  final String text;
  final Function onPressed;
  final Color color;
  final TextPaint textPaint = TextPaint(
    style: const TextStyle(
      fontSize: 24.0,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  );
  
  UIButton({
    required this.text,
    required Vector2 position,
    required Vector2 size,
    required this.onPressed,
    this.color = Colors.blue,
  }) : super(position: position, size: size);
  
  @override
  void render(ui.Canvas canvas) {
    super.render(canvas);
    
    // Draw the button background
    final paint = Paint()..color = color;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(rrect, paint);
    
    // Draw the button text - center it by rendering in the middle
    textPaint.render(
      canvas, 
      text, 
      Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center
    );
  }
  
  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    onPressed();
  }
}