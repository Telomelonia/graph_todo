import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graph_todo/services/data_service.dart';
import 'package:graph_todo/models/todo_node.dart';
import 'package:graph_todo/models/connection.dart';

void main() {
  group('DataService', () {
    group('validateConnections', () {
      test('returns true for valid connections', () {
        final nodes = [
          TodoNode(id: '1', text: 'Task 1', position: const Offset(0, 0)),
          TodoNode(id: '2', text: 'Task 2', position: const Offset(0, 0)),
        ];

        final connections = [
          Connection(id: 'c1', fromNodeId: '1', toNodeId: '2'),
        ];

        expect(DataService.validateConnections(nodes, connections), isTrue);
      });

      test('returns false when fromNodeId does not exist', () {
        final nodes = [
          TodoNode(id: '1', text: 'Task 1', position: const Offset(0, 0)),
        ];

        final connections = [
          Connection(id: 'c1', fromNodeId: 'invalid', toNodeId: '1'),
        ];

        expect(DataService.validateConnections(nodes, connections), isFalse);
      });

      test('returns false when toNodeId does not exist', () {
        final nodes = [
          TodoNode(id: '1', text: 'Task 1', position: const Offset(0, 0)),
        ];

        final connections = [
          Connection(id: 'c1', fromNodeId: '1', toNodeId: 'invalid'),
        ];

        expect(DataService.validateConnections(nodes, connections), isFalse);
      });

      test('returns true for empty connections list', () {
        final nodes = [
          TodoNode(id: '1', text: 'Task 1', position: const Offset(0, 0)),
        ];

        expect(DataService.validateConnections(nodes, []), isTrue);
      });

      test('returns true for empty nodes and connections', () {
        expect(DataService.validateConnections([], []), isTrue);
      });

      test('validates multiple connections correctly', () {
        final nodes = [
          TodoNode(id: '1', text: 'Task 1', position: const Offset(0, 0)),
          TodoNode(id: '2', text: 'Task 2', position: const Offset(0, 0)),
          TodoNode(id: '3', text: 'Task 3', position: const Offset(0, 0)),
        ];

        final connections = [
          Connection(id: 'c1', fromNodeId: '1', toNodeId: '2'),
          Connection(id: 'c2', fromNodeId: '2', toNodeId: '3'),
        ];

        expect(DataService.validateConnections(nodes, connections), isTrue);
      });

      test('detects invalid connection among valid ones', () {
        final nodes = [
          TodoNode(id: '1', text: 'Task 1', position: const Offset(0, 0)),
          TodoNode(id: '2', text: 'Task 2', position: const Offset(0, 0)),
        ];

        final connections = [
          Connection(id: 'c1', fromNodeId: '1', toNodeId: '2'),
          Connection(id: 'c2', fromNodeId: '2', toNodeId: 'invalid'),
        ];

        expect(DataService.validateConnections(nodes, connections), isFalse);
      });

      test('handles self-referencing connection validation', () {
        final nodes = [
          TodoNode(id: '1', text: 'Task 1', position: const Offset(0, 0)),
        ];

        final connections = [
          Connection(id: 'c1', fromNodeId: '1', toNodeId: '1'),
        ];

        // Should still validate the IDs exist, even if self-referencing
        expect(DataService.validateConnections(nodes, connections), isTrue);
      });
    });

    group('ImportResult', () {
      test('creates success result correctly', () {
        final nodes = [
          TodoNode(id: '1', text: 'Task', position: const Offset(0, 0)),
        ];
        final connections = [
          Connection(id: 'c1', fromNodeId: '1', toNodeId: '1'),
        ];
        final canvasState = {'scale': 1.0, 'panX': 0.0, 'panY': 0.0};

        final result = ImportResult.success(
          nodes: nodes,
          connections: connections,
          canvasState: canvasState,
          version: '1.0.0',
          exportDate: '2024-01-01T00:00:00.000',
        );

        expect(result.success, isTrue);
        expect(result.cancelled, isFalse);
        expect(result.error, isNull);
        expect(result.nodes, equals(nodes));
        expect(result.connections, equals(connections));
        expect(result.canvasState, equals(canvasState));
        expect(result.version, equals('1.0.0'));
        expect(result.exportDate, equals('2024-01-01T00:00:00.000'));
      });

      test('creates error result correctly', () {
        final result = ImportResult.error('Failed to parse file');

        expect(result.success, isFalse);
        expect(result.cancelled, isFalse);
        expect(result.error, equals('Failed to parse file'));
        expect(result.nodes, isNull);
        expect(result.connections, isNull);
      });

      test('creates cancelled result correctly', () {
        final result = ImportResult.cancelled();

        expect(result.success, isFalse);
        expect(result.cancelled, isTrue);
        expect(result.error, isNull);
      });
    });

    group('Export Data Format Validation', () {
      test('validates expected export structure can be parsed', () {
        // Simulate what exportData would create
        final exportData = {
          'version': '1.0.0',
          'exportDate': DateTime.now().toIso8601String(),
          'nodes': [
            TodoNode(
              id: '1',
              text: 'Task 1',
              position: const Offset(100, 200),
              icon: 'target',
              description: 'Test',
            ).toJson(),
          ],
          'connections': [
            Connection(
              id: 'c1',
              fromNodeId: '1',
              toNodeId: '2',
            ).toJson(),
          ],
          'canvasState': {
            'panOffset': {'dx': 0.0, 'dy': 0.0},
            'scale': 1.0,
          },
        };

        // Verify the structure can be serialized
        final jsonString = jsonEncode(exportData);
        expect(jsonString, isNotEmpty);

        // Verify it can be deserialized
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        expect(decoded['version'], isNotNull);
        expect(decoded['nodes'], isList);
        expect(decoded['connections'], isList);
        expect(decoded['canvasState'], isMap);
      });

      test('node serialization includes all required fields', () {
        final node = TodoNode(
          id: '1',
          text: 'Task',
          position: const Offset(10, 20),
          icon: 'code',
          description: 'Description',
          isCompleted: true,
          color: const Color(0xFF6366F1),
          size: 120.0,
        );

        final json = node.toJson();
        expect(json['id'], equals('1'));
        expect(json['text'], equals('Task'));
        expect(json['position'], isNotNull);
        expect(json['icon'], equals('code'));
        expect(json['description'], equals('Description'));
        expect(json['isCompleted'], isTrue);
        expect(json['color'], equals(0xFF6366F1));
        expect(json['size'], equals(120.0));
      });

      test('connection serialization includes all required fields', () {
        final connection = Connection(
          id: 'c1',
          fromNodeId: 'node1',
          toNodeId: 'node2',
          isGreen: true,
          isCharging: false,
          chargingProgress: 0.5,
        );

        final json = connection.toJson();
        expect(json['id'], equals('c1'));
        expect(json['fromNodeId'], equals('node1'));
        expect(json['toNodeId'], equals('node2'));
        expect(json['isGreen'], isTrue);
        expect(json['isCharging'], isFalse);
        expect(json['chargingProgress'], equals(0.5));
      });
    });

    group('Data Deserialization Tests', () {
      test('deserializes node with all fields', () {
        final json = {
          'id': '1',
          'text': 'Task',
          'position': {'dx': 100.0, 'dy': 200.0},
          'icon': 'heart',
          'description': 'Love this task',
          'isCompleted': true,
          'color': 0xFFEF4444,
          'size': 140.0,
        };

        final node = TodoNode.fromJson(json);
        expect(node.id, equals('1'));
        expect(node.text, equals('Task'));
        expect(node.icon, equals('heart'));
        expect(node.description, equals('Love this task'));
        expect(node.isCompleted, isTrue);
        expect(node.color, equals(const Color(0xFFEF4444)));
        expect(node.size, equals(140.0));
      });

      test('deserializes node with missing optional fields', () {
        final json = {
          'id': '1',
          'text': 'Task',
          'position': {'dx': 10.0, 'dy': 20.0},
        };

        final node = TodoNode.fromJson(json);
        expect(node.icon, equals('target')); // default
        expect(node.description, equals('')); // default
        expect(node.isCompleted, isFalse); // default
      });

      test('deserializes connection with all fields', () {
        final json = {
          'id': 'c1',
          'fromNodeId': 'n1',
          'toNodeId': 'n2',
          'isGreen': true,
          'isCharging': true,
          'chargingProgress': 0.75,
        };

        final connection = Connection.fromJson(json);
        expect(connection.id, equals('c1'));
        expect(connection.fromNodeId, equals('n1'));
        expect(connection.toNodeId, equals('n2'));
        expect(connection.isGreen, isTrue);
        expect(connection.isCharging, isTrue);
        expect(connection.chargingProgress, equals(0.75));
      });
    });

    group('Roundtrip Serialization', () {
      test('node data survives roundtrip', () {
        final original = TodoNode(
          id: 'test-id',
          text: 'Test Task',
          position: const Offset(123.456, 789.012),
          icon: 'brain',
          description: 'Think deeply about this',
          isCompleted: true,
          color: const Color(0xFF10B981),
          size: 135.5,
        );

        final json = original.toJson();
        final restored = TodoNode.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.text, equals(original.text));
        expect(restored.position.dx, closeTo(original.position.dx, 0.001));
        expect(restored.position.dy, closeTo(original.position.dy, 0.001));
        expect(restored.icon, equals(original.icon));
        expect(restored.description, equals(original.description));
        expect(restored.isCompleted, equals(original.isCompleted));
        expect(restored.color, equals(original.color));
        expect(restored.size, equals(original.size));
      });

      test('connection data survives roundtrip', () {
        final original = Connection(
          id: 'conn-id',
          fromNodeId: 'from-node',
          toNodeId: 'to-node',
          isGreen: true,
          isCharging: false,
          chargingProgress: 0.33,
        );

        final json = original.toJson();
        final restored = Connection.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.fromNodeId, equals(original.fromNodeId));
        expect(restored.toNodeId, equals(original.toNodeId));
        expect(restored.isGreen, equals(original.isGreen));
        expect(restored.isCharging, equals(original.isCharging));
        expect(restored.chargingProgress, equals(original.chargingProgress));
      });

      test('complete graph structure survives roundtrip', () {
        final nodes = [
          TodoNode(
            id: '1',
            text: 'First',
            position: const Offset(10, 20),
            icon: 'target',
            description: 'First task',
          ),
          TodoNode(
            id: '2',
            text: 'Second',
            position: const Offset(30, 40),
            icon: 'code',
            description: 'Second task',
            isCompleted: true,
          ),
        ];

        final connections = [
          Connection(id: 'c1', fromNodeId: '1', toNodeId: '2', isGreen: true),
        ];

        // Serialize
        final exportData = {
          'nodes': nodes.map((n) => n.toJson()).toList(),
          'connections': connections.map((c) => c.toJson()).toList(),
        };

        final jsonString = jsonEncode(exportData);

        // Deserialize
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        final nodesList = (decoded['nodes'] as List)
            .map((json) => TodoNode.fromJson(json))
            .toList();
        final connsList = (decoded['connections'] as List)
            .map((json) => Connection.fromJson(json))
            .toList();

        // Validate
        expect(nodesList.length, equals(2));
        expect(nodesList[0].icon, equals('target'));
        expect(nodesList[1].isCompleted, isTrue);
        expect(connsList.length, equals(1));
        expect(connsList[0].isGreen, isTrue);
      });
    });
  });
}
