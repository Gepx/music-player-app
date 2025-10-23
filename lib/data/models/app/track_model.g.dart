// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackModelAdapter extends TypeAdapter<TrackModel> {
  @override
  final int typeId = 0;

  @override
  TrackModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackModel(
      id: fields[0] as String,
      spotifyId: fields[1] as String?,
      title: fields[2] as String,
      artistName: fields[3] as String,
      artistId: fields[4] as String?,
      albumName: fields[5] as String,
      albumId: fields[6] as String?,
      albumArtUrl: fields[7] as String?,
      durationMs: fields[8] as int,
      streamUrl: fields[9] as String?,
      isFavorite: fields[10] as bool,
      addedAt: fields[11] as DateTime?,
      playCount: fields[12] as int,
      isDownloaded: fields[13] as bool,
      localPath: fields[14] as String?,
      popularity: fields[15] as int?,
      explicit: fields[16] as bool,
      uri: fields[17] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TrackModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.spotifyId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.artistName)
      ..writeByte(4)
      ..write(obj.artistId)
      ..writeByte(5)
      ..write(obj.albumName)
      ..writeByte(6)
      ..write(obj.albumId)
      ..writeByte(7)
      ..write(obj.albumArtUrl)
      ..writeByte(8)
      ..write(obj.durationMs)
      ..writeByte(9)
      ..write(obj.streamUrl)
      ..writeByte(10)
      ..write(obj.isFavorite)
      ..writeByte(11)
      ..write(obj.addedAt)
      ..writeByte(12)
      ..write(obj.playCount)
      ..writeByte(13)
      ..write(obj.isDownloaded)
      ..writeByte(14)
      ..write(obj.localPath)
      ..writeByte(15)
      ..write(obj.popularity)
      ..writeByte(16)
      ..write(obj.explicit)
      ..writeByte(17)
      ..write(obj.uri);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
