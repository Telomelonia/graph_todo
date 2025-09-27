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
        
        // Create a larger hitbox around the connection line for better interaction
        final hitboxSize = 32.0 * provider.scale.clamp(0.8, 2.0);
        
        return Positioned(
          left: middlePoint.dx - hitboxSize / 2,
          top: middlePoint.dy - hitboxSize / 2,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
              onTap: () {
                // Delete the connection when clicked
                provider.removeConnection(widget.connection.id);
              },
              child: Container(
                width: hitboxSize,
                height: hitboxSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isHovered 
                      ? Colors.red.withValues(alpha: 0.5)
                      : Colors.transparent,
                  border: _isHovered 
                      ? Border.all(
                          color: Colors.red.withValues(alpha: 0.9),
                          width: 2.5,
                        )
                      : null,
                  // Add shadow for better visibility over nodes
                  boxShadow: _isHovered ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: _isHovered 
                    ? Icon(
                        Icons.close,
                        color: Colors.white,
                        size: hitboxSize * 0.4,
                      )
                    : SizedBox(
                        // Invisible but clickable area when not hovered
                        width: hitboxSize,
                        height: hitboxSize,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}