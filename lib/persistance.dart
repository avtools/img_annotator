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
  Map<String, Tag> tags;

  Picture(filename, filepath) {
    this.filepath = filepath;
    this.filename = filename;
    this.tags = Map<String, Tag>();
  }

  factory Picture.fromJson(Map<String, dynamic> json) =>
      _$PictureFromJson(json);

  Map<String, dynamic> toJson() => _$PictureToJson(this);
}

@JsonSerializable(nullable: false)
class Tag {
  String name;
  List<Location> location;
  int color;

  Tag(name, color) {
    this.name = name;
    this.color = color;
    this.location = List<Location>();
  }

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  Map<String, dynamic> toJson() => _$TagToJson(this);
}

@JsonSerializable(nullable: false)
class Location {
//  Offset start,end;
  double x, y, w, h;

  Location(x, y, w, h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);
}
