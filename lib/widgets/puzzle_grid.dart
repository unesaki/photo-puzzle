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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final gridHeight = screenHeight * 2 / 3;
    final pieceListHeight = screenHeight / 3;
    final imageWidth = image?.width.toDouble() ?? screenWidth;
    final imageHeight = image?.height.toDouble() ?? gridHeight;
    final pieceWidth = screenWidth * 0.9 / widget.gridSize;
    final pieceHeight = gridHeight / widget.gridSize;

    return Column(
      children: [
        // Puzzle Grid - 上部2/3
        SizedBox(
          height: gridHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxBoardHeight = constraints.maxHeight; // 動的な高さ取得
              final gridSize = widget.gridSize;

              // 元画像の縦横サイズ
              final imgWidth = image?.width.toDouble() ?? 1;
              final imgHeight = image?.height.toDouble() ?? 1;

              // 元画像の縦横比
              final imageAspectRatio = imgWidth / imgHeight;

              // ピースの縦横サイズを調整（縦優先）
              final pieceHeight = maxBoardHeight / gridSize;
              final pieceWidth = pieceHeight * imageAspectRatio;

              // 全体幅（超えた場合は縮小）
              final boardWidth = pieceWidth * gridSize;

              return Center(
                child: SizedBox(
                  height: maxBoardHeight,
                  width: boardWidth,
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                      childAspectRatio: imageAspectRatio,
                    ),
                    itemCount: gridSize * gridSize,
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
                            return _buildImagePiece(index, currentPiece, true, pieceWidth, pieceHeight);
                          } else if (currentPiece != null) {
                            return Draggable<int>(
                              data: currentPiece,
                              feedback: Material(
                                child: _buildImagePiece(index, currentPiece, false, pieceWidth, pieceHeight),
                              ),
                              childWhenDragging: Container(
                                width: pieceWidth,
                                height: pieceHeight,
                                color: Colors.grey,
                              ),
                              onDragCompleted: () {
                                setState(() {
                                  placedTiles[index] = null;
                                });
                              },
                              child: _buildImagePiece(index, currentPiece, false, pieceWidth, pieceHeight),
                            );
                          } else {
                            return Container(
                              width: pieceWidth,
                              height: pieceHeight,
                              margin: const EdgeInsets.all(1.0),
                              color: Colors.grey,
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        // Piece List - 下部1/3（最大5つ）
        SizedBox(
          height: pieceListHeight,
          child: Center(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: pieceList.take(5).map((piece) {
                return Draggable<int>(
                  data: piece,
                  feedback: Material(
                    child: _buildImagePiece(0, piece, false, pieceWidth * 0.75, pieceHeight * 0.75),
                  ),
                  childWhenDragging: Container(
                    width: pieceWidth * 0.75,
                    height: pieceHeight * 0.75,
                    color: Colors.grey,
                  ),
                  child: _buildImagePiece(0, piece, false, pieceWidth * 0.75, pieceHeight * 0.75),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePiece(int index, int? piece, bool isFixed, double pieceWidth, double pieceHeight) {
    if (image == null || piece == null) {
      return Container(
        width: pieceWidth,
        height: pieceHeight,
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

    final row = (piece - 1) ~/ widget.gridSize;
    final col = (piece - 1) % widget.gridSize;

    final imgWidth = image!.width.toDouble();
    final imgHeight = image!.height.toDouble();
    final srcWidth = imgWidth / widget.gridSize;
    final srcHeight = imgHeight / widget.gridSize;

    return CustomPaint(
      size: Size(pieceWidth, pieceHeight),
      painter: _ImagePiecePainter(
        image: image!,
        srcRect: Rect.fromLTWH(
          col * srcWidth,
          row * srcHeight,
          srcWidth,
          srcHeight,
        ),
        isFixed: isFixed,
        targetSize: Size(pieceWidth, pieceHeight),
      ),
    );
  }
}

class _ImagePiecePainter extends CustomPainter {
  final ui.Image image;
  final Rect srcRect;
  final bool isFixed;
  final Size targetSize;

  _ImagePiecePainter({
    required this.image,
    required this.srcRect,
    required this.isFixed,
    required this.targetSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    if (isFixed) {
      paint.colorFilter = const ColorFilter.mode(Colors.green, BlendMode.modulate);
    }
    canvas.drawImageRect(image, srcRect, Offset.zero & targetSize, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
