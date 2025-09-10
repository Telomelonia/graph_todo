import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/canvas_provider.dart';
import 'widgets/todo_node_widget.dart';
import 'widgets/connection_painter.dart';

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
              // Zoom In Button
              FloatingActionButton(
                heroTag: "zoomIn",
                onPressed: () {
                  final center = Offset(
                    MediaQuery.of(context).size.width / 2,
                    MediaQuery.of(context).size.height / 2,
                  );
                  provider.setZoom(provider.scale * 1.2, center);
                },
                backgroundColor: Colors.blue,
                mini: true,
                child: const Icon(Icons.zoom_in),
              ),
              const SizedBox(height: 5),
              // Zoom Out Button
              FloatingActionButton(
                heroTag: "zoomOut",
                onPressed: () {
                  final center = Offset(
                    MediaQuery.of(context).size.width / 2,
                    MediaQuery.of(context).size.height / 2,
                  );
                  provider.setZoom(provider.scale / 1.2, center);
                },
                backgroundColor: Colors.blue,
                mini: true,
                child: const Icon(Icons.zoom_out),
              ),
              const SizedBox(height: 5),
              // Reset Zoom Button
              FloatingActionButton(
                heroTag: "resetZoom",
                onPressed: () {
                  final center = Offset(
                    MediaQuery.of(context).size.width / 2,
                    MediaQuery.of(context).size.height / 2,
                  );
                  provider.setZoom(1.0, center);
                },
                backgroundColor: Colors.purple,
                mini: true,
                child: const Icon(Icons.center_focus_strong),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: "addNode",
                onPressed: provider.toggleAddNodeMode,
                backgroundColor: provider.isAddNodeMode
                    ? Colors.green
                    : Colors.grey,
                child: Icon(
                  provider.isAddNodeMode
                      ? Icons.add
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

class CanvasWidget extends StatelessWidget {
  const CanvasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CanvasProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
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
                provider.addNode(canvasPosition);
              }
            }
          },
          child: GestureDetector(
            onScaleStart: (details) {
              // Store initial state for scale gesture
            },
            onScaleUpdate: (details) {
              if (details.pointerCount == 1) {
                // Single finger - pan the canvas if no node is being dragged
                if (provider.draggedNode == null) {
                  provider.updatePanOffset(details.focalPointDelta);
                }
              } else if (details.pointerCount == 2) {
                // Two fingers - zoom the canvas
                provider.zoom(details.scale, details.localFocalPoint);
              }
            },
            onScaleEnd: (details) {
              // Reset scale gesture state
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

                // Add node mode indicator
                if (provider.isAddNodeMode)
                  Positioned(
                    top: 50,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.9),
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
