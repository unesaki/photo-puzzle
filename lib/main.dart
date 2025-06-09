import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
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

class DifficultyScreen extends StatelessWidget {
  const DifficultyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Difficulty')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              Navigator.pushNamed(
                context,
                '/puzzle',
                arguments: {
                  'image': File(pickedFile.path),
                  'gridSize': 3,
                },
              );
            }
          },
          child: const Text('Pick Image and Start Puzzle'),
        ),
      ),
    );
  }
}
