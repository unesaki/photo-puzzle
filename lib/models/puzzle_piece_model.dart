enum EdgeType { flat, inward, outward }

class PuzzlePieceShape {
  final EdgeType top;
  final EdgeType right;
  final EdgeType bottom;
  final EdgeType left;

  const PuzzlePieceShape({
    required this.top,
    required this.right,
    required this.bottom,
    required this.left,
  });
}
