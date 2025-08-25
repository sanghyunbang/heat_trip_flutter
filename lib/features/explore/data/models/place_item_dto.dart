// 기존 PlaceItem 에 필드 추가(옵셔널 + 기본값)
class PlaceItem {
  final int contentid;
  final String title;
  final String addr1;
  final String addr2;
  final String firstimage;
  final String firstimage2;

  // ▼ 스냅샷 파생 필드들(옵션)
  final String? cat3; // ex) A02010400
  final String? cat3Name; // ex) 고택
  final String? shortDesc1; // 간단 설명 1
  final String? shortDesc2; // 간단 설명 2
  final List<String> hashtags;
  final List<String> simpleTags;

  const PlaceItem({
    required this.contentid,
    required this.title,
    required this.addr1,
    required this.addr2,
    required this.firstimage,
    required this.firstimage2,
    this.cat3,
    this.cat3Name,
    this.shortDesc1,
    this.shortDesc2,
    this.hashtags = const [],
    this.simpleTags = const [],
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
    super.cat3,
    super.cat3Name,
    super.shortDesc1,
    super.shortDesc2,
    super.hashtags = const [],
    super.simpleTags = const [],
  });

  factory PlaceItemDto.fromJson(Map<String, dynamic> json) {
    // 서버 응답: CursorPageResponse { items: [...], nextCursor, hasNext }
    // 여기서 items[i] 의 각 필드명을 그대로 사용한다고 가정(백엔드 PlaceSummaryDto)
    List<String> _list(dynamic v) =>
        (v is List) ? v.whereType<String>().toList() : const [];

    return PlaceItemDto(
      contentid: json['contentid'] as int,
      title: json['title'] as String? ?? '',
      addr1: json['addr1'] as String? ?? '',
      addr2: json['addr2'] as String? ?? '',
      firstimage: json['firstimage'] as String? ?? '',
      firstimage2: json['firstimage2'] as String? ?? '',
      cat3: json['cat3'] as String?,
      cat3Name: json['cat3Name'] as String?,
      shortDesc1: json['shortDesc1'] as String?,
      shortDesc2: json['shortDesc2'] as String?,
      hashtags: _list(json['hashtags']),
      simpleTags: _list(json['simpleTags']),
    );
  }

  Map<String, dynamic> toJson() => {
    'contentid': contentid,
    'title': title,
    'addr1': addr1,
    'addr2': addr2,
    'firstimage': firstimage,
    'firstimage2': firstimage2,
    'cat3': cat3,
    'cat3Name': cat3Name,
    'shortDesc1': shortDesc1,
    'shortDesc2': shortDesc2,
    'hashtags': hashtags,
    'simpleTags': simpleTags,
  };
}

// class PlaceItem {
//   final int contentid;
//   final String title;
//   final String addr1;
//   final String addr2;
//   final String firstimage;
//   final String firstimage2;
//   // final String overview;

//   const PlaceItem({
//     required this.contentid,
//     required this.title,
//     required this.addr1,
//     required this.addr2,
//     required this.firstimage,
//     required this.firstimage2,
//     // required this.overview,
//   });
// }

// class PlaceItemDto extends PlaceItem {
//   const PlaceItemDto({
//     required super.contentid,
//     required super.title,
//     required super.addr1,
//     required super.addr2,
//     required super.firstimage,
//     required super.firstimage2,
//     // required super.overview,
//   });

//   factory PlaceItemDto.fromJson(Map<String, dynamic> json) {
//     return PlaceItemDto(
//       contentid: json['contentid'] as int,
//       title: json['title'] as String,
//       addr1: json['addr1'] as String,
//       addr2: json['addr2'] as String,
//       firstimage: json['firstimage'] as String,
//       firstimage2: json['firstimage2'] as String,
//       // overview: json['overview'] as String,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'contentid': contentid,
//     'title': title,
//     'addr1': addr1,
//     'addr2': addr2,
//     'firstimage': firstimage,
//     'firstimage2': firstimage2,
//     // 'overview': overview,
//   };
// }
