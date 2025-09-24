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
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  late AnimationController _connectorPulseController;
  late Animation<double> _connectorPulseAnimation;
  late AnimationController _completionHoverController;
  late Animation<double> _completionHoverAnimation;
  late AnimationController _infoHoverController;
  late Animation<double> _infoHoverAnimation;
  final TextEditingController _textController = TextEditingController();
  bool _isEditing = false;
  bool _isHovered = false;
  bool _isCompletionHovered = false;
  bool _isInfoHovered = false;

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

    // Setup hover animation
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    // Setup connector pulse animation
    _connectorPulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _connectorPulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _connectorPulseController,
      curve: Curves.easeInOut,
    ));

    // Setup completion hover animation
    _completionHoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _completionHoverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _completionHoverController,
      curve: Curves.easeOutBack,
    ));

    // Setup info hover animation
    _infoHoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _infoHoverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _infoHoverController,
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
    _hoverController.dispose();
    _connectorPulseController.dispose();
    _completionHoverController.dispose();
    _infoHoverController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleTap() {
    final provider = context.read<CanvasProvider>();
    
    // Prevent interactions when info panel is open
    if (provider.isInfoPanelOpen) return;

    if (provider.isEraserMode) {
      // Delete the node when in eraser mode
      provider.removeNode(widget.node.id);
    } else if (provider.isConnectMode) {
      provider.selectNodeForConnection(widget.node.id);
    } else if (_isHovered && !provider.isConnectMode) {
      // If hovering and not in connect mode, start connection from this node
      provider.startConnectionFromNode(widget.node.id);
    }
    // Removed the else case - completion now happens only via the center hover area
  }

  void _handleHover(bool isHovered) {
    final provider = context.read<CanvasProvider>();
    
    // Don't show hover connector if in eraser mode, editing, or info panel is open
    if (provider.isEraserMode || _isEditing || provider.isInfoPanelOpen) return;
    
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _hoverController.forward();
      _connectorPulseController.repeat();
    } else {
      _hoverController.reverse();
      _connectorPulseController.stop();
    }
  }

  void _handleCompletionHover(bool isHovered) {
    final provider = context.read<CanvasProvider>();
    
    // Only show completion hover if not in special modes, not editing, and info panel is not open
    if (provider.isEraserMode || provider.isConnectMode || _isEditing || provider.isInfoPanelOpen) return;
    
    setState(() {
      _isCompletionHovered = isHovered;
    });

    if (isHovered) {
      _completionHoverController.forward();
    } else {
      _completionHoverController.reverse();
    }
  }

  void _handleInfoHover(bool isHovered) {
    final provider = context.read<CanvasProvider>();
    
    // Only show info hover if not in special modes, not editing, and info panel is not open
    if (provider.isEraserMode || provider.isConnectMode || _isEditing || provider.isInfoPanelOpen) return;
    
    setState(() {
      _isInfoHovered = isHovered;
    });

    if (isHovered) {
      _infoHoverController.forward();
    } else {
      _infoHoverController.reverse();
    }
  }

  void _handleCompletionTap() {
    final provider = context.read<CanvasProvider>();
    
    // Only allow completion toggle if not in special modes and info panel is not open
    if (!provider.isEraserMode && !provider.isConnectMode && !provider.isInfoPanelOpen) {
      provider.toggleNodeCompletion(widget.node.id);
    }
  }

  void _handleInfoTap() {
    final provider = context.read<CanvasProvider>();
    
    // Only allow info panel opening if not in special modes
    if (!provider.isEraserMode && !provider.isConnectMode && !provider.isInfoPanelOpen) {
      provider.showNodeInfo(widget.node.id);
    }
  }

  void _handleDoubleTap() {
    final provider = context.read<CanvasProvider>();
    if (!provider.isConnectMode && !provider.isEraserMode && !provider.isInfoPanelOpen) {
      // Get screen size for zoom calculation
      final mediaQuery = MediaQuery.maybeOf(context);
      if (mediaQuery != null) {
        final screenSize = mediaQuery.size;
        // Zoom to node with consistent 14% screen size ratio
        provider.zoomToNodeForEditing(widget.node.id, screenSize);
      }
      
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
          child: MouseRegion(
            onEnter: (_) => _handleHover(true),
            onExit: (_) => _handleHover(false),
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
                animation: Listenable.merge([_glowAnimation, _hoverAnimation, _connectorPulseAnimation, _completionHoverAnimation, _infoHoverAnimation]),
                builder: (context, child) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
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
                      ),
                      // Completion hover area in the center
                      _buildCompletionHoverArea(scaledSize, provider.scale),
                      // Info button hover area
                      _buildInfoHoverArea(scaledSize, provider.scale),
                      // Hover connector indicators
                      if (_isHovered && !provider.isEraserMode && !_isEditing && !provider.isConnectMode)
                        ..._buildConnectorIndicators(scaledSize, provider.scale),
                    ],
                  );
                },
              ),
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

  List<Widget> _buildConnectorIndicators(double scaledSize, double scale) {
    final radius = scaledSize / 2;
    final connectorSize = 6.0 * scale;
    final pulseValue = _connectorPulseAnimation.value;
    
    // Create 4 connector dots inside the node
    final positions = [
      Offset(0, -radius * 0.7), // Top
      Offset(radius * 0.7, 0), // Right
      Offset(0, radius * 0.7), // Bottom
      Offset(-radius * 0.7, 0), // Left
    ];
    
    return positions.asMap().entries.map((entry) {
      final position = entry.value;
      final pulseOffset = (pulseValue * 2 - 1).abs();
      
      return Positioned(
        left: scaledSize / 2 + position.dx - connectorSize / 2,
        top: scaledSize / 2 + position.dy - connectorSize / 2,
        child: FadeTransition(
          opacity: _hoverAnimation,
          child: Container(
            width: connectorSize + pulseOffset * 2,
            height: connectorSize + pulseOffset * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withValues(alpha: 0.8 - pulseOffset * 0.3),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.9),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.4),
                  blurRadius: 6.0,
                  spreadRadius: pulseOffset * 1.5,
                ),
              ],
            ),
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: connectorSize * 0.6,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildCompletionHoverArea(double scaledSize, double scale) {
    final provider = context.watch<CanvasProvider>();
    
    // Don't show completion hover area if in special modes or editing
    if (provider.isEraserMode || provider.isConnectMode || _isEditing) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      left: scaledSize * 0.375,  // Center a smaller area (25% of node size)
      top: scaledSize * 0.375,
      child: MouseRegion(
        onEnter: (_) => _handleCompletionHover(true),
        onExit: (_) => _handleCompletionHover(false),
        child: GestureDetector(
          onTap: _handleCompletionTap,
          child: AnimatedBuilder(
            animation: _completionHoverAnimation,
            builder: (context, child) {
              final hoverValue = _completionHoverAnimation.value;
              final baseSize = scaledSize * 0.25;  // Smaller base size (25% of node)
              final animatedSize = baseSize + (hoverValue * baseSize * 0.2);  // Less expansion
              
              // Calculate offset to keep it centered as it expands
              final sizeOffset = (animatedSize - baseSize) / 2;
              
              return Transform.translate(
                offset: Offset(-sizeOffset, -sizeOffset),
                child: Container(
                  width: animatedSize,
                  height: animatedSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isCompletionHovered
                        ? (widget.node.isCompleted 
                            ? Colors.orange.withValues(alpha: 0.3 + hoverValue * 0.4)
                            : Colors.green.withValues(alpha: 0.3 + hoverValue * 0.4))
                        : Colors.transparent,
                    border: _isCompletionHovered
                        ? Border.all(
                            color: widget.node.isCompleted 
                                ? Colors.orange.withValues(alpha: 0.8)
                                : Colors.green.withValues(alpha: 0.8),
                            width: 1.5 + hoverValue * 1.5,  // Smaller border
                          )
                        : null,
                    boxShadow: _isCompletionHovered
                        ? [
                            BoxShadow(
                              color: (widget.node.isCompleted 
                                  ? Colors.orange 
                                  : Colors.green).withValues(alpha: 0.4 * hoverValue),
                              blurRadius: 6.0 * hoverValue,  // Smaller glow
                              spreadRadius: 2.0 * hoverValue,
                            ),
                          ]
                        : null,
                  ),
                  child: _isCompletionHovered
                      ? Center(
                          child: Icon(
                            widget.node.isCompleted ? Icons.refresh : Icons.check,
                            color: widget.node.isCompleted ? Colors.orange : Colors.green,
                            size: (12.0 + hoverValue * 6.0) * scale.clamp(0.5, 2.0),  // Smaller icon
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoHoverArea(double scaledSize, double scale) {
    final provider = context.watch<CanvasProvider>();
    
    // Don't show info hover area if in special modes, editing, or info panel is open
    if (provider.isEraserMode || provider.isConnectMode || _isEditing || provider.isInfoPanelOpen) {
      return const SizedBox.shrink();
    }
    
    // Create a larger hover area (1.5x node size) but position the info button in top-right
    final hoverRadius = scaledSize * 0.75; // 1.5x radius (since scaledSize is diameter)
    final buttonOffset = scaledSize * 0.3; // Position in top-right quadrant
    
    return Positioned(
      left: scaledSize / 2 - hoverRadius, // Center the hover area
      top: scaledSize / 2 - hoverRadius,
      child: MouseRegion(
        onEnter: (_) => _handleInfoHover(true),
        onExit: (_) => _handleInfoHover(false),
        child: GestureDetector(
          onTap: _handleInfoTap,
          child: Container(
            width: hoverRadius * 2, // Full hover area
            height: hoverRadius * 2,
            color: Colors.transparent,
            child: Stack(
              children: [
                // Position info button in top-right of hover area
                Positioned(
                  right: hoverRadius - buttonOffset,
                  top: hoverRadius - buttonOffset,
                  child: AnimatedBuilder(
                    animation: _infoHoverAnimation,
                    builder: (context, child) {
                      final hoverValue = _infoHoverAnimation.value;
                      final buttonSize = (16.0 + hoverValue * 4.0) * scale.clamp(0.5, 2.0);
                      
                      return Container(
                        width: buttonSize,
                        height: buttonSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isInfoHovered
                              ? Colors.blue.withValues(alpha: 0.8 + hoverValue * 0.2)
                              : Colors.grey.withValues(alpha: 0.6),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.9),
                            width: 1.0 + hoverValue * 0.5,
                          ),
                          boxShadow: _isInfoHovered
                              ? [
                                  BoxShadow(
                                    color: Colors.blue.withValues(alpha: 0.5 * hoverValue),
                                    blurRadius: 4.0 * hoverValue,
                                    spreadRadius: 1.0 * hoverValue,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: buttonSize * 0.6,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
