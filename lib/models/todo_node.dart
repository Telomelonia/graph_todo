import 'dart:ui';
import 'package:hive/hive.dart';

part 'todo_node.g.dart';

@HiveType(typeId: 0)
class TodoNode {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String text;

  @HiveField(2)
  String description;

  @HiveField(3)
  String icon;

  @HiveField(4)
  Offset position;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  Color color;

  @HiveField(7)
  double size;

  @HiveField(8)
  DateTime? dueDate;

  TodoNode({
    required this.id,
    required this.text,
    this.description = '',
    this.icon = 'target', // Default target icon
    required this.position,
    this.isCompleted = false,
    this.color = const Color(0xFF6366F1), // Default indigo color
    this.size = 120.0,
    this.dueDate,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'description': description,
      'icon': icon,
      'position': {'dx': position.dx, 'dy': position.dy},
      'isCompleted': isCompleted,
      'color': color.toARGB32(),
      'size': size,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  // Create from JSON
  factory TodoNode.fromJson(Map<String, dynamic> json) {
    return TodoNode(
      id: json['id'],
      text: json['text'],
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'target',
      position: Offset(json['position']['dx'], json['position']['dy']),
      isCompleted: json['isCompleted'] ?? false,
      color: Color(json['color'] ?? 0xFF6366F1),
      size: json['size']?.toDouble() ?? 100.0,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    );
  }

  // Create a copy with updated properties
  TodoNode copyWith({
    String? text,
    String? description,
    String? icon,
    Offset? position,
    bool? isCompleted,
    Color? color,
    double? size,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) {
    return TodoNode(
      id: id,
      text: text ?? this.text,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      position: position ?? this.position,
      isCompleted: isCompleted ?? this.isCompleted,
      color: color ?? this.color,
      size: size ?? this.size,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
    );
  }
}
