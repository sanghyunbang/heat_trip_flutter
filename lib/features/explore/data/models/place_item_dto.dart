class PlaceItem {
  final int contentid;
  final String title;
  final String addr1;
  final String addr2;
  final String firstimage;
  final String firstimage2;
  // final String overview;

  const PlaceItem({
    required this.contentid,
    required this.title,
    required this.addr1,
    required this.addr2,
    required this.firstimage,
    required this.firstimage2,
    // required this.overview,
  });
}

class PlaceItemDto extends PlaceItem {
  const PlaceItemDto({
    required super.contentid,
    required super.title,
    required super.addr1,
    required super.addr2,
    required super.firstimage,
    required super.firstimage2,
    // required super.overview,
  });

  factory PlaceItemDto.fromJson(Map<String, dynamic> json) {
    return PlaceItemDto(
      contentid: json['contentid'] as int,
      title: json['title'] as String,
      addr1: json['addr1'] as String,
      addr2: json['addr2'] as String,
      firstimage: json['firstimage'] as String,
      firstimage2: json['firstimage2'] as String,
      // overview: json['overview'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'contentid': contentid,
    'title': title,
    'addr1': addr1,
    'addr2': addr2,
    'firstimage': firstimage,
    'firstimage2': firstimage2,
    // 'overview': overview,
  };
}
