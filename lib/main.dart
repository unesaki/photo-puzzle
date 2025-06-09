import 'dart:io';
import 'package:flutter/material.dart';
import 'screens/difficulty_screen.dart';
import 'screens/puzzle_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Puzzle',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DifficultyScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/puzzle') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => PuzzleScreen(
              image: args['image'],
              gridSize: args['gridSize'],
            ),
          );
        }
        return null;
      },
    );
  }
}