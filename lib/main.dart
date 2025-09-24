import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'providers/canvas_provider.dart';
import 'widgets/todo_node_widget.dart';
import 'widgets/connection_painter.dart';
import 'widgets/interactive_connection_widget.dart';
import 'widgets/connection_endpoint_widget.dart';

void main() {
  runApp(const GraphTodoApp());
}

class GraphTodoApp extends StatelessWidget {
  const GraphTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GraphTodo',
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
              FloatingActionButton(
                heroTag: "addNode",
                onPressed: provider.toggleAddNodeMode,
                backgroundColor: provider.isAddNodeMode
                    ? Colors.grey
                    : Colors.green,
                child: Icon(
                  provider.isAddNodeMode
                      ? Icons.close
                      : Icons.add,
                ),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: "connect",
                onPressed: provider.toggleConnectMode,
                backgroundColor: provider.isConnectMode
                    ? Colors.yellow
                    : Colors.indigo,
                child: Icon(
                  provider.isConnectMode
                      ? Icons.close
                      : Icons.link,
                ),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: "eraser",
                onPressed: provider.toggleEraserMode,
                backgroundColor: provider.isEraserMode
                    ? Colors.red
                    : Colors.orange,
                child: Icon(
                  provider.isEraserMode
                      ? Icons.close
                      : Icons.cleaning_services,
                ),
              ),
              const SizedBox(height: 10),
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
                child: const Icon(Icons.clear_all),
              ),
            ],
          );
        },
      ),
    );
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
              // Only create new node if in add node mode and not in connect mode
              if (!provider.isConnectMode && provider.isAddNodeMode) {
                // Check if tap is on any existing node using proper hit detection
                bool tappedOnNode = false;
                for (final node in provider.nodes) {
                  if (provider.isPointOnNode(details.localPosition, node)) {
                    tappedOnNode = true;
                    break;
                  }
                }

                // Create new node if not tapping on existing node
                if (!tappedOnNode) {
                  final canvasPosition = provider.screenToCanvas(details.localPosition);
                  provider.addNode(canvasPosition, viewSize: viewSize);
                }
              }
            },
            onScaleStart: (details) {
              // Store the current scale when gesture starts
              _lastScale = provider.scale;
            },
            onScaleUpdate: (details) {
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

                // Interactive connection deletion layer
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

                // Connection endpoint widgets for dragging
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

                // Nodes layer
                ...provider.nodes.map(
                      (node) => TodoNodeWidget(node: node),
                ),

                // Add node mode indicator
                if (provider.isAddNodeMode)
                  Positioned(
                    top: 50,
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

                // Connection mode indicator
                if (provider.isConnectMode)
                  Positioned(
                    top: 100,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.yellow.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        provider.selectedNodeForConnection == null
                            ? 'Select first node to connect'
                            : 'Select second node to connect',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Eraser mode indicator
                if (provider.isEraserMode)
                  Positioned(
                    top: 100,
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

                // Zoom level indicator
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${(provider.scale * 100).toInt()}%',
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
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1.0;

    // Only draw grid if scale is reasonable
    if (scale < 0.3) return;

    final scaledGridSize = gridSize * scale;

    // Calculate visible area
    final startX = (-panOffset.dx % scaledGridSize);
    final startY = (-panOffset.dy % scaledGridSize);

    // Draw vertical lines
    for (double x = startX; x < size.width; x += scaledGridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = startY; y < size.height; y += scaledGridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return scale != oldDelegate.scale || panOffset != oldDelegate.panOffset;
  }
}
