import 'dart:io';
import 'package:flutter/material.dart';

class PuzzleGrid extends StatelessWidget {
  final int gridSize;
  final File? imageFile;

  const PuzzleGrid({required this.gridSize, this.imageFile});

  @override
  Widget build(BuildContext context) {
    if (imageFile == null) {
      return const Center(child: Text('画像が未選択です'));
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridSize,
      ),
      itemCount: gridSize * gridSize,
      itemBuilder: (context, index) {
        return Image.file(
          imageFile!,
          fit: BoxFit.cover,
        );
      },
    );
  }
}

class PuzzleScreen extends StatelessWidget {
  final File image;
  final int gridSize;

  const PuzzleScreen({
    required this.image,
    required this.gridSize,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Puzzle Screen')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PuzzleGrid(
          imageFile: image,
          gridSize: gridSize,
        ),
      ),
    );
  }
}

