import 'dart:ui';
import 'package:hive/hive.dart';

class ColorAdapter extends TypeAdapter<Color> {
  @override
  final int typeId = 3;

  @override
  Color read(BinaryReader reader) {
    final value = reader.readInt();
    return Color(value);
  }

  @override
  void write(BinaryWriter writer, Color obj) {
    writer.writeInt(obj.toARGB32());
  }
}
