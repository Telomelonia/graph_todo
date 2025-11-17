import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graph_todo/services/storage_service.dart';
import 'package:graph_todo/models/todo_node.dart';
import 'package:graph_todo/models/connection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StorageService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await StorageService.initialize();
    });

    group('Node Storage', () {
      test('saves and loads nodes correctly', () {
        final nodes = [
          TodoNode(
            id: '1',
            text: 'Task 1',
            position: const Offset(10, 20),
          ),
          TodoNode(
            id: '2',
            text: 'Task 2',
            position: const Offset(30, 40),
            isCompleted: true,
          ),
        ];

        StorageService.saveNodes(nodes);
        final loaded = StorageService.loadNodes();

        expect(loaded.length, equals(2));
        expect(loaded[0].id, equals('1'));
        expect(loaded[0].text, equals('Task 1'));
        expect(loaded[1].isCompleted, isTrue);
      });

      test('saves and loads nodes with icon and description', () {
        final nodes = [
          TodoNode(
            id: '1',
            text: 'Code review',
            position: const Offset(10, 20),
            icon: 'code',
            description: 'Review pull requests',
          ),
        ];

        StorageService.saveNodes(nodes);
        final loaded = StorageService.loadNodes();

        expect(loaded.length, equals(1));
        expect(loaded[0].icon, equals('code'));
        expect(loaded[0].description, equals('Review pull requests'));
      });

      test('saves and loads nodes with custom colors and sizes', () {
        final nodes = [
          TodoNode(
            id: '1',
            text: 'Task',
            position: const Offset(10, 20),
            color: const Color(0xFFFF0000),
            size: 150.0,
          ),
        ];

        StorageService.saveNodes(nodes);
        final loaded = StorageService.loadNodes();

        expect(loaded[0].color, equals(const Color(0xFFFF0000)));
        expect(loaded[0].size, equals(150.0));
      });

      test('loadNodes returns empty list when no data exists', () {
        final loaded = StorageService.loadNodes();
        expect(loaded, isEmpty);
      });

      test('overwrites existing nodes on save', () {
        final nodes1 = [
          TodoNode(id: '1', text: 'First', position: const Offset(0, 0)),
        ];
        final nodes2 = [
          TodoNode(id: '2', text: 'Second', position: const Offset(0, 0)),
        ];

        StorageService.saveNodes(nodes1);
        StorageService.saveNodes(nodes2);
        final loaded = StorageService.loadNodes();

        expect(loaded.length, equals(1));
        expect(loaded[0].id, equals('2'));
      });

      test('handles empty node list', () {
        StorageService.saveNodes([]);
        final loaded = StorageService.loadNodes();
        expect(loaded, isEmpty);
      });

      test('preserves position precision', () {
        final nodes = [
          TodoNode(
            id: '1',
            text: 'Task',
            position: const Offset(123.456789, 987.654321),
          ),
        ];

        StorageService.saveNodes(nodes);
        final loaded = StorageService.loadNodes();

        expect(loaded[0].position.dx, closeTo(123.456789, 0.000001));
        expect(loaded[0].position.dy, closeTo(987.654321, 0.000001));
      });
    });

    group('Connection Storage', () {
      test('saves and loads connections correctly', () {
        final connections = [
          Connection(
            id: 'c1',
            fromNodeId: 'node1',
            toNodeId: 'node2',
          ),
          Connection(
            id: 'c2',
            fromNodeId: 'node2',
            toNodeId: 'node3',
            isGreen: true,
          ),
        ];

        StorageService.saveConnections(connections);
        final loaded = StorageService.loadConnections();

        expect(loaded.length, equals(2));
        expect(loaded[0].fromNodeId, equals('node1'));
        expect(loaded[0].toNodeId, equals('node2'));
        expect(loaded[1].isGreen, isTrue);
      });

      test('saves and loads connections with charging state', () {
        final connections = [
          Connection(
            id: 'c1',
            fromNodeId: 'node1',
            toNodeId: 'node2',
            isCharging: true,
            chargingProgress: 0.75,
          ),
        ];

        StorageService.saveConnections(connections);
        final loaded = StorageService.loadConnections();

        expect(loaded[0].isCharging, isTrue);
        expect(loaded[0].chargingProgress, equals(0.75));
      });

      test('loadConnections returns empty list when no data exists', () {
        final loaded = StorageService.loadConnections();
        expect(loaded, isEmpty);
      });

      test('handles empty connection list', () {
        StorageService.saveConnections([]);
        final loaded = StorageService.loadConnections();
        expect(loaded, isEmpty);
      });
    });

    group('Canvas State Storage', () {
      test('saves and loads canvas state correctly', () {
        StorageService.saveCanvasState(
          scale: 2.5,
          panX: 100.0,
          panY: 200.0,
        );

        final state = StorageService.loadCanvasState();

        expect(state['scale'], equals(2.5));
        expect(state['panX'], equals(100.0));
        expect(state['panY'], equals(200.0));
      });

      test('loadCanvasState returns defaults when no data exists', () {
        final state = StorageService.loadCanvasState();

        expect(state['scale'], equals(1.0));
        expect(state['panX'], equals(0.0));
        expect(state['panY'], equals(0.0));
      });

      test('handles negative pan values', () {
        StorageService.saveCanvasState(
          scale: 1.0,
          panX: -150.5,
          panY: -275.3,
        );

        final state = StorageService.loadCanvasState();

        expect(state['panX'], equals(-150.5));
        expect(state['panY'], equals(-275.3));
      });

      test('preserves precision in scale values', () {
        StorageService.saveCanvasState(
          scale: 1.23456789,
          panX: 0,
          panY: 0,
        );

        final state = StorageService.loadCanvasState();

        expect(state['scale'], closeTo(1.23456789, 0.000001));
      });
    });

    group('Bulk Operations', () {
      test('saveAllData saves nodes, connections, and canvas state', () {
        final nodes = [
          TodoNode(id: '1', text: 'Task', position: const Offset(0, 0)),
        ];
        final connections = [
          Connection(id: 'c1', fromNodeId: '1', toNodeId: '2'),
        ];

        StorageService.saveAllData(
          nodes: nodes,
          connections: connections,
          scale: 1.5,
          panX: 50.0,
          panY: 75.0,
        );

        final loadedNodes = StorageService.loadNodes();
        final loadedConnections = StorageService.loadConnections();
        final loadedState = StorageService.loadCanvasState();

        expect(loadedNodes.length, equals(1));
        expect(loadedConnections.length, equals(1));
        expect(loadedState['scale'], equals(1.5));
        expect(loadedState['panX'], equals(50.0));
      });

      test('clearAllData removes all stored data', () {
        // Save some data
        StorageService.saveAllData(
          nodes: [TodoNode(id: '1', text: 'Task', position: const Offset(0, 0))],
          connections: [Connection(id: 'c1', fromNodeId: '1', toNodeId: '2')],
          scale: 2.0,
          panX: 100.0,
          panY: 200.0,
        );

        // Clear it
        StorageService.clearAllData();

        // Verify everything is cleared
        final loadedNodes = StorageService.loadNodes();
        final loadedConnections = StorageService.loadConnections();
        final loadedState = StorageService.loadCanvasState();

        expect(loadedNodes, isEmpty);
        expect(loadedConnections, isEmpty);
        expect(loadedState['scale'], equals(1.0)); // default
        expect(loadedState['panX'], equals(0.0)); // default
        expect(loadedState['panY'], equals(0.0)); // default
      });
    });

    group('Error Handling', () {
      test('loadNodes returns empty list on corrupted JSON', () async {
        // Manually inject corrupted JSON
        SharedPreferences.setMockInitialValues({
          'graph_todo_nodes': 'invalid json {[',
        });
        await StorageService.initialize();

        final loaded = StorageService.loadNodes();
        expect(loaded, isEmpty);
      });

      test('loadConnections returns empty list on corrupted JSON', () async {
        SharedPreferences.setMockInitialValues({
          'graph_todo_connections': 'not valid json',
        });
        await StorageService.initialize();

        final loaded = StorageService.loadConnections();
        expect(loaded, isEmpty);
      });

      test('loadCanvasState returns defaults on corrupted JSON', () async {
        SharedPreferences.setMockInitialValues({
          'graph_todo_canvas_state': '{ invalid',
        });
        await StorageService.initialize();

        final state = StorageService.loadCanvasState();
        expect(state['scale'], equals(1.0));
        expect(state['panX'], equals(0.0));
        expect(state['panY'], equals(0.0));
      });
    });

    group('Roundtrip Tests', () {
      test('complex graph survives roundtrip', () {
        final nodes = [
          TodoNode(
            id: '1',
            text: 'First Task',
            position: const Offset(100, 200),
            icon: 'target',
            description: 'Description 1',
            isCompleted: false,
            color: const Color(0xFF6366F1),
            size: 120.0,
          ),
          TodoNode(
            id: '2',
            text: 'Second Task',
            position: const Offset(300, 400),
            icon: 'code',
            description: 'Description 2',
            isCompleted: true,
            color: const Color(0xFFEF4444),
            size: 140.0,
          ),
        ];

        final connections = [
          Connection(
            id: 'c1',
            fromNodeId: '1',
            toNodeId: '2',
            isGreen: true,
          ),
        ];

        StorageService.saveAllData(
          nodes: nodes,
          connections: connections,
          scale: 1.75,
          panX: 125.5,
          panY: 225.5,
        );

        final loadedNodes = StorageService.loadNodes();
        final loadedConnections = StorageService.loadConnections();
        final loadedState = StorageService.loadCanvasState();

        // Verify nodes
        expect(loadedNodes.length, equals(2));
        expect(loadedNodes[0].text, equals('First Task'));
        expect(loadedNodes[0].icon, equals('target'));
        expect(loadedNodes[0].description, equals('Description 1'));
        expect(loadedNodes[1].isCompleted, isTrue);
        expect(loadedNodes[1].color, equals(const Color(0xFFEF4444)));

        // Verify connections
        expect(loadedConnections.length, equals(1));
        expect(loadedConnections[0].isGreen, isTrue);

        // Verify canvas state
        expect(loadedState['scale'], equals(1.75));
        expect(loadedState['panX'], equals(125.5));
        expect(loadedState['panY'], equals(225.5));
      });
    });
  });
}
