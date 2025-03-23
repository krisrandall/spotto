// ui_button.dart - Updated with text size parameter
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class UIButton extends PositionComponent with TapCallbacks {
  final String? text;
  final Function onPressed;
  final Color color;
  final int priority;
  final double textSize;

  late final TextPaint textPaint;
  
  // For sprite buttons
  Sprite? buttonSprite;
  String? spritePath;
  bool _spriteLoaded = false;
  
  UIButton({
    this.text,
    required Vector2 position,
    required Vector2 size,
    required this.onPressed,
    this.color = Colors.blue,
    this.spritePath,
    this.priority = 0,
    this.textSize = 24.0,
  }) : super(
         position: position,
         size: size,
         priority: priority,
       ) {
    textPaint = TextPaint(
      style: TextStyle(
        fontSize: textSize,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Load sprite if spritePath is provided
    if (spritePath != null && !_spriteLoaded) {
      try {
        buttonSprite = await Sprite.load(spritePath!);
        _spriteLoaded = true;
      } catch (e) {
        print('Error loading button sprite: $e');
      }
    }
  }
  
  @override
  void render(ui.Canvas canvas) {
    super.render(canvas);
    
    if (buttonSprite != null) {
      // Draw the button sprite
      buttonSprite!.render(
        canvas, 
        size: size,
        position: Vector2.zero(),
      );
    } else {
      // Draw the button background
      final paint = Paint()..color = color;
      final rect = Rect.fromLTWH(0, 0, size.x, size.y);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
      canvas.drawRRect(rrect, paint);
      
      // Draw the button text - center it by rendering in the middle
      if (text != null) {
        textPaint.render(
          canvas, 
          text!, 
          Vector2(size.x / 2, size.y / 2),
          anchor: Anchor.center
        );
      }
    }
  }
  
  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    onPressed();
  }
}