import 'package:hive/hive.dart';

part 'music.g.dart';

@HiveType(typeId: 0)
class Music extends HiveObject {
  @HiveField(0)
  dynamic id;

  @HiveField(1)
  dynamic audioLink;

  @HiveField(2)
  dynamic photo;

  @HiveField(3)
  dynamic artist;

  @HiveField(4)
  dynamic song;

  @HiveField(5)
  dynamic type;

  @HiveField(6)
  dynamic duration;

  @HiveField(7)
  dynamic videoLink;

  @HiveField(8)
  dynamic bg_colors;

  @HiveField(9)
  dynamic videoCover;

  Music(
    this.audioLink,
    this.photo,
    this.artist,
    this.song,
    this.type,
    this.duration,
    this.id,
    this.bg_colors, {
    this.videoLink,
    this.videoCover,
  });

  factory Music.fromJson(Map<String, dynamic> jsonMapObject) {
    return Music(
      jsonMapObject['link'],
      jsonMapObject['photo'],
      jsonMapObject['artist'],
      jsonMapObject['song'],
      jsonMapObject['type'],
      jsonMapObject['duration'],
      jsonMapObject['id'],
      jsonMapObject['bg_colors'],
      videoCover: jsonMapObject['videoCover'],
    );
  }
}
