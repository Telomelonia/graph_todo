// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConnectionAdapter extends TypeAdapter<Connection> {
  @override
  final int typeId = 1;

  @override
  Connection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Connection(
      id: fields[0] as String,
      fromNodeId: fields[1] as String,
      toNodeId: fields[2] as String,
      isGreen: fields[3] as bool,
      isCharging: fields[4] as bool,
      chargingProgress: fields[5] as double,
      chargingFromNodeId: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Connection obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fromNodeId)
      ..writeByte(2)
      ..write(obj.toNodeId)
      ..writeByte(3)
      ..write(obj.isGreen)
      ..writeByte(4)
      ..write(obj.isCharging)
      ..writeByte(5)
      ..write(obj.chargingProgress)
      ..writeByte(6)
      ..write(obj.chargingFromNodeId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
