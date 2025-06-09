import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/puzzle_grid.dart';

class PuzzleScreen extends StatelessWidget {
  final File image;
  final int gridSize;

  const PuzzleScreen({
    super.key,
    required this.image,
    required this.gridSize,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Puzzle')),
      body: PuzzleGrid(
        imageFile: image,
        gridSize: gridSize,
      ),
    );
  }
}