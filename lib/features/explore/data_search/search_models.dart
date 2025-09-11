// 검색 응답/아이템 모델들
// [!] 백엔드 PageResponse 가 프로젝트 구간별로 필드명이 다를 수 있어
//     fromJson에서 "content/ items", "total/ totalElements", "page/ number" 등을 폭넓게 처리한다. ※M-1

class PlaceSummary {
  final int contentid;
  final String title;
  final String? addr1;
  final String? addr2;
  final String? firstimage;
  final String? firstimage2;
  final int? contentTypeId;
  final String? cat3;
  final String? cat3Name;

  PlaceSummary({
    required this.contentid,
    required this.title,
    this.addr1,
    this.addr2,
    this.firstimage,
    this.firstimage2,
    this.contentTypeId,
    this.cat3,
    this.cat3Name,
  });

  factory PlaceSummary.fromJson(Map<String, dynamic> j) {
    int? _toInt(dynamic v) => (v == null) ? null : int.tryParse('$v');
    return PlaceSummary(
      contentid: int.parse('${j['contentid']}'),
      title: '${j['title'] ?? ''}',
      addr1: j['addr1'],
      addr2: j['addr2'],
      firstimage: j['firstimage'],
      firstimage2: j['firstimage2'],
      contentTypeId: _toInt(j['contentTypeId']),
      cat3: j['cat3'],
      cat3Name: j['cat3Name'],
    );
  }
}

class PageResponsePS {
  final List<PlaceSummary> items;
  final int page;
  final int size;
  final int total;
  final bool? last;

  PageResponsePS({
    required this.items,
    required this.page,
    required this.size,
    required this.total,
    this.last,
  });

  factory PageResponsePS.fromJson(Map<String, dynamic> j) {
    // 키 가변 대응
    final list = (j['content'] ?? j['items'] ?? []) as List;
    final page = j['page'] ?? j['number'] ?? 0;
    final size = j['size'] ?? (j['pageSize'] ?? 20);
    final total = j['total'] ?? j['totalElements'] ?? (j['count'] ?? 0);
    final last = j['last']; // 없을 수 있음
    return PageResponsePS(
      items: list.map((e) => PlaceSummary.fromJson(e as Map<String, dynamic>)).toList(),
      page: page is int ? page : int.tryParse('$page') ?? 0,
      size: size is int ? size : int.tryParse('$size') ?? 20,
      total: total is int ? total : int.tryParse('$total') ?? 0,
      last: (last is bool) ? last : null,
    );
  }
}
