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
      expect(node.size, equals(120.0));
      expect(node.description, equals(''));
      expect(node.icon, equals('target'));
    });

    test('creates node with custom values', () {
      final node = TodoNode(
        id: 'custom-id',
        text: 'Custom task',
        description: 'Custom description',
        icon: 'heart',
        position: const Offset(30, 40),
        isCompleted: true,
        color: Colors.red,
        size: 80.0,
      );

      expect(node.isCompleted, isTrue);
      expect(node.color, equals(Colors.red));
      expect(node.size, equals(80.0));
      expect(node.description, equals('Custom description'));
      expect(node.icon, equals('heart'));
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
      expect(node.size, equals(100.0));
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

    test('creates node with custom icon', () {
      final node = TodoNode(
        id: 'test-id',
        text: 'Test task',
        icon: 'code',
        position: const Offset(10, 20),
      );

      expect(node.icon, equals('code'));
    });

    test('creates node with description', () {
      final node = TodoNode(
        id: 'test-id',
        text: 'Test task',
        description: 'This is a test description',
        position: const Offset(10, 20),
      );

      expect(node.description, equals('This is a test description'));
    });

    test('copyWith updates icon', () {
      final original = TodoNode(
        id: 'test-id',
        text: 'Original text',
        icon: 'target',
        position: const Offset(10, 20),
      );

      final updated = original.copyWith(icon: 'heart');

      expect(updated.icon, equals('heart'));
      expect(updated.text, equals('Original text')); // unchanged
    });

    test('copyWith updates description', () {
      final original = TodoNode(
        id: 'test-id',
        text: 'Original text',
        description: 'Original description',
        position: const Offset(10, 20),
      );

      final updated = original.copyWith(description: 'New description');

      expect(updated.description, equals('New description'));
      expect(updated.text, equals('Original text')); // unchanged
    });

    test('toJson includes icon and description', () {
      final node = TodoNode(
        id: 'test-id',
        text: 'Test task',
        description: 'Test description',
        icon: 'star',
        position: const Offset(10.5, 20.7),
      );

      final json = node.toJson();

      expect(json['description'], equals('Test description'));
      expect(json['icon'], equals('star'));
    });

    test('fromJson deserializes icon and description', () {
      final json = {
        'id': 'test-id',
        'text': 'Test task',
        'description': 'Test description',
        'icon': 'heart',
        'position': {'dx': 10.5, 'dy': 20.7},
      };

      final node = TodoNode.fromJson(json);

      expect(node.description, equals('Test description'));
      expect(node.icon, equals('heart'));
    });

    test('fromJson handles missing description', () {
      final json = {
        'id': 'test-id',
        'text': 'Test task',
        'position': {'dx': 10.0, 'dy': 20.0},
      };

      final node = TodoNode.fromJson(json);

      expect(node.description, equals(''));
    });

    test('fromJson handles missing icon', () {
      final json = {
        'id': 'test-id',
        'text': 'Test task',
        'position': {'dx': 10.0, 'dy': 20.0},
      };

      final node = TodoNode.fromJson(json);

      expect(node.icon, equals('target'));
    });

    test('roundtrip serialization preserves icon and description', () {
      final original = TodoNode(
        id: 'test-id',
        text: 'Test task',
        description: 'Detailed description',
        icon: 'trophy',
        position: const Offset(10.5, 20.7),
        isCompleted: true,
        color: const Color(0xFFFF0000),
        size: 75.0,
      );

      final json = original.toJson();
      final restored = TodoNode.fromJson(json);

      expect(restored.description, equals(original.description));
      expect(restored.icon, equals(original.icon));
      expect(restored.text, equals(original.text));
    });
  });
}