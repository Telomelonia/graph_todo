import 'package:flutter/material.dart';

class ResizeHandlesWidget extends StatelessWidget {
  final double nodeSize;
  final double scale;
  final Function(DragStartDetails)? onTopRightDragStart;
  final Function(DragStartDetails)? onBottomLeftDragStart;
  final Function(DragUpdateDetails)? onTopRightDrag;
  final Function(DragUpdateDetails)? onBottomLeftDrag;
  final Function(DragEndDetails)? onTopRightDragEnd;
  final Function(DragEndDetails)? onBottomLeftDragEnd;

  const ResizeHandlesWidget({
    super.key,
    required this.nodeSize,
    required this.scale,
    this.onTopRightDragStart,
    this.onBottomLeftDragStart,
    this.onTopRightDrag,
    this.onBottomLeftDrag,
    this.onTopRightDragEnd,
    this.onBottomLeftDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    final handleSize = 24.0 * scale.clamp(0.8, 1.5);
    final nodeRadius = nodeSize / 2;
    final handleOffset = nodeRadius + handleSize / 2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Top-right resize handle
        Positioned(
          right: -handleOffset,
          top: -handleOffset,
          child: GestureDetector(
            onPanStart: onTopRightDragStart,
            onPanUpdate: onTopRightDrag,
            onPanEnd: onTopRightDragEnd,
            child: Container(
              width: handleSize,
              height: handleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.9),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.8),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.open_in_full,
                color: Colors.blue,
                size: handleSize * 0.6,
              ),
            ),
          ),
        ),
        // Bottom-left resize handle
        Positioned(
          left: -handleOffset,
          bottom: -handleOffset,
          child: GestureDetector(
            onPanStart: onBottomLeftDragStart,
            onPanUpdate: onBottomLeftDrag,
            onPanEnd: onBottomLeftDragEnd,
            child: Container(
              width: handleSize,
              height: handleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.9),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.8),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.open_in_full,
                color: Colors.blue,
                size: handleSize * 0.6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}