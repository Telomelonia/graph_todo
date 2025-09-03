import 'dart:ui';

class TodoNode {
  final String id;
  String text;
  Offset position;
  bool isCompleted;
  final Color color;
  double size;

  TodoNode({
    required this.id,
    required this.text,
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
      'position': {'dx': position.dx, 'dy': position.dy},
      'isCompleted': isCompleted,
      'color': color.value,
      'size': size,
    };
  }

  // Create from JSON
  factory TodoNode.fromJson(Map<String, dynamic> json) {
    return TodoNode(
      id: json['id'],
      text: json['text'],
      position: Offset(json['position']['dx'], json['position']['dy']),
      isCompleted: json['isCompleted'] ?? false,
      color: Color(json['color'] ?? 0xFF6366F1),
      size: json['size']?.toDouble() ?? 60.0,
    );
  }

  // Create a copy with updated properties
  TodoNode copyWith({
    String? text,
    Offset? position,
    bool? isCompleted,
    double? size,
  }) {
    return TodoNode(
      id: id,
      text: text ?? this.text,
      position: position ?? this.position,
      isCompleted: isCompleted ?? this.isCompleted,
      color: color,
      size: size ?? this.size,
    );
  }
}
