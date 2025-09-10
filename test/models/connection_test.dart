import 'package:flutter_test/flutter_test.dart';
import 'package:graph_todo/models/connection.dart';

void main() {
  group('Connection', () {
    test('creates connection with default values', () {
      final connection = Connection(
        id: 'test-id',
        fromNodeId: 'node1',
        toNodeId: 'node2',
      );

      expect(connection.id, equals('test-id'));
      expect(connection.fromNodeId, equals('node1'));
      expect(connection.toNodeId, equals('node2'));
      expect(connection.isGreen, isFalse);
      expect(connection.isCharging, isFalse);
      expect(connection.chargingProgress, equals(0.0));
    });

    test('creates connection with custom green state', () {
      final connection = Connection(
        id: 'test-id',
        fromNodeId: 'node1',
        toNodeId: 'node2',
        isGreen: true,
      );

      expect(connection.isGreen, isTrue);
    });

    test('copyWith updates green state', () {
      final original = Connection(
        id: 'test-id',
        fromNodeId: 'node1',
        toNodeId: 'node2',
      );

      final updated = original.copyWith(isGreen: true, isCharging: true, chargingProgress: 0.5);

      expect(updated.id, equals('test-id'));
      expect(updated.fromNodeId, equals('node1'));
      expect(updated.toNodeId, equals('node2'));
      expect(updated.isGreen, isTrue);
      expect(updated.isCharging, isTrue);
      expect(updated.chargingProgress, equals(0.5));
    });

    test('copyWith preserves original when no changes', () {
      final original = Connection(
        id: 'test-id',
        fromNodeId: 'node1',
        toNodeId: 'node2',
        isGreen: true,
        isCharging: true,
        chargingProgress: 0.7,
      );

      final copy = original.copyWith();

      expect(copy.id, equals(original.id));
      expect(copy.fromNodeId, equals(original.fromNodeId));
      expect(copy.toNodeId, equals(original.toNodeId));
      expect(copy.isGreen, equals(original.isGreen));
      expect(copy.isCharging, equals(original.isCharging));
      expect(copy.chargingProgress, equals(original.chargingProgress));
    });

    test('equality works correctly', () {
      final connection1 = Connection(
        id: 'id1',
        fromNodeId: 'node1',
        toNodeId: 'node2',
      );

      final connection2 = Connection(
        id: 'id2', // different id
        fromNodeId: 'node1',
        toNodeId: 'node2',
      );

      final connection3 = Connection(
        id: 'id3',
        fromNodeId: 'node2', // swapped nodes
        toNodeId: 'node1',
      );

      final connection4 = Connection(
        id: 'id4',
        fromNodeId: 'node1',
        toNodeId: 'node3', // different to node
      );

      expect(connection1, equals(connection2)); // same nodes, different id
      expect(connection1, isNot(equals(connection3))); // swapped nodes
      expect(connection1, isNot(equals(connection4))); // different nodes
    });

    test('hashCode works correctly', () {
      final connection1 = Connection(
        id: 'id1',
        fromNodeId: 'node1',
        toNodeId: 'node2',
      );

      final connection2 = Connection(
        id: 'id2',
        fromNodeId: 'node1',
        toNodeId: 'node2',
      );

      expect(connection1.hashCode, equals(connection2.hashCode));
    });

    test('toJson serializes correctly', () {
      final connection = Connection(
        id: 'test-id',
        fromNodeId: 'node1',
        toNodeId: 'node2',
        isGreen: true,
        isCharging: true,
        chargingProgress: 0.8,
      );

      final json = connection.toJson();

      expect(json['id'], equals('test-id'));
      expect(json['fromNodeId'], equals('node1'));
      expect(json['toNodeId'], equals('node2'));
      expect(json['isGreen'], isTrue);
      expect(json['isCharging'], isTrue);
      expect(json['chargingProgress'], equals(0.8));
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'id': 'test-id',
        'fromNodeId': 'node1',
        'toNodeId': 'node2',
        'isGreen': true,
        'isCharging': true,
        'chargingProgress': 0.9,
      };

      final connection = Connection.fromJson(json);

      expect(connection.id, equals('test-id'));
      expect(connection.fromNodeId, equals('node1'));
      expect(connection.toNodeId, equals('node2'));
      expect(connection.isGreen, isTrue);
      expect(connection.isCharging, isTrue);
      expect(connection.chargingProgress, equals(0.9));
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'test-id',
        'fromNodeId': 'node1',
        'toNodeId': 'node2',
      };

      final connection = Connection.fromJson(json);

      expect(connection.isGreen, isFalse);
      expect(connection.isCharging, isFalse);
      expect(connection.chargingProgress, equals(0.0));
    });

    test('roundtrip serialization preserves data', () {
      final original = Connection(
        id: 'test-id',
        fromNodeId: 'node1',
        toNodeId: 'node2',
        isGreen: true,
        isCharging: true,
        chargingProgress: 0.6,
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
  });
}