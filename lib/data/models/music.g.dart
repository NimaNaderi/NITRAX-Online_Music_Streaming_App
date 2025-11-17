// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MusicAdapter extends TypeAdapter<Music> {
  @override
  final int typeId = 0;

  @override
  Music read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Music(
      fields[1] as dynamic,
      fields[2] as dynamic,
      fields[3] as dynamic,
      fields[4] as dynamic,
      fields[5] as dynamic,
      fields[6] as dynamic,
      fields[0] as dynamic,
      fields[8] as dynamic,
      videoLink: fields[7] as dynamic,
      videoCover: fields[9] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, Music obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.audioLink)
      ..writeByte(2)
      ..write(obj.photo)
      ..writeByte(3)
      ..write(obj.artist)
      ..writeByte(4)
      ..write(obj.song)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.duration)
      ..writeByte(7)
      ..write(obj.videoLink)
      ..writeByte(8)
      ..write(obj.bg_colors)
      ..writeByte(9)
      ..write(obj.videoCover);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
