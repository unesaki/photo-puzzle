import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DifficultyScreen extends StatefulWidget {
  const DifficultyScreen({super.key});

  @override
  State<DifficultyScreen> createState() => _DifficultyScreenState();
}

class _DifficultyScreenState extends State<DifficultyScreen> {
  String selectedDifficulty = 'かんたん';

  int _difficultyToGridSize(String difficulty) {
    switch (difficulty) {
      case 'ふつう':
        return 4;
      case 'むずかしい':
        return 5;
      case 'かんたん':
      default:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('画像と難易度の選択')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RadioListTile<String>(
            title: const Text('かんたん (3x3)'),
            value: 'かんたん',
            groupValue: selectedDifficulty,
            onChanged: (value) {
              setState(() {
                selectedDifficulty = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('ふつう (4x4)'),
            value: 'ふつう',
            groupValue: selectedDifficulty,
            onChanged: (value) {
              setState(() {
                selectedDifficulty = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('むずかしい (5x5)'),
            value: 'むずかしい',
            groupValue: selectedDifficulty,
            onChanged: (value) {
              setState(() {
                selectedDifficulty = value!;
              });
            },
          ),
          ElevatedButton(
            onPressed: () async {
              final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                Navigator.pushNamed(
                  context,
                  '/puzzle',
                  arguments: {
                    'image': File(pickedFile.path),
                    'gridSize': _difficultyToGridSize(selectedDifficulty),
                  },
                );
              }
            },
            child: const Text('画像を選んでスタート'),
          ),
        ],
      ),
    );
  }
}