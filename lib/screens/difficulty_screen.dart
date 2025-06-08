import 'package:flutter/material.dart';

class DifficultyScreen extends StatefulWidget {
  const DifficultyScreen({super.key});

  @override
  _DifficultyScreenState createState() => _DifficultyScreenState();
}

class _DifficultyScreenState extends State<DifficultyScreen> {
  String selectedDifficulty = 'かんたん';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Difficulty Selection'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RadioListTile<String>(
            title: const Text('かんたん'),
            value: 'かんたん',
            groupValue: selectedDifficulty,
            onChanged: (value) {
              setState(() {
                selectedDifficulty = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('ふつう'),
            value: 'ふつう',
            groupValue: selectedDifficulty,
            onChanged: (value) {
              setState(() {
                selectedDifficulty = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('むずかしい'),
            value: 'むずかしい',
            groupValue: selectedDifficulty,
            onChanged: (value) {
              setState(() {
                selectedDifficulty = value!;
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/puzzle',
                arguments: selectedDifficulty,
              );
            },
            child: const Text('Go to Puzzle'),
          ),
        ],
      ),
    );
  }
}
