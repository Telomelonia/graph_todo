import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'providers/canvas_provider.dart';
import 'widgets/todo_node_widget.dart';
import 'widgets/connection_painter.dart';
import 'widgets/interactive_connection_widget.dart';
import 'widgets/connection_endpoint_widget.dart';
import 'widgets/info_panel_widget.dart';

void main() {
  runApp(const GraphTodoApp());
}

class GraphTodoApp extends StatelessWidget {
  const GraphTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GraphTodo - Visual Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: ChangeNotifierProvider(
        create: (context) => CanvasProvider(),
        child: const HomePage(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: const CanvasWidget(),
      floatingActionButton: Consumer<CanvasProvider>(
        builder: (context, provider, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Import button
              FloatingActionButton(
                heroTag: "import",
                onPressed: () => _handleImport(context, provider),
                backgroundColor: Colors.blue,
                tooltip: 'Import Data',
                child: const Icon(
                  Icons.upload_file,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              // Export button
              FloatingActionButton(
                heroTag: "export",
                onPressed: () => _handleExport(context, provider),
                backgroundColor: Colors.orange,
                tooltip: 'Export Data',
                child: const Icon(
                  Icons.download,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              // Add node button
              FloatingActionButton(
                heroTag: "addNode",
                onPressed: provider.toggleAddNodeMode,
                backgroundColor: provider.isAddNodeMode
                    ? Colors.grey
                    : Colors.green,
                tooltip: provider.isAddNodeMode ? 'Cancel' : 'Add Node',
                child: Icon(
                  provider.isAddNodeMode
                      ? Icons.close
                      : Icons.add,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              // Clear canvas button
              FloatingActionButton(
                heroTag: "clear",
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear Canvas'),
                      content: const Text('Remove all nodes and connections?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            provider.clearCanvas();
                            Navigator.pop(context);
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                },
                backgroundColor: Colors.red,
                tooltip: 'Clear Canvas',
                child: const Icon(
                  Icons.clear_all,
                  color: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleExport(BuildContext context, CanvasProvider provider) async {
    if (provider.nodes.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No data to export. Create some nodes first!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      final result = await provider.exportData();
      if (!context.mounted) return;
      
      if (result != null) {
        if (result == 'cancelled') {
          // User cancelled the save dialog - no need to show message
          return;
        } else if (kIsWeb) {
          // For web, show simpler message since download happens immediately
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data exported successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Show the file path where it was saved
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Data exported successfully!\nSaved to: $result'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to export data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleImport(BuildContext context, CanvasProvider provider) async {
    // Show confirmation dialog if there's existing data
    if (provider.nodes.isNotEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import Data'),
          content: const Text(
            'This will replace all current data. Are you sure you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Import'),
            ),
          ],
        ),
      );
      
      if (confirmed != true) return;
    }

    try {
      final result = await provider.importData();
      if (!context.mounted) return;
      
      if (result.cancelled) {
        return; // User cancelled, no message needed
      }
      
      if (result.success) {
        provider.loadImportedData(result);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Data imported successfully!\n'
              '${result.nodes?.length ?? 0} nodes, ${result.connections?.length ?? 0} connections',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: ${result.error}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class CanvasWidget extends StatefulWidget {
  const CanvasWidget({super.key});

  @override
  State<CanvasWidget> createState() => _CanvasWidgetState();
}

class _CanvasWidgetState extends State<CanvasWidget> {
  double _lastScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewSize = Size(constraints.maxWidth, constraints.maxHeight);
        
        return Consumer<CanvasProvider>(
          builder: (context, provider, child) {
            return Listener(
          onPointerSignal: (pointerSignal) {
            if (pointerSignal is PointerScrollEvent) {
              final deltaY = pointerSignal.scrollDelta.dy;
              final deltaX = pointerSignal.scrollDelta.dx;
              
              // Handle both mouse wheel and trackpad scroll for zoom
              if (deltaY.abs() > 0.1) {
                final zoomFactor = deltaY > 0 ? 1.05 : 0.95;
                final newScale = provider.scale * zoomFactor;
                provider.setZoom(newScale, pointerSignal.localPosition);
              }
              // Handle horizontal trackpad scroll for panning
              else if (deltaX.abs() > 0.1) {
                provider.updatePanOffset(Offset(deltaX * -1.5, 0));
              }
            }
          },
          child: GestureDetector(
            onTapUp: (details) {
              // Check if tap is on any existing node using proper hit detection
              bool tappedOnNode = false;
              for (final node in provider.nodes) {
                if (provider.isPointOnNode(details.localPosition, node)) {
                  tappedOnNode = true;
                  break;
                }
              }

              // If clicking on empty canvas, hide action buttons and info panel
              if (!tappedOnNode) {
                provider.hideNodeActionButtons();
                if (provider.isInfoPanelOpen) {
                  provider.hideNodeInfo();
                  return;
                }
              }
              
              // Only create new node if in add node mode and not in connect mode
              if (!provider.isConnectMode && provider.isAddNodeMode && !tappedOnNode) {
                final canvasPosition = provider.screenToCanvas(details.localPosition);
                provider.addNode(canvasPosition, viewSize: viewSize);
              }
            },
            onScaleStart: (details) {
              // Store the current scale when gesture starts
              _lastScale = provider.scale;
            },
            onScaleUpdate: (details) {
              // Prevent panning when info panel is open
              if (provider.isInfoPanelOpen) return;
              
              if (details.pointerCount == 1) {
                // Single finger/mouse - pan the canvas if no node is being dragged
                if (provider.draggedNode == null) {
                  // Increased sensitivity for web platform mouse panning
                  const sensitivity = kIsWeb ? 2.2 : 1.8;
                  provider.updatePanOffset(details.focalPointDelta * sensitivity);
                }
              } else if (details.pointerCount == 2) {
                // Two fingers - enhanced trackpad gesture handling
                final scaleChange = (details.scale - 1.0).abs();
                
                if (scaleChange > 0.005) {
                  // Pinch-to-zoom gesture detected - prioritize zoom over pan
                  final newScale = _lastScale * details.scale;
                  provider.setZoom(newScale, details.localFocalPoint);
                } else if (details.focalPointDelta.distance > 2.0) {
                  // Two-finger pan gesture - only if not zooming
                  provider.updatePanOffset(details.focalPointDelta * 1.8);
                }
              }
            },
            onScaleEnd: (details) {
              // Update the last scale for next gesture
              _lastScale = provider.scale;
            },
            child: Stack(
              children: [
                // Background grid (optional)
                CustomPaint(
                  painter: GridPainter(
                    scale: provider.scale,
                    panOffset: provider.panOffset,
                  ),
                  size: Size.infinite,
                ),

                // Connections layer
                CustomPaint(
                  painter: ConnectionPainter(
                    connections: provider.connections,
                    nodes: provider.nodes,
                    scale: provider.scale,
                    panOffset: provider.panOffset,
                  ),
                  size: Size.infinite,
                ),

                // Nodes layer
                ...provider.nodes.map(
                      (node) => TodoNodeWidget(node: node),
                ),

                // Interactive connection deletion layer (rendered on top of nodes for better hover detection)
                ...provider.connections.map((connection) {
                  final fromNode = provider.nodes.firstWhere(
                    (node) => node.id == connection.fromNodeId,
                    orElse: () => throw Exception('From node not found'),
                  );
                  final toNode = provider.nodes.firstWhere(
                    (node) => node.id == connection.toNodeId,
                    orElse: () => throw Exception('To node not found'),
                  );
                  
                  return InteractiveConnectionWidget(
                    key: Key(connection.id),
                    connection: connection,
                    fromNode: fromNode,
                    toNode: toNode,
                  );
                }),

                // Connection endpoint widgets for dragging (on top for interaction)
                ...provider.connections.expand((connection) {
                  final fromNode = provider.nodes.firstWhere(
                    (node) => node.id == connection.fromNodeId,
                    orElse: () => throw Exception('From node not found'),
                  );
                  final toNode = provider.nodes.firstWhere(
                    (node) => node.id == connection.toNodeId,
                    orElse: () => throw Exception('To node not found'),
                  );
                  
                  return [
                    ConnectionEndpointWidget(
                      key: Key('${connection.id}_from'),
                      connection: connection,
                      fromNode: fromNode,
                      toNode: toNode,
                      isFromEndpoint: true,
                    ),
                    ConnectionEndpointWidget(
                      key: Key('${connection.id}_to'),
                      connection: connection,
                      fromNode: fromNode,
                      toNode: toNode,
                      isFromEndpoint: false,
                    ),
                  ];
                }),

                // Info panel layer
                if (provider.isInfoPanelOpen && provider.nodeShowingInfo != null)
                  Builder(
                    builder: (context) {
                      final node = provider.nodes.firstWhere(
                        (n) => n.id == provider.nodeShowingInfo,
                        orElse: () => throw Exception('Node showing info not found'),
                      );
                      return InfoPanelWidget(node: node);
                    },
                  ),

                // Add node mode indicator
                if (provider.isAddNodeMode)
                  Positioned(
                    top: 70,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Click anywhere to add a new node',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Eraser mode indicator
                if (provider.isEraserMode)
                  Positioned(
                    top: 70,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Click any node to delete it',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Controls instruction (only for web)
                if (kIsWeb)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Scroll wheel: zoom • Drag: pan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),

                // Zoom level indicator (top left)
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Zoom: ${(provider.scale * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        );
          },
        );
      },
    );
  }
}

class GridPainter extends CustomPainter {
  final double scale;
  final Offset panOffset;

  GridPainter({required this.scale, required this.panOffset});

  @override
  void paint(Canvas canvas, Size size) {
    const gridSize = 50.0;
    const smallGridSize = 10.0; // Smaller grid for high zoom levels

    // Main grid paint (normal opacity)
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1.0;

    // Small grid paint (slightly more subtle)
    final smallPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;

    // Draw main grid (always visible above 30% zoom)
    final scaledGridSize = gridSize * scale;
    final gridOffsetX = panOffset.dx % scaledGridSize;
    final gridOffsetY = panOffset.dy % scaledGridSize;

    // Draw main grid vertical lines
    for (double x = gridOffsetX; x < size.width; x += scaledGridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw main grid horizontal lines
    for (double y = gridOffsetY; y < size.height; y += scaledGridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw smaller grid when zoomed in beyond 500% (scale > 5.0)
    if (scale > 5.0) {
      final scaledSmallGridSize = smallGridSize * scale;
      final smallGridOffsetX = panOffset.dx % scaledSmallGridSize;
      final smallGridOffsetY = panOffset.dy % scaledSmallGridSize;

      // Draw small grid vertical lines
      for (double x = smallGridOffsetX; x < size.width; x += scaledSmallGridSize) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), smallPaint);
      }

      // Draw small grid horizontal lines
      for (double y = smallGridOffsetY; y < size.height; y += scaledSmallGridSize) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), smallPaint);
      }
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return scale != oldDelegate.scale || panOffset != oldDelegate.panOffset;
  }
}
