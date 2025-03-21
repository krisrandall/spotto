// main.dart
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'car_game.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Spotto',
      home: Scaffold(
        body: GameWidget(game: CarGame()),
      ),
    ),
  );
}
