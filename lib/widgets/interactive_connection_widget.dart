import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/connection.dart';
import '../models/todo_node.dart';
import '../providers/canvas_provider.dart';

class InteractiveConnectionWidget extends StatefulWidget {
  final Connection connection;
  final TodoNode fromNode;
  final TodoNode toNode;

  const InteractiveConnectionWidget({
    super.key,
    required this.connection,
    required this.fromNode,
    required this.toNode,
  });

  @override
  State<InteractiveConnectionWidget> createState() => _InteractiveConnectionWidgetState();
}

class _InteractiveConnectionWidgetState extends State<InteractiveConnectionWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<CanvasProvider>(
      builder: (context, provider, child) {
        // Convert node positions to screen coordinates
        final fromPos = provider.canvasToScreen(widget.fromNode.position);
        final toPos = provider.canvasToScreen(widget.toNode.position);
        
        // Calculate connection points on node edges
        final fromRadius = (widget.fromNode.size / 2) * provider.scale;
        final toRadius = (widget.toNode.size / 2) * provider.scale;
        
        final direction = toPos - fromPos;
        final distance = direction.distance;
        
        if (distance == 0) return const SizedBox.shrink();
        
        final normalizedDirection = direction / distance;
        final fromPoint = fromPos + normalizedDirection * fromRadius;
        final toPoint = toPos - normalizedDirection * toRadius;
        
        // Calculate the middle point and connection bounds
        final middlePoint = Offset(
          (fromPoint.dx + toPoint.dx) / 2,
          (fromPoint.dy + toPoint.dy) / 2,
        );
        
        // Create a hitbox around the connection line
        final hitboxSize = 20.0 * provider.scale.clamp(0.5, 2.0);
        
        return Positioned(
          left: middlePoint.dx - hitboxSize / 2,
          top: middlePoint.dy - hitboxSize / 2,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
              onTap: () {
                // Delete the connection when clicked while hovered
                if (_isHovered) {
                  provider.removeConnection(widget.connection.id);
                }
              },
              child: Container(
                width: hitboxSize,
                height: hitboxSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isHovered 
                      ? Colors.red.withValues(alpha: 0.3)
                      : Colors.transparent,
                ),
                child: _isHovered
                    ? Icon(
                        Icons.close,
                        color: Colors.white,
                        size: hitboxSize * 0.6,
                      )
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}