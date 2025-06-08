import 'package:flutter/material.dart';
import '../widgets/puzzle_grid.dart';

class PuzzleScreen extends StatelessWidget {
  const PuzzleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? difficulty = ModalRoute.of(context)!.settings.arguments as String?;
    int gridSize;
    File? imageFile;

    switch (difficulty) {
      case 'かんたん':
        gridSize = 3;
        break;
      case 'ふつう':
        gridSize = 5;
        break;
      case 'むずかしい':
        gridSize = 10;
        break;
      default:
        gridSize = 3;
    }

    Future<void> _pickImage() async {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          imageFile = File(pickedFile.path);
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzle Screen'),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.photo_library),
          onPressed: _pickImage,
        ),
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: () {
            // Implement undo functionality
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            // Implement reset functionality
          },
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PuzzleGrid(gridSize: gridSize, imageFile: imageFile),
      ),
    );
  }
}
