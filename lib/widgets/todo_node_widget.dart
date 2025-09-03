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

    if (provider.isConnectMode) {
      provider.selectNodeForConnection(widget.node.id);
    } else {
      // Toggle completion
      provider.toggleNodeCompletion(widget.node.id);
    }
  }

  void _handleDoubleTap() {
    if (!context.read<CanvasProvider>().isConnectMode) {
      setState(() {
        _isEditing = true;
      });
    }
  }

  void _handleEditingComplete() {
    final provider = context.read<CanvasProvider>();
    provider.updateNodeText(widget.node.id, _textController.text);
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.node.position.dx - widget.node.size / 2,
      top: widget.node.position.dy - widget.node.size / 2,
      child: GestureDetector(
        onTap: _handleTap,
        onDoubleTap: _handleDoubleTap,
        onPanStart: (details) {
          context.read<CanvasProvider>().startDrag(widget.node);
        },
        onPanUpdate: (details) {
          final provider = context.read<CanvasProvider>();
          final newPosition = provider.screenToCanvas(
            widget.node.position + details.delta,
          );
          provider.updateNodePosition(widget.node.id, newPosition);
        },
        onPanEnd: (details) {
          context.read<CanvasProvider>().endDrag();
        },
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              width: widget.node.size,
              height: widget.node.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.node.color.withOpacity(0.9),
                border: Border.all(
                  color: _getSelectionColor(),
                  width: _getSelectionWidth(),
                ),
                boxShadow: _buildShadows(),
              ),
              child: _buildContent(),
            );
          },
        ),
      ),
    );
  }

  Color _getSelectionColor() {
    final provider = context.watch<CanvasProvider>();

    if (provider.selectedNodeForConnection == widget.node.id) {
      return Colors.yellow;
    } else if (provider.isConnectMode) {
      return Colors.white.withOpacity(0.5);
    } else {
      return Colors.transparent;
    }
  }

  double _getSelectionWidth() {
    final provider = context.watch<CanvasProvider>();

    if (provider.selectedNodeForConnection == widget.node.id) {
      return 3.0;
    } else if (provider.isConnectMode) {
      return 2.0;
    } else {
      return 0.0;
    }
  }

  List<BoxShadow> _buildShadows() {
    List<BoxShadow> shadows = [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 8.0,
        offset: const Offset(0, 4),
      ),
    ];

    // Add glow effect when completed
    if (widget.node.isCompleted) {
      shadows.add(
        BoxShadow(
          color: Colors.green.withOpacity(0.6 * _glowAnimation.value),
          blurRadius: 20.0 * _glowAnimation.value,
          spreadRadius: 5.0 * _glowAnimation.value,
        ),
      );
    }

    return shadows;
  }

  Widget _buildContent() {
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
