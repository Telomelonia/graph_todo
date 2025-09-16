import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graph_todo/providers/canvas_provider.dart';

void main() {
  group('CanvasProvider', () {
    late CanvasProvider provider;

    setUp(() {
      provider = CanvasProvider();
    });

    test('initializes with default values', () {
      expect(provider.nodes, isEmpty);
      expect(provider.connections, isEmpty);
      expect(provider.panOffset, equals(Offset.zero));
      expect(provider.scale, equals(1.0));
      expect(provider.isConnectMode, isFalse);
      expect(provider.selectedNodeForConnection, isNull);
      expect(provider.draggedNode, isNull);
    });

    test('addNode creates and adds new node', () {
      provider.addNode(const Offset(10, 20), text: 'Test task');

      expect(provider.nodes.length, equals(1));
      final node = provider.nodes.first;
      expect(node.text, equals('Test task'));
      expect(node.position, equals(const Offset(10, 20)));
      expect(node.isCompleted, isFalse);
    });

    test('addNode with default text', () {
      provider.addNode(const Offset(10, 20));

      expect(provider.nodes.length, equals(1));
      expect(provider.nodes.first.text, equals(''));
    });

    test('addNode sizes node as 14% of view when viewSize provided', () {
      const viewSize = Size(1000, 800); // Width = 1000, Height = 800
      provider.addNode(const Offset(10, 20), viewSize: viewSize);

      expect(provider.nodes.length, equals(1));
      // 14% of the smaller dimension (800) = 112.0
      expect(provider.nodes.first.size, closeTo(112.0, 0.001));
    });

    test('addNode automatically exits add node mode', () {
      // First enable add node mode
      provider.toggleAddNodeMode();
      expect(provider.isAddNodeMode, isTrue);

      // Add a node
      provider.addNode(const Offset(10, 20));

      // Verify add node mode is automatically disabled
      expect(provider.isAddNodeMode, isFalse);
      expect(provider.nodes.length, equals(1));
    });

    test('updateNodeText modifies existing node', () {
      provider.addNode(const Offset(10, 20), text: 'Original');
      final nodeId = provider.nodes.first.id;

      provider.updateNodeText(nodeId, 'Updated');

      expect(provider.nodes.first.text, equals('Updated'));
    });

    test('updateNodeText ignores non-existent node', () {
      provider.addNode(const Offset(10, 20), text: 'Original');

      provider.updateNodeText('non-existent', 'Updated');

      expect(provider.nodes.first.text, equals('Original'));
    });

    test('updateNodePosition modifies existing node', () {
      provider.addNode(const Offset(10, 20));
      final nodeId = provider.nodes.first.id;

      provider.updateNodePosition(nodeId, const Offset(30, 40));

      expect(provider.nodes.first.position, equals(const Offset(30, 40)));
    });

    test('toggleNodeCompletion changes completion state', () {
      provider.addNode(const Offset(10, 20));
      final nodeId = provider.nodes.first.id;

      expect(provider.nodes.first.isCompleted, isFalse);

      provider.toggleNodeCompletion(nodeId);

      expect(provider.nodes.first.isCompleted, isTrue);

      provider.toggleNodeCompletion(nodeId);

      expect(provider.nodes.first.isCompleted, isFalse);
    });

    test('removeNode removes node and its connections', () {
      provider.addNode(const Offset(10, 20));
      provider.addNode(const Offset(30, 40));
      final node1Id = provider.nodes[0].id;
      final node2Id = provider.nodes[1].id;

      provider.createConnection(node1Id, node2Id);

      expect(provider.nodes.length, equals(2));
      expect(provider.connections.length, equals(1));

      provider.removeNode(node1Id);

      expect(provider.nodes.length, equals(1));
      expect(provider.connections.length, equals(0));
      expect(provider.nodes.first.id, equals(node2Id));
    });

    test('updatePanOffset changes pan offset', () {
      provider.updatePanOffset(const Offset(10, 20));

      expect(provider.panOffset, equals(const Offset(10, 20)));

      provider.updatePanOffset(const Offset(5, -10));

      expect(provider.panOffset, equals(const Offset(15, 10)));
    });

    test('updateScale clamps scale within bounds', () {
      provider.updateScale(2.0);
      expect(provider.scale, equals(2.0));

      provider.updateScale(0.05);
      expect(provider.scale, equals(0.1)); // clamped to min

      provider.updateScale(10.0);
      expect(provider.scale, equals(5.0)); // clamped to max
    });

    test('toggleConnectMode changes connect mode state', () {
      expect(provider.isConnectMode, isFalse);

      provider.toggleConnectMode();

      expect(provider.isConnectMode, isTrue);
      expect(provider.selectedNodeForConnection, isNull);

      provider.toggleConnectMode();

      expect(provider.isConnectMode, isFalse);
    });

    test('exitConnectMode resets connect mode state', () {
      provider.toggleConnectMode();
      provider.addNode(const Offset(10, 20));
      provider.selectNodeForConnection(provider.nodes.first.id);

      expect(provider.isConnectMode, isTrue);
      expect(provider.selectedNodeForConnection, isNotNull);

      provider.exitConnectMode();

      expect(provider.isConnectMode, isFalse);
      expect(provider.selectedNodeForConnection, isNull);
    });

    test('selectNodeForConnection works in connect mode', () {
      provider.addNode(const Offset(10, 20));
      provider.addNode(const Offset(30, 40));
      final node1Id = provider.nodes[0].id;
      final node2Id = provider.nodes[1].id;

      provider.toggleConnectMode();

      // Select first node
      provider.selectNodeForConnection(node1Id);
      expect(provider.selectedNodeForConnection, equals(node1Id));
      expect(provider.isConnectMode, isTrue);

      // Select second node - should create connection and exit connect mode
      provider.selectNodeForConnection(node2Id);
      expect(provider.selectedNodeForConnection, isNull);
      expect(provider.isConnectMode, isFalse);
      expect(provider.connections.length, equals(1));
    });

    test('selectNodeForConnection ignores when not in connect mode', () {
      provider.addNode(const Offset(10, 20));
      final nodeId = provider.nodes.first.id;

      provider.selectNodeForConnection(nodeId);

      expect(provider.selectedNodeForConnection, isNull);
      expect(provider.connections.length, equals(0));
    });

    test('createConnection creates new connection', () {
      provider.addNode(const Offset(10, 20));
      provider.addNode(const Offset(30, 40));
      final node1Id = provider.nodes[0].id;
      final node2Id = provider.nodes[1].id;

      provider.createConnection(node1Id, node2Id);

      expect(provider.connections.length, equals(1));
      final connection = provider.connections.first;
      expect(connection.fromNodeId, equals(node1Id));
      expect(connection.toNodeId, equals(node2Id));
      expect(connection.isGreen, isFalse);
    });

    test('createConnection prevents duplicate connections', () {
      provider.addNode(const Offset(10, 20));
      provider.addNode(const Offset(30, 40));
      final node1Id = provider.nodes[0].id;
      final node2Id = provider.nodes[1].id;

      provider.createConnection(node1Id, node2Id);
      provider.createConnection(node1Id, node2Id); // duplicate
      provider.createConnection(node2Id, node1Id); // reverse duplicate

      expect(provider.connections.length, equals(1));
    });

    test('connection becomes green when both nodes completed', () {
      provider.addNode(const Offset(10, 20));
      provider.addNode(const Offset(30, 40));
      final node1Id = provider.nodes[0].id;
      final node2Id = provider.nodes[1].id;

      provider.createConnection(node1Id, node2Id);
      expect(provider.connections.first.isGreen, isFalse);

      // Complete first node
      provider.toggleNodeCompletion(node1Id);
      expect(provider.connections.first.isGreen, isFalse);

      // Complete second node
      provider.toggleNodeCompletion(node2Id);
      expect(provider.connections.first.isGreen, isTrue);

      // Uncomplete first node
      provider.toggleNodeCompletion(node1Id);
      expect(provider.connections.first.isGreen, isFalse);
    });

    test('startDrag and endDrag manage drag state', () {
      provider.addNode(const Offset(10, 20));
      final node = provider.nodes.first;

      provider.startDrag(node);
      expect(provider.draggedNode, equals(node));

      provider.endDrag();
      expect(provider.draggedNode, isNull);
    });

    test('screenToCanvas converts coordinates correctly', () {
      provider.updatePanOffset(const Offset(10, 20));
      provider.updateScale(2.0);

      const screenPoint = Offset(30, 40);
      final canvasPoint = provider.screenToCanvas(screenPoint);

      expect(canvasPoint, equals(const Offset(10, 10))); // (30-10)/2, (40-20)/2
    });

    test('canvasToScreen converts coordinates correctly', () {
      provider.updatePanOffset(const Offset(10, 20));
      provider.updateScale(2.0);

      const canvasPoint = Offset(10, 10);
      final screenPoint = provider.canvasToScreen(canvasPoint);

      expect(screenPoint, equals(const Offset(30, 40))); // 10*2+10, 10*2+20
    });

    test('clearCanvas resets everything', () {
      provider.addNode(const Offset(10, 20));
      provider.addNode(const Offset(30, 40));
      provider.createConnection(provider.nodes[0].id, provider.nodes[1].id);
      provider.updatePanOffset(const Offset(10, 20));
      provider.updateScale(2.0);
      provider.toggleConnectMode();

      provider.clearCanvas();

      expect(provider.nodes, isEmpty);
      expect(provider.connections, isEmpty);
      expect(provider.panOffset, equals(Offset.zero));
      expect(provider.scale, equals(1.0));
      expect(provider.isConnectMode, isFalse);
      expect(provider.selectedNodeForConnection, isNull);
      expect(provider.draggedNode, isNull);
    });
  });
}