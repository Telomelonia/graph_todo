import 'package:flutter/foundation.dart';
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

// ignore_for_file: unused_field
class _InteractiveConnectionWidgetState extends State<InteractiveConnectionWidget>
    with TickerProviderStateMixin {
  bool _isHovered = false;
  bool _isHolding = false;
  double _holdProgress = 0.0;
  AnimationController? _holdAnimationController;
  Animation<double>? _holdAnimation;

  @override
  void initState() {
    super.initState();
    // Only initialize animation controller for mobile platforms
    if (!_shouldUseInstantDelete) {
      _holdAnimationController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      );
      _holdAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _holdAnimationController!, curve: Curves.linear),
      );
      _holdAnimation!.addListener(() {
        setState(() {
          _holdProgress = _holdAnimation!.value;
        });
      });
      _holdAnimation!.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // Delete connection when animation completes
          Provider.of<CanvasProvider>(context, listen: false)
              .removeConnection(widget.connection.id);
        }
      });
    }
  }

  @override
  void dispose() {
    _holdAnimationController?.dispose();
    super.dispose();
  }

  void _startHolding() {
    if (!_shouldUseInstantDelete) {
      setState(() {
        _isHolding = true;
      });
      _holdAnimationController?.forward();
    }
  }

  void _stopHolding() {
    if (!_shouldUseInstantDelete) {
      setState(() {
        _isHolding = false;
        _holdProgress = 0.0;
      });
      _holdAnimationController?.reset();
    }
  }

  bool get _shouldUseInstantDelete {
    // Use instant delete for desktop platforms (macOS, Windows, Linux) and web
    return kIsWeb || 
           defaultTargetPlatform == TargetPlatform.macOS ||
           defaultTargetPlatform == TargetPlatform.windows ||
           defaultTargetPlatform == TargetPlatform.linux;
  }

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
              onTap: _shouldUseInstantDelete ? () {
                // Instant delete for desktop and web platforms
                provider.removeConnection(widget.connection.id);
              } : null,
              onLongPressStart: !_shouldUseInstantDelete ? (_) => _startHolding() : null,
              onLongPressEnd: !_shouldUseInstantDelete ? (_) => _stopHolding() : null,
              onLongPressCancel: !_shouldUseInstantDelete ? () => _stopHolding() : null,
              child: Container(
                width: hitboxSize,
                height: hitboxSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (!_shouldUseInstantDelete && _isHolding)
                      ? Colors.red.withValues(alpha: 0.3 + (_holdProgress * 0.4))
                      : _isHovered 
                          ? Colors.red.withValues(alpha: 0.5)
                          : Colors.transparent,
                  border: ((!_shouldUseInstantDelete && _isHolding) || _isHovered) 
                      ? Border.all(
                          color: (!_shouldUseInstantDelete && _isHolding)
                              ? Colors.red.withValues(alpha: 0.7 + (_holdProgress * 0.3))
                              : Colors.red.withValues(alpha: 0.9),
                          width: (!_shouldUseInstantDelete && _isHolding) ? 3.0 + (_holdProgress * 2.0) : 2.5,
                        )
                      : null,
                  // Add shadow for better visibility over nodes
                  boxShadow: (_isHovered || (!_shouldUseInstantDelete && _isHolding)) ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: (!_shouldUseInstantDelete && _isHolding) ? 6.0 + (_holdProgress * 4.0) : 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: (!_shouldUseInstantDelete && _isHolding)
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          // Progress indicator
                          CircularProgressIndicator(
                            value: _holdProgress,
                            strokeWidth: 3.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withValues(alpha: 0.9),
                            ),
                            backgroundColor: Colors.white.withValues(alpha: 0.3),
                          ),
                          // Delete icon
                          Icon(
                            Icons.delete_forever,
                            color: Colors.white,
                            size: hitboxSize * 0.3,
                          ),
                        ],
                      )
                    : _isHovered 
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