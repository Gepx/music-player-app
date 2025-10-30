// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArtistModelAdapter extends TypeAdapter<ArtistModel> {
  @override
  final int typeId = 2;

  @override
  ArtistModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArtistModel(
      id: fields[0] as String,
      spotifyId: fields[1] as String?,
      name: fields[2] as String,
      imageUrl: fields[3] as String?,
      genres: (fields[4] as List).cast<String>(),
      isFollowing: fields[5] as bool,
      trackCount: fields[6] as int,
      albumCount: fields[7] as int,
      popularity: fields[8] as int?,
      followers: fields[9] as int?,
      uri: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ArtistModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.spotifyId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.genres)
      ..writeByte(5)
      ..write(obj.isFollowing)
      ..writeByte(6)
      ..write(obj.trackCount)
      ..writeByte(7)
      ..write(obj.albumCount)
      ..writeByte(8)
      ..write(obj.popularity)
      ..writeByte(9)
      ..write(obj.followers)
      ..writeByte(10)
      ..write(obj.uri);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArtistModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
