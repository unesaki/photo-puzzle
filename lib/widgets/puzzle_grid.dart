import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:io';

class PuzzleGrid extends StatefulWidget {
  final int gridSize;
  final File? imageFile;

  const PuzzleGrid({super.key, required this.gridSize, this.imageFile});

  @override
  _PuzzleGridState createState() => _PuzzleGridState();
}

class _PuzzleGridState extends State<PuzzleGrid> {
  late List<int?> placedTiles;
  late List<int> pieceList;
  ui.Image? image;
  List<int> history = [];

  @override
  void initState() {
    super.initState();
    _initializeTiles();
    _loadImage();
  }

  void _initializeTiles() {
    placedTiles = List<int?>.filled(widget.gridSize * widget.gridSize, null);
    pieceList = List<int>.generate(widget.gridSize * widget.gridSize, (index) => index + 1);
    pieceList.shuffle(Random());
    history.clear();
  }

  Future<void> _loadImage() async {
    if (widget.imageFile != null) {
      final bytes = await widget.imageFile!.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      setState(() {
        image = frame.image;
      });
    } else {
      final data = await DefaultAssetBundle.of(context).load('assets/sample.jpg');
      final bytes = data.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      setState(() {
        image = frame.image;
      });
    }
  }

  bool isCompleted() {
    for (int i = 0; i < placedTiles.length; i++) {
      if (placedTiles[i] != i + 1) {
        return false;
      }
    }
    return true;
  }

  void _checkCompletion() {
    if (isCompleted()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('完成しました！'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      });
    }
  }

  void undo() {
    if (history.isNotEmpty) {
      setState(() {
        final lastIndex = history.removeLast();
        final piece = placedTiles[lastIndex];
        if (piece != null) {
          pieceList.add(piece);
          placedTiles[lastIndex] = null;
        }
      });
    }
  }

  void reset() {
    setState(() {
      _initializeTiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxGridSize = MediaQuery.of(context).size.width * 0.9;
    final pieceSize = maxGridSize / widget.gridSize;

    return Column(
      children: [
        // Puzzle Grid
        SizedBox(
          width: maxGridSize,
          height: maxGridSize,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.gridSize,
            ),
            itemCount: widget.gridSize * widget.gridSize,
            itemBuilder: (context, index) {
              final expectedValue = index + 1;
              final currentPiece = placedTiles[index];

              return DragTarget<int>(
                onAccept: (data) {
                  setState(() {
                    placedTiles[index] = data;
                    pieceList.remove(data);
                    history.add(index);
                  });
                  _checkCompletion();
                },
                builder: (context, candidateData, rejectedData) {
                  if (currentPiece == expectedValue) {
                    // Correctly placed piece, not draggable
                    return _buildImagePiece(index, currentPiece, true, pieceSize);
                  } else if (currentPiece != null) {
                    // Incorrectly placed piece, draggable
                    return Draggable<int>(
                      data: currentPiece,
                      feedback: Material(
                        child: _buildImagePiece(index, currentPiece, false, pieceSize),
                      ),
                      childWhenDragging: Container(
                        width: pieceSize,
                        height: pieceSize,
                        color: Colors.grey,
                      ),
                      onDragCompleted: () {
                        setState(() {
                          placedTiles[index] = null;
                        });
                      },
                      child: _buildImagePiece(index, currentPiece, false, pieceSize),
                    );
                  } else {
                    // Empty spot
                    return Container(
                      width: pieceSize,
                      height: pieceSize,
                      margin: const EdgeInsets.all(1.0),
                      color: Colors.grey,
                    );
                  }
                },
              );
            },
          ),
        ),
        // Piece List
        SizedBox(
          height: pieceSize + 20,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: pieceList.length,
            itemBuilder: (context, index) {
              return Draggable<int>(
                data: pieceList[index],
                feedback: Material(
                  child: _buildImagePiece(index, pieceList[index], false, pieceSize),
                ),
                childWhenDragging: Container(
                  width: pieceSize,
                  height: pieceSize,
                  color: Colors.grey,
                ),
                child: _buildImagePiece(index, pieceList[index], false, pieceSize),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImagePiece(int index, int? piece, bool isFixed, double pieceSize) {
    if (image == null) {
      return Container(
        width: pieceSize,
        height: pieceSize,
        margin: const EdgeInsets.all(1.0),
        color: isFixed ? Colors.green : Colors.blueAccent,
        child: Center(
          child: Text(
            piece?.toString() ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    final row = (piece! - 1) ~/ widget.gridSize;
    final col = (piece - 1) % widget.gridSize;

    return CustomPaint(
      size: Size(pieceSize, pieceSize),
      painter: _ImagePiecePainter(
        image: image!,
        srcRect: Rect.fromLTWH(col * pieceSize, row * pieceSize, pieceSize, pieceSize),
        isFixed: isFixed,
      ),
    );
  }
}

class _ImagePiecePainter extends CustomPainter {
  final ui.Image image;
  final Rect srcRect;
  final bool isFixed;

  _ImagePiecePainter({required this.image, required this.srcRect, required this.isFixed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    if (isFixed) {
      paint.colorFilter = const ColorFilter.mode(Colors.green, BlendMode.modulate);
    }
    canvas.drawImageRect(image, srcRect, Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
