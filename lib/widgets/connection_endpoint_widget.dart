import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/connection.dart';
import '../models/todo_node.dart';
import '../providers/canvas_provider.dart';

class ConnectionEndpointWidget extends StatefulWidget {
  final Connection connection;
  final TodoNode fromNode;
  final TodoNode toNode;
  final bool isFromEndpoint; // true for 'from' endpoint, false for 'to' endpoint

  const ConnectionEndpointWidget({
    super.key,
    required this.connection,
    required this.fromNode,
    required this.toNode,
    required this.isFromEndpoint,
  });

  @override
  State<ConnectionEndpointWidget> createState() => _ConnectionEndpointWidgetState();
}

class _ConnectionEndpointWidgetState extends State<ConnectionEndpointWidget>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isDragging = false;
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _hoverController.forward();
    } else if (!_isDragging) {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CanvasProvider>(
      builder: (context, provider, child) {
        final currentNode = widget.isFromEndpoint ? widget.fromNode : widget.toNode;
        final otherNode = widget.isFromEndpoint ? widget.toNode : widget.fromNode;
        
        // Convert node positions to screen coordinates
        final currentPos = provider.canvasToScreen(currentNode.position);
        final otherPos = provider.canvasToScreen(otherNode.position);
        
        // Calculate connection points on node edges
        final currentRadius = (currentNode.size / 2) * provider.scale;
        
        final direction = otherPos - currentPos;
        final distance = direction.distance;
        
        if (distance == 0) return const SizedBox.shrink();
        
        final normalizedDirection = direction / distance;
        final endpointPosition = currentPos + normalizedDirection * currentRadius;
        
        final endpointSize = (8.0 * provider.scale).clamp(6.0, 16.0);
        
        return Positioned(
          left: endpointPosition.dx - endpointSize / 2,
          top: endpointPosition.dy - endpointSize / 2,
          child: MouseRegion(
            onEnter: (_) => _handleHover(true),
            onExit: (_) => _handleHover(false),
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _isDragging = true;
                });
                _hoverController.forward();
              },
              onPanUpdate: (details) {
                // Visual feedback could be added here during drag
              },
              onPanEnd: (details) {
                setState(() {
                  _isDragging = false;
                });
                
                if (!_isHovered) {
                  _hoverController.reverse();
                }
                
                // Find the closest node to drop the endpoint
                final dropPosition = details.globalPosition;
                TodoNode? targetNode;
                double minDistance = double.infinity;
                
                for (final node in provider.nodes) {
                  if (node.id == currentNode.id) continue; // Skip the current connected node
                  
                  final nodeScreenPos = provider.canvasToScreen(node.position);
                  final distance = (nodeScreenPos - dropPosition).distance;
                  final nodeRadius = (node.size / 2) * provider.scale;
                  
                  if (distance <= nodeRadius + 20 && distance < minDistance) {
                    minDistance = distance;
                    targetNode = node;
                  }
                }
                
                // If dropped on a valid node, update the connection
                if (targetNode != null) {
                  provider.updateConnectionEndpoint(
                    widget.connection.id,
                    widget.isFromEndpoint,
                    targetNode.id,
                  );
                }
              },
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: endpointSize,
                      height: endpointSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isHovered || _isDragging
                            ? Colors.blue.withValues(alpha: 0.9)
                            : Colors.white.withValues(alpha: 0.8),
                        border: Border.all(
                          color: _isHovered || _isDragging
                              ? Colors.white
                              : Colors.grey.withValues(alpha: 0.5),
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isHovered || _isDragging)
                                ? Colors.blue.withValues(alpha: 0.5)
                                : Colors.black.withValues(alpha: 0.3),
                            blurRadius: (_isHovered || _isDragging) ? 8.0 : 4.0,
                            spreadRadius: (_isHovered || _isDragging) ? 2.0 : 0.0,
                          ),
                        ],
                      ),
                      child: (_isHovered || _isDragging)
                          ? Icon(
                              Icons.drag_indicator,
                              size: endpointSize * 0.6,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}