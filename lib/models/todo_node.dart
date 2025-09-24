import 'dart:ui';

class TodoNode {
  final String id;
  String text;
  String description;
  Offset position;
  bool isCompleted;
  Color color;
  double size;

  TodoNode({
    required this.id,
    required this.text,
    this.description = '',
    required this.position,
    this.isCompleted = false,
    this.color = const Color(0xFF6366F1), // Default indigo color
    this.size = 60.0,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'description': description,
      'position': {'dx': position.dx, 'dy': position.dy},
      'isCompleted': isCompleted,
      'color': color.toARGB32(),
      'size': size,
    };
  }

  // Create from JSON
  factory TodoNode.fromJson(Map<String, dynamic> json) {
    return TodoNode(
      id: json['id'],
      text: json['text'],
      description: json['description'] ?? '',
      position: Offset(json['position']['dx'], json['position']['dy']),
      isCompleted: json['isCompleted'] ?? false,
      color: Color(json['color'] ?? 0xFF6366F1),
      size: json['size']?.toDouble() ?? 60.0,
    );
  }

  // Create a copy with updated properties
  TodoNode copyWith({
    String? text,
    String? description,
    Offset? position,
    bool? isCompleted,
    Color? color,
    double? size,
  }) {
    return TodoNode(
      id: id,
      text: text ?? this.text,
      description: description ?? this.description,
      position: position ?? this.position,
      isCompleted: isCompleted ?? this.isCompleted,
      color: color ?? this.color,
      size: size ?? this.size,
    );
  }
}
