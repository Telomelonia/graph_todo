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
            // Only create new node if not in connect mode and not tapping on existing node
            if (!provider.isConnectMode) {
              final canvasPosition = provider.screenToCanvas(details.localPosition);

              // Check if tap is on any existing node
              bool tappedOnNode = false;
              for (final node in provider.nodes) {
                final distance = (node.position - canvasPosition).distance;
                if (distance <= node.size / 2) {
                  tappedOnNode = true;
                  break;
                }
              }

              // Create new node if not tapping on existing node
              if (!tappedOnNode) {
                provider.addNode(canvasPosition);
              }
            }
          },
          onPanUpdate: (details) {
            // Pan the canvas if no node is being dragged
            if (provider.draggedNode == null) {
              provider.updatePanOffset(details.delta);
            }
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

              // Connection mode indicator
              if (provider.isConnectMode)
                Positioned(
                  top: 50,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.yellow.withOpacity(0.9),
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
            ],
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
      ..color = Colors.white.withOpacity(0.1)
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
