// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persistance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PictureBook _$PictureBookFromJson(Map<String, dynamic> json) {
  return PictureBook()
    ..pictures = (json['pictures'] as List)
        .map((e) => Picture.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$PictureBookToJson(PictureBook instance) =>
    <String, dynamic>{
      'pictures': instance.pictures,
    };

Picture _$PictureFromJson(Map<String, dynamic> json) {
  return Picture(
    json['filename'],
    json['filepath'],
  )..tags = (json['tags'] as List)
      .map((e) => Tag.fromJson(e as Map<String, dynamic>))
      .toList();
}

Map<String, dynamic> _$PictureToJson(Picture instance) => <String, dynamic>{
      'filename': instance.filename,
      'filepath': instance.filepath,
      'tags': instance.tags,
    };

Tag _$TagFromJson(Map<String, dynamic> json) {
  return Tag(
    name: json['name'] as String,
  )..location = (json['location'] as List)
      .map((e) => Location.fromJson(e as Map<String, dynamic>))
      .toList();
}

Map<String, dynamic> _$TagToJson(Tag instance) => <String, dynamic>{
      'name': instance.name,
      'location': instance.location,
    };

Location _$LocationFromJson(Map<String, dynamic> json) {
  return Location(
    json['x'],
    json['y'],
    json['w'],
    json['h'],
  );
}

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'w': instance.w,
      'h': instance.h,
    };
