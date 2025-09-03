import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graph_todo/models/todo_node.dart';

void main() {
  group('TodoNode', () {
    test('creates node with default values', () {
      final node = TodoNode(
        id: 'test-id',
        text: 'Test task',
        position: const Offset(10, 20),
      );

      expect(node.id, equals('test-id'));
      expect(node.text, equals('Test task'));
      expect(node.position, equals(const Offset(10, 20)));
      expect(node.isCompleted, isFalse);
      expect(node.color, equals(const Color(0xFF6366F1)));
      expect(node.size, equals(60.0));
    });

    test('creates node with custom values', () {
      final node = TodoNode(
        id: 'custom-id',
        text: 'Custom task',
        position: const Offset(30, 40),
        isCompleted: true,
        color: Colors.red,
        size: 80.0,
      );

      expect(node.isCompleted, isTrue);
      expect(node.color, equals(Colors.red));
      expect(node.size, equals(80.0));
    });

    test('copyWith updates specified fields', () {
      final original = TodoNode(
        id: 'test-id',
        text: 'Original text',
        position: const Offset(10, 20),
      );

      final updated = original.copyWith(
        text: 'Updated text',
        isCompleted: true,
      );

      expect(updated.id, equals('test-id')); // unchanged
      expect(updated.text, equals('Updated text')); // changed
      expect(updated.position, equals(const Offset(10, 20))); // unchanged
      expect(updated.isCompleted, isTrue); // changed
      expect(updated.color, equals(const Color(0xFF6366F1))); // unchanged
    });

    test('copyWith preserves original when no changes', () {
      final original = TodoNode(
        id: 'test-id',
        text: 'Original text',
        position: const Offset(10, 20),
      );

      final copy = original.copyWith();

      expect(copy.id, equals(original.id));
      expect(copy.text, equals(original.text));
      expect(copy.position, equals(original.position));
      expect(copy.isCompleted, equals(original.isCompleted));
      expect(copy.color, equals(original.color));
      expect(copy.size, equals(original.size));
    });

    test('toJson serializes correctly', () {
      final node = TodoNode(
        id: 'test-id',
        text: 'Test task',
        position: const Offset(10.5, 20.7),
        isCompleted: true,
        color: const Color(0xFFFF0000),
        size: 75.0,
      );

      final json = node.toJson();

      expect(json['id'], equals('test-id'));
      expect(json['text'], equals('Test task'));
      expect(json['position']['dx'], equals(10.5));
      expect(json['position']['dy'], equals(20.7));
      expect(json['isCompleted'], isTrue);
      expect(json['color'], equals(0xFFFF0000));
      expect(json['size'], equals(75.0));
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'id': 'test-id',
        'text': 'Test task',
        'position': {'dx': 10.5, 'dy': 20.7},
        'isCompleted': true,
        'color': 0xFFFF0000,
        'size': 75.0,
      };

      final node = TodoNode.fromJson(json);

      expect(node.id, equals('test-id'));
      expect(node.text, equals('Test task'));
      expect(node.position, equals(const Offset(10.5, 20.7)));
      expect(node.isCompleted, isTrue);
      expect(node.color, equals(const Color(0xFFFF0000)));
      expect(node.size, equals(75.0));
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'test-id',
        'text': 'Test task',
        'position': {'dx': 10.0, 'dy': 20.0},
      };

      final node = TodoNode.fromJson(json);

      expect(node.isCompleted, isFalse);
      expect(node.color, equals(const Color(0xFF6366F1)));
      expect(node.size, equals(60.0));
    });

    test('roundtrip serialization preserves data', () {
      final original = TodoNode(
        id: 'test-id',
        text: 'Test task',
        position: const Offset(10.5, 20.7),
        isCompleted: true,
        color: const Color(0xFFFF0000),
        size: 75.0,
      );

      final json = original.toJson();
      final restored = TodoNode.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.text, equals(original.text));
      expect(restored.position, equals(original.position));
      expect(restored.isCompleted, equals(original.isCompleted));
      expect(restored.color, equals(original.color));
      expect(restored.size, equals(original.size));
    });
  });
}