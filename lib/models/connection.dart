class Connection {
  final String id;
  final String fromNodeId;
  final String toNodeId;
  bool isGreen;
  bool isCharging;
  double chargingProgress;
  String? chargingFromNodeId; // ID of the node that is charging (the completed one)

  Connection({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    this.isGreen = false,
    this.isCharging = false,
    this.chargingProgress = 0.0,
    this.chargingFromNodeId,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromNodeId': fromNodeId,
      'toNodeId': toNodeId,
      'isGreen': isGreen,
      'isCharging': isCharging,
      'chargingProgress': chargingProgress,
      'chargingFromNodeId': chargingFromNodeId,
    };
  }

  // Create from JSON
  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['id'],
      fromNodeId: json['fromNodeId'],
      toNodeId: json['toNodeId'],
      isGreen: json['isGreen'] ?? false,
      isCharging: json['isCharging'] ?? false,
      chargingProgress: json['chargingProgress'] ?? 0.0,
      chargingFromNodeId: json['chargingFromNodeId'],
    );
  }

  // Create a copy with updated properties
  Connection copyWith({
    String? fromNodeId,
    String? toNodeId,
    bool? isGreen,
    bool? isCharging,
    double? chargingProgress,
    String? chargingFromNodeId,
  }) {
    return Connection(
      id: id,
      fromNodeId: fromNodeId ?? this.fromNodeId,
      toNodeId: toNodeId ?? this.toNodeId,
      isGreen: isGreen ?? this.isGreen,
      isCharging: isCharging ?? this.isCharging,
      chargingProgress: chargingProgress ?? this.chargingProgress,
      chargingFromNodeId: chargingFromNodeId ?? this.chargingFromNodeId,
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
