import 'package:flutter/material.dart';
import '../models/connection.dart';
import '../models/todo_node.dart';

class ConnectionPainter extends CustomPainter {
  final List<Connection> connections;
  final List<TodoNode> nodes;
  final double scale;
  final Offset panOffset;

  ConnectionPainter({
    required this.connections,
    required this.nodes,
    required this.scale,
    required this.panOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final connection in connections) {
      _drawConnection(canvas, connection);
    }
  }

  void _drawConnection(Canvas canvas, Connection connection) {
    // Find the connected nodes
    final fromNode = nodes.firstWhere(
          (node) => node.id == connection.fromNodeId,
      orElse: () => throw Exception('From node not found'),
    );
    final toNode = nodes.firstWhere(
          (node) => node.id == connection.toNodeId,
      orElse: () => throw Exception('To node not found'),
    );

    // Convert node positions to screen coordinates
    final fromPos = _canvasToScreen(fromNode.position);
    final toPos = _canvasToScreen(toNode.position);

    // Calculate connection points on node edges
    final connectionPoints = _calculateConnectionPoints(
      fromPos,
      toPos,
      fromNode.size / 2,
      toNode.size / 2,
    );

    // Create paint for the connection line
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Set color based on connection state
    if (connection.isGolden) {
      paint.color = const Color(0xFFFFD700); // Gold color
      paint.strokeWidth = 4.0;

      // Add glow effect for golden connections
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.3);

      canvas.drawLine(connectionPoints.from, connectionPoints.to, glowPaint);
    } else {
      paint.color = Colors.white.withValues(alpha: 0.6);
    }

    // Draw the main connection line
    canvas.drawLine(connectionPoints.from, connectionPoints.to, paint);

    // Draw small circles at connection points
    _drawConnectionDots(canvas, connectionPoints, connection.isGolden);
  }

  void _drawConnectionDots(
      Canvas canvas,
      ConnectionPoints points,
      bool isGolden,
      ) {
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isGolden
          ? const Color(0xFFFFD700)
          : Colors.white.withValues(alpha: 0.8);

    const dotRadius = 4.0;
    canvas.drawCircle(points.from, dotRadius, dotPaint);
    canvas.drawCircle(points.to, dotRadius, dotPaint);
  }

  ConnectionPoints _calculateConnectionPoints(
      Offset fromCenter,
      Offset toCenter,
      double fromRadius,
      double toRadius,
      ) {
    // Calculate the direction vector
    final direction = toCenter - fromCenter;
    final distance = direction.distance;

    if (distance == 0) {
      return ConnectionPoints(fromCenter, toCenter);
    }

    // Normalize the direction
    final normalizedDirection = direction / distance;

    // Calculate connection points on the edge of circles
    final fromPoint = fromCenter + normalizedDirection * fromRadius;
    final toPoint = toCenter - normalizedDirection * toRadius;

    return ConnectionPoints(fromPoint, toPoint);
  }

  Offset _canvasToScreen(Offset canvasPoint) {
    return canvasPoint * scale + panOffset;
  }

  @override
  bool shouldRepaint(ConnectionPainter oldDelegate) {
    return connections != oldDelegate.connections ||
        nodes != oldDelegate.nodes ||
        scale != oldDelegate.scale ||
        panOffset != oldDelegate.panOffset;
  }
}

class ConnectionPoints {
  final Offset from;
  final Offset to;

  ConnectionPoints(this.from, this.to);
}
