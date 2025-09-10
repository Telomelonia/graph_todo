class Connection {
  final String id;
  final String fromNodeId;
  final String toNodeId;
  bool isGreen;
  bool isCharging;
  double chargingProgress;

  Connection({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    this.isGreen = false,
    this.isCharging = false,
    this.chargingProgress = 0.0,
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
    );
  }

  // Create a copy with updated properties
  Connection copyWith({
    bool? isGreen,
    bool? isCharging,
    double? chargingProgress,
  }) {
    return Connection(
      id: id,
      fromNodeId: fromNodeId,
      toNodeId: toNodeId,
      isGreen: isGreen ?? this.isGreen,
      isCharging: isCharging ?? this.isCharging,
      chargingProgress: chargingProgress ?? this.chargingProgress,
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
