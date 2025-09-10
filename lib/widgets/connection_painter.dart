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

    // Calculate connection points on node edges (scale the node radii properly)
    final connectionPoints = _calculateConnectionPoints(
      fromPos,
      toPos,
      (fromNode.size / 2) * scale,
      (toNode.size / 2) * scale,
    );

    // Create paint for the connection line (limit stroke scaling to prevent over-thick lines)
    final scaledStrokeWidth = (3.0 * scale).clamp(1.0, 6.0);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = scaledStrokeWidth
      ..strokeCap = StrokeCap.round;

    // Set color based on connection state
    if (connection.isGreen) {
      paint.color = const Color(0xFF4CAF50); // Green color
      paint.strokeWidth = (4.0 * scale).clamp(2.0, 8.0);

      // Add glow effect for green connections (limit glow scaling)
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (8.0 * scale).clamp(4.0, 16.0)
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF4CAF50).withValues(alpha: 0.3);

      canvas.drawLine(connectionPoints.from, connectionPoints.to, glowPaint);
    } else if (connection.isCharging) {
      // Draw charging animation
      _drawChargingConnection(canvas, connectionPoints, connection, scale);
      return; // Skip drawing the normal line
    } else {
      paint.color = Colors.white.withValues(alpha: 0.6);
    }

    // Draw the main connection line
    canvas.drawLine(connectionPoints.from, connectionPoints.to, paint);

    // Draw small circles at connection points
    _drawConnectionDots(canvas, connectionPoints, connection.isGreen, scale);
  }

  void _drawChargingConnection(
      Canvas canvas,
      ConnectionPoints points,
      Connection connection,
      double scale,
      ) {
    // Draw base line
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = (3.0 * scale).clamp(1.0, 6.0)
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.4);

    canvas.drawLine(points.from, points.to, basePaint);

    // Calculate the direction and distance
    final direction = points.to - points.from;
    final distance = direction.distance;
    
    if (distance > 0) {
      final normalizedDirection = direction / distance;
      
      // Draw charging effect - partial green line based on progress
      final chargedDistance = distance * connection.chargingProgress;
      final chargedEndPoint = points.from + normalizedDirection * chargedDistance;
      
      final chargingPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (4.0 * scale).clamp(2.0, 8.0)
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF4CAF50);

      // Add glow effect for the charged portion
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (8.0 * scale).clamp(4.0, 16.0)
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF4CAF50).withValues(alpha: 0.5);

      if (chargedDistance > 0) {
        canvas.drawLine(points.from, chargedEndPoint, glowPaint);
        canvas.drawLine(points.from, chargedEndPoint, chargingPaint);
        
        // Draw a bright charging point at the end of the charged section
        final chargingPointPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xFF81C784);
        
        canvas.drawCircle(chargedEndPoint, (6.0 * scale).clamp(3.0, 12.0), chargingPointPaint);
      }
    }

    // Draw connection dots
    _drawConnectionDots(canvas, points, false, scale);
  }

  void _drawConnectionDots(
      Canvas canvas,
      ConnectionPoints points,
      bool isGreen,
      double scale,
      ) {
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isGreen
          ? const Color(0xFF4CAF50)
          : Colors.white.withValues(alpha: 0.8);

    final dotRadius = (4.0 * scale).clamp(2.0, 8.0);
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
