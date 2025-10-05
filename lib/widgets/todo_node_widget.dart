import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../models/todo_node.dart';
import '../providers/canvas_provider.dart';

class TodoNodeWidget extends StatefulWidget {
  final TodoNode node;

  const TodoNodeWidget({
    super.key,
    required this.node,
  });

  @override
  State<TodoNodeWidget> createState() => _TodoNodeWidgetState();
}

class _TodoNodeWidgetState extends State<TodoNodeWidget>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Setup glow animation for completion
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Start glow animation if node is completed
    if (widget.node.isCompleted) {
      _glowController.forward();
    }

    // Check if this is a newly created node that should open info panel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CanvasProvider>();
      if (provider.newlyCreatedNodeId == widget.node.id) {
        provider.showNodeInfo(widget.node.id);
        provider.clearNewlyCreatedFlag();
      }
    });
  }

  @override
  void didUpdateWidget(TodoNodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle completion animation
    if (widget.node.isCompleted != oldWidget.node.isCompleted) {
      if (widget.node.isCompleted) {
        _glowController.forward();
      } else {
        _glowController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _handleTap() {
    final provider = context.read<CanvasProvider>();
    
    // Prevent interactions when info panel is open
    if (provider.isInfoPanelOpen) return;

    // Handle special modes
    if (provider.isEraserMode) {
      provider.removeNode(widget.node.id);
      return;
    } else if (provider.isConnectMode) {
      provider.selectNodeForConnection(widget.node.id);
      return;
    }

    // In normal mode, toggle action buttons
    provider.toggleNodeActionButtons(widget.node.id);
  }

  void _handleCompletionTap() {
    final provider = context.read<CanvasProvider>();
    provider.toggleNodeCompletion(widget.node.id);
    provider.hideNodeActionButtons();
  }

  void _handleConnectorTap() {
    final provider = context.read<CanvasProvider>();
    provider.startConnectionFromNode(widget.node.id);
    provider.hideNodeActionButtons();
  }

  void _handleDeleteTap() {
    final provider = context.read<CanvasProvider>();
    provider.removeNode(widget.node.id);
  }

  void _handleInfoTap() {
    final provider = context.read<CanvasProvider>();
    provider.showNodeInfo(widget.node.id);
    provider.hideNodeActionButtons();
  }

  void _handleDoubleTap() {
    final provider = context.read<CanvasProvider>();
    if (!provider.isConnectMode && !provider.isEraserMode && !provider.isInfoPanelOpen) {
      // Open info panel for editing
      provider.showNodeInfo(widget.node.id);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<CanvasProvider>(
      builder: (context, provider, child) {
        // Convert canvas position to screen position
        final screenPosition = provider.canvasToScreen(widget.node.position);
        // Scale the node size based on canvas scale
        final scaledSize = widget.node.size * provider.scale;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Main node
            Positioned(
              left: screenPosition.dx - scaledSize / 2,
              top: screenPosition.dy - scaledSize / 2,
              child: GestureDetector(
                onTap: _handleTap,
                onDoubleTap: _handleDoubleTap,
                onPanStart: (details) {
                  context.read<CanvasProvider>().startDrag(widget.node);
                },
                onPanUpdate: (details) {
                  final provider = context.read<CanvasProvider>();
                  // Convert screen delta to canvas coordinates and update position
                  // Increased sensitivity for web platform mouse dragging
                  const sensitivity = kIsWeb ? 2.0 : 1.6;
                  final canvasDelta = (details.delta * sensitivity) / provider.scale;
                  final newPosition = widget.node.position + canvasDelta;
                  provider.updateNodePosition(widget.node.id, newPosition);
                },
                onPanEnd: (details) {
                  context.read<CanvasProvider>().endDrag();
                },
                child: AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      width: scaledSize,
                      height: scaledSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.node.color.withValues(alpha: 0.9),
                        border: Border.all(
                          color: _getSelectionColor(),
                          width: _getSelectionWidth() * provider.scale,
                        ),
                        boxShadow: _buildShadows(provider.scale),
                      ),
                      child: _buildContent(provider.scale),
                    );
                  },
                ),
              ),
            ),
            // Action buttons (separate from node gesture detector)
            if (provider.nodeWithActiveButtons == widget.node.id)
              ..._buildActionButtons(screenPosition.dx, screenPosition.dy, scaledSize, provider.scale),
          ],
        );
      },
    );
  }

  Color _getSelectionColor() {
    final provider = context.watch<CanvasProvider>();

    if (provider.selectedNodeForConnection == widget.node.id) {
      return Colors.yellow;
    } else if (provider.isEraserMode) {
      return Colors.red;
    } else if (provider.isConnectMode) {
      return Colors.white.withValues(alpha: 0.5);
    } else {
      return Colors.transparent;
    }
  }

  double _getSelectionWidth() {
    final provider = context.watch<CanvasProvider>();

    if (provider.selectedNodeForConnection == widget.node.id) {
      return 3.0;
    } else if (provider.isEraserMode) {
      return 2.5;
    } else if (provider.isConnectMode) {
      return 2.0;
    } else {
      return 0.0;
    }
  }

  List<BoxShadow> _buildShadows(double scale) {
    List<BoxShadow> shadows = [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 8.0 * scale,
        offset: const Offset(0, 4),
      ),
    ];

    // Add glow effect when completed
    if (widget.node.isCompleted) {
      shadows.add(
        BoxShadow(
          color: Colors.green.withValues(alpha: 0.6 * _glowAnimation.value),
          blurRadius: 20.0 * _glowAnimation.value,
          spreadRadius: 5.0 * _glowAnimation.value,
        ),
      );
    }

    return shadows;
  }

  Widget _buildContent(double scale) {
    return Stack(
      children: [
        // Main icon display
        Center(
          child: Text(
            widget.node.icon,
            style: TextStyle(
              fontSize: 48 * scale.clamp(0.5, 1.2),
              decoration: widget.node.isCompleted
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
        ),
        // Checkmark overlay for completed tasks
        if (widget.node.isCompleted)
          Positioned(
            right: 4,
            top: 4,
            child: FadeTransition(
              opacity: _glowAnimation,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildActionButtons(double centerX, double centerY, double scaledSize, double scale) {
    final buttonSize = 32.0 * scale.clamp(0.8, 1.5);
    final radius = scaledSize / 2 + buttonSize + 8;
    
    // Define button positions around the node (top, right, bottom, left)
    final buttonPositions = [
      {'offset': Offset(0, -radius), 'icon': widget.node.isCompleted ? Icons.refresh : Icons.check, 'color': widget.node.isCompleted ? Colors.orange : Colors.green, 'onTap': _handleCompletionTap},
      {'offset': Offset(radius, 0), 'icon': Icons.link, 'color': Colors.purple, 'onTap': _handleConnectorTap},
      {'offset': Offset(0, radius), 'icon': Icons.delete, 'color': Colors.red, 'onTap': _handleDeleteTap},
      {'offset': Offset(-radius, 0), 'icon': Icons.info, 'color': Colors.blue, 'onTap': _handleInfoTap},
    ];

    return buttonPositions.asMap().entries.map((entry) {
      final index = entry.key;
      final buttonData = entry.value;
      final offset = buttonData['offset'] as Offset;
      final icon = buttonData['icon'] as IconData;
      final color = buttonData['color'] as Color;
      final onTap = buttonData['onTap'] as VoidCallback;
      
      return Positioned(
        left: centerX + offset.dx - buttonSize / 2,
        top: centerY + offset.dy - buttonSize / 2,
        child: AnimatedScale(
          scale: 1.0,
          duration: Duration(milliseconds: 300 + (index * 75)),
          curve: Curves.elasticOut,
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: Duration(milliseconds: 200 + (index * 50)),
            curve: Curves.easeOut,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.9),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8.0,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 12.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: buttonSize * 0.5,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}