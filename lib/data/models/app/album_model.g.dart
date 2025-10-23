// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlbumModelAdapter extends TypeAdapter<AlbumModel> {
  @override
  final int typeId = 1;

  @override
  AlbumModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlbumModel(
      id: fields[0] as String,
      spotifyId: fields[1] as String?,
      title: fields[2] as String,
      artistName: fields[3] as String,
      artistId: fields[4] as String?,
      coverArtUrl: fields[5] as String?,
      releaseDate: fields[6] as DateTime,
      totalTracks: fields[7] as int,
      trackIds: (fields[8] as List).cast<String>(),
      isSaved: fields[9] as bool,
      albumType: fields[10] as String,
      uri: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AlbumModel obj) {
    writer
      ..writeByte(12)
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
      ..write(obj.coverArtUrl)
      ..writeByte(6)
      ..write(obj.releaseDate)
      ..writeByte(7)
      ..write(obj.totalTracks)
      ..writeByte(8)
      ..write(obj.trackIds)
      ..writeByte(9)
      ..write(obj.isSaved)
      ..writeByte(10)
      ..write(obj.albumType)
      ..writeByte(11)
      ..write(obj.uri);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlbumModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
