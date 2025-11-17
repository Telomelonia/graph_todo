import 'package:flutter/material.dart';
import '../models/connection.dart';
import '../models/todo_node.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

class ConnectionPainter extends CustomPainter {
  final List<Connection> connections;
  final List<TodoNode> nodes;
  final double scale;
  final Offset panOffset;
  final bool isConnectMode;
  final String? selectedNodeForConnection;
  final double animationValue;
  final String? hoveredConnectionId;
  final VoidCallback? onConnectionDelete;
  final bool isDarkMode;

  ConnectionPainter({
    required this.connections,
    required this.nodes,
    required this.scale,
    required this.panOffset,
    this.isConnectMode = false,
    this.selectedNodeForConnection,
    this.animationValue = 0.0,
    this.hoveredConnectionId,
    this.onConnectionDelete,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw existing connections
    for (final connection in connections) {
      _drawConnection(canvas, connection);
    }

    // Draw animated connection preview in connect mode
    if (isConnectMode && selectedNodeForConnection != null) {
      _drawConnectionPreview(canvas, size);
    }
  }

  void _drawConnectionPreview(Canvas canvas, Size size) {
    final selectedNode = nodes.firstWhere(
      (node) => node.id == selectedNodeForConnection,
      orElse: () => throw Exception('Selected node not found'),
    );

    final fromPos = _canvasToScreen(selectedNode.position);
    final scaledRadius = (selectedNode.size / 2) * scale;

    // Draw pulsing circle around selected node
    final pulseAlpha = 0.8 * (0.5 + 0.5 * math.sin(animationValue * 6));
    final selectionColor = AppTheme.getSelectionColor(isDarkMode);
    final pulsePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = selectionColor.withValues(alpha: pulseAlpha);

    canvas.drawCircle(
      fromPos,
      scaledRadius + 10 + 5 * math.sin(animationValue * 4),
      pulsePaint,
    );

    // Draw animated arrows pointing outward
    _drawAnimatedArrows(canvas, fromPos, scaledRadius + 20);
  }

  void _drawAnimatedArrows(Canvas canvas, Offset center, double radius) {
    final selectionColor = AppTheme.getSelectionColor(isDarkMode);
    final arrowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = selectionColor.withValues(alpha: 0.7);

    // Draw 8 arrows in a circle
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) + animationValue;
      final arrowCenter = center + Offset(
        math.cos(angle) * radius,
        math.sin(angle) * radius,
      );

      // Create arrow path
      final arrowPath = Path();
      const arrowSize = 8.0;

      // Arrow pointing outward
      final tipX = arrowCenter.dx + math.cos(angle) * arrowSize;
      final tipY = arrowCenter.dy + math.sin(angle) * arrowSize;

      final leftX = arrowCenter.dx + math.cos(angle - 2.5) * arrowSize * 0.6;
      final leftY = arrowCenter.dy + math.sin(angle - 2.5) * arrowSize * 0.6;

      final rightX = arrowCenter.dx + math.cos(angle + 2.5) * arrowSize * 0.6;
      final rightY = arrowCenter.dy + math.sin(angle + 2.5) * arrowSize * 0.6;

      arrowPath.moveTo(tipX, tipY);
      arrowPath.lineTo(leftX, leftY);
      arrowPath.lineTo(rightX, rightY);
      arrowPath.close();

      canvas.drawPath(arrowPath, arrowPaint);
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
      (fromNode.size / 2) * scale,
      (toNode.size / 2) * scale,
    );

    // Check if this connection is hovered
    final isHovered = hoveredConnectionId == connection.id;

    // Create paint for the connection line
    final scaledStrokeWidth = (3.0 * scale).clamp(1.0, 6.0);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = scaledStrokeWidth
      ..strokeCap = StrokeCap.round;

    // Set color based on connection state
    if (isHovered) {
      paint.color = Colors.red.withValues(alpha: 0.8);
      paint.strokeWidth = (5.0 * scale).clamp(2.0, 10.0);
    } else if (connection.isGreen) {
      paint.color = const Color(0xFF4CAF50);
      paint.strokeWidth = (4.0 * scale).clamp(2.0, 8.0);

      // Add glow effect for green connections
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (8.0 * scale).clamp(4.0, 16.0)
        ..strokeCap = StrokeCap.round
        ..color = AppTheme.primaryGreen.withValues(alpha: 0.3);

      canvas.drawLine(connectionPoints.from, connectionPoints.to, glowPaint);
    } else if (connection.isCharging) {
      _drawChargingConnection(canvas, connectionPoints, connection, scale);
      return;
    } else {
      paint.color = AppTheme.getConnectionColor(isDarkMode);
    }

    // Draw the main connection line
    canvas.drawLine(connectionPoints.from, connectionPoints.to, paint);

    // Draw small circles at connection points
    _drawConnectionDots(canvas, connectionPoints, connection.isGreen, scale);

    // Draw delete cross icon if hovered
    if (isHovered) {
      _drawDeleteCross(canvas, connectionPoints, scale);
    }
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
      ..color = AppTheme.getConnectionColor(isDarkMode).withValues(alpha: 0.4);

    canvas.drawLine(points.from, points.to, basePaint);

    // Calculate the direction and distance
    final direction = points.to - points.from;
    final distance = direction.distance;

    if (distance > 0) {
      // Determine charging direction based on which node is the source
      final isChargingFromStart = connection.chargingFromNodeId == connection.fromNodeId;
      
      Offset chargingStartPoint;
      Offset chargingEndPoint;
      
      if (isChargingFromStart) {
        // Charging from the 'from' node to the 'to' node
        final normalizedDirection = direction / distance;
        final chargedDistance = distance * connection.chargingProgress;
        chargingStartPoint = points.from;
        chargingEndPoint = points.from + normalizedDirection * chargedDistance;
      } else {
        // Charging from the 'to' node to the 'from' node
        final normalizedDirection = -direction / distance; // Reverse direction
        final chargedDistance = distance * connection.chargingProgress;
        chargingStartPoint = points.to;
        chargingEndPoint = points.to + normalizedDirection * chargedDistance;
      }

      final chargingPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (4.0 * scale).clamp(2.0, 8.0)
        ..strokeCap = StrokeCap.round
        ..color = AppTheme.primaryGreen;

      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (8.0 * scale).clamp(4.0, 16.0)
        ..strokeCap = StrokeCap.round
        ..color = AppTheme.primaryGreen.withValues(alpha: 0.5);

      if (connection.chargingProgress > 0) {
        canvas.drawLine(chargingStartPoint, chargingEndPoint, glowPaint);
        canvas.drawLine(chargingStartPoint, chargingEndPoint, chargingPaint);

        final chargingPointPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xFF81C784);

        canvas.drawCircle(chargingEndPoint, (6.0 * scale).clamp(3.0, 12.0), chargingPointPaint);
      }
    }

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
      ..color = AppTheme.getConnectionDotColor(isDarkMode, isGolden: isGreen);

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
    final direction = toCenter - fromCenter;
    final distance = direction.distance;

    if (distance == 0) {
      return ConnectionPoints(fromCenter, toCenter);
    }

    final normalizedDirection = direction / distance;
    final fromPoint = fromCenter + normalizedDirection * fromRadius;
    final toPoint = toCenter - normalizedDirection * toRadius;

    return ConnectionPoints(fromPoint, toPoint);
  }

  void _drawDeleteCross(Canvas canvas, ConnectionPoints points, double scale) {
    // Calculate the middle point of the connection
    final middlePoint = Offset(
      (points.from.dx + points.to.dx) / 2,
      (points.from.dy + points.to.dy) / 2,
    );

    final crossSize = (12.0 * scale).clamp(8.0, 20.0);
    
    // Draw background circle
    final backgroundPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.red.withValues(alpha: 0.9);

    canvas.drawCircle(middlePoint, crossSize / 2, backgroundPaint);

    // Draw border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.white;

    canvas.drawCircle(middlePoint, crossSize / 2, borderPaint);

    // Draw the cross lines
    final crossPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;

    final crossOffset = crossSize * 0.3;

    // Draw X shape
    canvas.drawLine(
      Offset(middlePoint.dx - crossOffset, middlePoint.dy - crossOffset),
      Offset(middlePoint.dx + crossOffset, middlePoint.dy + crossOffset),
      crossPaint,
    );
    canvas.drawLine(
      Offset(middlePoint.dx - crossOffset, middlePoint.dy + crossOffset),
      Offset(middlePoint.dx + crossOffset, middlePoint.dy - crossOffset),
      crossPaint,
    );
  }

  Offset _canvasToScreen(Offset canvasPoint) {
    return canvasPoint * scale + panOffset;
  }

  @override
  bool shouldRepaint(ConnectionPainter oldDelegate) {
    return connections != oldDelegate.connections ||
        nodes != oldDelegate.nodes ||
        scale != oldDelegate.scale ||
        panOffset != oldDelegate.panOffset ||
        isConnectMode != oldDelegate.isConnectMode ||
        selectedNodeForConnection != oldDelegate.selectedNodeForConnection ||
        animationValue != oldDelegate.animationValue ||
        hoveredConnectionId != oldDelegate.hoveredConnectionId ||
        isDarkMode != oldDelegate.isDarkMode;
  }
}

class ConnectionPoints {
  final Offset from;
  final Offset to;

  ConnectionPoints(this.from, this.to);
}
