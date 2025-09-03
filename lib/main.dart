import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                heroTag: "add",
                onPressed: provider.toggleNodeCreateMode,
                backgroundColor: provider.isNodeCreateMode
                    ? Colors.green
                    : Colors.grey,
                child: Icon(
                  provider.isNodeCreateMode
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
        return Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.equal ||
                  event.logicalKey == LogicalKeyboardKey.add) {
                provider.increaseSelectedNodeSize();
                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.minus) {
                provider.decreaseSelectedNodeSize();
                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.escape) {
                provider.clearNodeSelection();
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: GestureDetector(
            onTapUp: (details) {
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

              // Only create new node if in node create mode and not tapping on existing node
              if (provider.isNodeCreateMode && !tappedOnNode) {
                provider.addNode(canvasPosition);
              }

              // Clear selection if tapping on empty space
              if (!tappedOnNode) {
                provider.clearNodeSelection();
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

              // Node creation mode indicator
              if (provider.isNodeCreateMode)
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
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Selected node size controls indicator
              if (provider.selectedNodeId != null)
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Node Selected',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '+/= : Increase size',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          '- : Decrease size',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          'ESC : Clear selection',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
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
