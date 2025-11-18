// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_node.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoNodeAdapter extends TypeAdapter<TodoNode> {
  @override
  final int typeId = 0;

  @override
  TodoNode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TodoNode(
      id: fields[0] as String,
      text: fields[1] as String,
      description: fields[2] as String,
      icon: fields[3] as String,
      position: fields[4] as Offset,
      isCompleted: fields[5] as bool,
      color: fields[6] as Color,
      size: fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, TodoNode obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.icon)
      ..writeByte(4)
      ..write(obj.position)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.color)
      ..writeByte(7)
      ..write(obj.size);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoNodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
