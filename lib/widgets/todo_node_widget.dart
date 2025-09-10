import 'package:flutter/material.dart';
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
  final TextEditingController _textController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _textController.text = widget.node.text;

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

    // Check if this is a newly created node that should start in editing mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CanvasProvider>();
      if (provider.newlyCreatedNodeId == widget.node.id) {
        setState(() {
          _isEditing = true;
        });
      }
    });
  }

  @override
  void didUpdateWidget(TodoNodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update text controller if node text changed externally
    if (widget.node.text != oldWidget.node.text) {
      _textController.text = widget.node.text;
    }

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
    _textController.dispose();
    super.dispose();
  }

  void _handleTap() {
    final provider = context.read<CanvasProvider>();

    if (provider.isEraserMode) {
      // Delete the node when in eraser mode
      provider.removeNode(widget.node.id);
    } else if (provider.isConnectMode) {
      provider.selectNodeForConnection(widget.node.id);
    } else {
      // Toggle completion
      provider.toggleNodeCompletion(widget.node.id);
    }
  }

  void _handleDoubleTap() {
    final provider = context.read<CanvasProvider>();
    if (!provider.isConnectMode && !provider.isEraserMode) {
      setState(() {
        _isEditing = true;
      });
    }
  }

  void _handleEditingComplete() {
    final provider = context.read<CanvasProvider>();

    // If the text is empty, set a default text
    final finalText = _textController.text.trim().isEmpty ? 'New Task' : _textController.text;

    provider.updateNodeText(widget.node.id, finalText);

    // Clear the newly created flag if this was a newly created node
    if (provider.newlyCreatedNodeId == widget.node.id) {
      provider.clearNewlyCreatedFlag();
    }

    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CanvasProvider>(
      builder: (context, provider, child) {
        // Convert canvas position to screen position
        final screenPosition = provider.canvasToScreen(widget.node.position);
        // Scale the node size based on canvas scale
        final scaledSize = widget.node.size * provider.scale;

        return Positioned(
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
              final canvasDelta = details.delta / provider.scale;
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
    if (_isEditing) {
      return Center(
        child: TextField(
          controller: _textController,
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(8),
          ),
          onSubmitted: (value) => _handleEditingComplete(),
          onTapOutside: (event) => _handleEditingComplete(),
          maxLines: null,
        ),
      );
    } else {
      return Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.node.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  decoration: widget.node.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
  }
}
