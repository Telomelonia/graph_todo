class Connection {
  final String id;
  final String fromNodeId;
  final String toNodeId;
  bool isGolden;

  Connection({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    this.isGolden = false,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromNodeId': fromNodeId,
      'toNodeId': toNodeId,
      'isGolden': isGolden,
    };
  }

  // Create from JSON
  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['id'],
      fromNodeId: json['fromNodeId'],
      toNodeId: json['toNodeId'],
      isGolden: json['isGolden'] ?? false,
    );
  }

  // Create a copy with updated properties
  Connection copyWith({
    bool? isGolden,
  }) {
    return Connection(
      id: id,
      fromNodeId: fromNodeId,
      toNodeId: toNodeId,
      isGolden: isGolden ?? this.isGolden,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Connection &&
        other.fromNodeId == fromNodeId &&
        other.toNodeId == toNodeId;
  }

  @override
  int get hashCode => fromNodeId.hashCode ^ toNodeId.hashCode;
}
