import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_node.dart';
import '../providers/canvas_provider.dart';

class InfoPanelWidget extends StatefulWidget {
  final TodoNode node;

  const InfoPanelWidget({
    super.key,
    required this.node,
  });

  @override
  State<InfoPanelWidget> createState() => _InfoPanelWidgetState();
}

class _InfoPanelWidgetState extends State<InfoPanelWidget> {
  late TextEditingController _descriptionController;
  late Color _selectedColor;

  // Predefined color options
  final List<Color> _colorOptions = [
    const Color(0xFF6366F1), // Indigo (default)
    const Color(0xFFEF4444), // Red
    const Color(0xFF10B981), // Green
    const Color(0xFFF59E0B), // Yellow
    const Color(0xFF3B82F6), // Blue
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFFEC4899), // Pink
    const Color(0xFFF97316), // Orange
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFF84CC16), // Lime
  ];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.node.description);
    _selectedColor = widget.node.color;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final provider = context.read<CanvasProvider>();
    
    // Update description if changed
    if (_descriptionController.text != widget.node.description) {
      provider.updateNodeDescription(widget.node.id, _descriptionController.text);
    }
    
    // Update color if changed
    if (_selectedColor != widget.node.color) {
      provider.updateNodeColor(widget.node.id, _selectedColor);
    }
    
    // Close the panel
    provider.hideNodeInfo();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CanvasProvider>();
    final screenSize = MediaQuery.of(context).size;
    
    // Calculate responsive panel dimensions
    final panelWidth = (screenSize.width * 0.85).clamp(280.0, 400.0);
    final panelHeight = (screenSize.height * 0.7).clamp(300.0, 500.0);
    
    // Calculate ideal positions to center both node and panel in view
    final screenCenter = Offset(screenSize.width / 2, screenSize.height / 2);
    
    // For mobile screens (narrow), position panel below the centered node
    // For larger screens, position panel to the side
    final isMobile = screenSize.width < 600;
    
    late double panelLeft;
    late double panelTop;
    late double targetScale;
    late Offset nodeTargetPosition;
    
    if (isMobile) {
      // Mobile layout: node at top center, panel below
      targetScale = 1.2;
      nodeTargetPosition = Offset(screenCenter.dx, screenSize.height * 0.25);
      panelLeft = (screenSize.width - panelWidth) / 2;
      panelTop = screenSize.height * 0.45;
    } else {
      // Desktop layout: node on left, panel on right, both centered vertically
      targetScale = 1.5;
      nodeTargetPosition = Offset(screenSize.width * 0.3, screenCenter.dy);
      panelLeft = screenSize.width * 0.55;
      panelTop = (screenSize.height - panelHeight) / 2;
      
      // Ensure panel doesn't go off screen
      if (panelLeft + panelWidth > screenSize.width - 20) {
        panelLeft = screenSize.width - panelWidth - 20;
      }
    }
    
    // Ensure panel fits on screen
    panelLeft = panelLeft.clamp(20.0, screenSize.width - panelWidth - 20);
    panelTop = panelTop.clamp(20.0, screenSize.height - panelHeight - 20);
    
    // Auto-adjust view to center node and panel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetPanOffset = nodeTargetPosition - (widget.node.position * targetScale);
      if ((provider.panOffset - targetPanOffset).distance > 10 || 
          (provider.scale - targetScale).abs() > 0.1) {
        provider.updatePanOffset(targetPanOffset - provider.panOffset);
        provider.updateScale(targetScale);
      }
    });

    return Positioned(
      left: panelLeft,
      top: panelTop,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: panelWidth,
          height: panelHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.node.text.isEmpty ? 'New Task' : widget.node.text,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => provider.hideNodeInfo(),
                      icon: const Icon(Icons.close),
                      iconSize: 18,
                      color: Colors.white.withValues(alpha: 0.7),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description field
                      Text(
                        'Description:',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add a description...',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.blue, width: 2),
                          ),
                          contentPadding: const EdgeInsets.all(10),
                          filled: true,
                          fillColor: Colors.black.withValues(alpha: 0.2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Color picker
                      Text(
                        'Color:',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _colorOptions.map((color) {
                          final isSelected = _selectedColor == color;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: isSelected ? 2 : 0,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.white.withValues(alpha: 0.3),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Action buttons
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => provider.hideNodeInfo(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}