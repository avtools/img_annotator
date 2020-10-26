import 'package:json_annotation/json_annotation.dart';

part 'persistance.g.dart';

@JsonSerializable(nullable: false)
class PictureBook {
  List<Picture> pictures = [];

  PictureBook();

  factory PictureBook.fromJson(Map<String, dynamic> json) =>
      _$PictureBookFromJson(json);

  Map<String, dynamic> toJson() => _$PictureBookToJson(this);

  void add(Picture) => this.pictures.add(Picture);
}

@JsonSerializable(nullable: false)
class Picture {
  String filename;
  String filepath;
  List<Tag> tags;

  Picture({this.filename, this.filepath});

  factory Picture.fromJson(Map<String, dynamic> json) =>
      _$PictureFromJson(json);

  Map<String, dynamic> toJson() => _$PictureToJson(this);
}

@JsonSerializable(nullable: false)
class Tag {
  String name;
  List<Location> location;

  Tag({this.name});

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  Map<String, dynamic> toJson() => _$TagToJson(this);
}

@JsonSerializable(nullable: false)
class Location {
  double w, h, x, y;

  Location();

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);
}
