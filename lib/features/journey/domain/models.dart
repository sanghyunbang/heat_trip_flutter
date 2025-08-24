/// 도메인 모델/타입 정의: DB 스키마에 맞춘 Schedule, 다이어리, 통계
/// - 상태/표시문자열은 모델 내부에서 계산(getter)로 제공

enum ScheduleStatus { planned, inProgress, completed }

class Schedule {
  // ── DB 매핑 필드 ───────────────────────────────────────────
  final int id;                 // schedule.schedule_id (PK)
  final String title;           // schedule.title
  final String? content;        // schedule.content
  final DateTime? dateFrom;     // schedule.date_from
  final DateTime? dateTo;       // schedule.date_to
  final DateTime? createdAt;    // schedule.created_at
  final DateTime? updatedAt;    // schedule.updated_at
  final int userId;             // schedule.user_id (FK)

  // ── 화면 확장 필드(테이블에는 없음) ─────────────────────────
  final String? location;       // 예: "Kyoto, Japan"
  final List<String> tags;      // 칩 태그
  final int memoriesCount;      // 추억/사진 수
  final String? heroImageUrl;   // 카드 상단 이미지

  // ── 파생 속성: 날짜로부터 계산 ──────────────────────────────
  ScheduleStatus get status => _deriveStatus(dateFrom, dateTo, DateTime.now());
  String get dateLabel => _buildDateLabel(dateFrom, dateTo);

  const Schedule({
    required this.id,
    required this.title,
    required this.userId,
    this.content,
    this.dateFrom,
    this.dateTo,
    this.createdAt,
    this.updatedAt,
    this.location,
    this.tags = const [],
    this.memoriesCount = 0,
    this.heroImageUrl,
  });

  /// 서버 schedule JSON → 모델 (snake_case 가정)
  factory Schedule.fromScheduleJson(Map<String, dynamic> json) {
    DateTime? _parse(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());
    return Schedule(
      id: (json['schedule_id'] as num).toInt(),
      title: (json['title'] ?? '') as String,
      content: json['content'] as String?,
      dateFrom: _parse(json['date_from']),
      dateTo: _parse(json['date_to']),
      createdAt: _parse(json['created_at']),
      updatedAt: _parse(json['updated_at']),
      userId: (json['user_id'] as num).toInt(),
      // 확장 필드(있으면 사용)
      location: (json['location'] ?? json['countryOrCity']) as String?,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      memoriesCount: (json['memories_count'] as int?) ?? 0,
      heroImageUrl: json['thumbnail_url'] as String?,
    );
  }

  /// 저장/수정 payload (서버 정책에 맞게 조정)
  Map<String, dynamic> toSchedulePayload() {
    String? _dateOnly(DateTime? d) => d?.toIso8601String().split('T').first;
    return {
      'schedule_id': id,
      'title': title,
      'content': content,
      'date_from': _dateOnly(dateFrom),
      'date_to': _dateOnly(dateTo),
      'user_id': userId,
    };
  }

  // ── 상태/표시 문자열 계산 유틸 ──────────────────────────────
  static ScheduleStatus _deriveStatus(DateTime? from, DateTime? to, DateTime now) {
    if (from != null && now.isBefore(from)) return ScheduleStatus.planned;
    if (from != null && to != null && !now.isBefore(from) && !now.isAfter(to)) {
      return ScheduleStatus.inProgress;
    }
    if (to != null && now.isAfter(to)) return ScheduleStatus.completed;
    return ScheduleStatus.planned;
  }

  static String _buildDateLabel(DateTime? from, DateTime? to) {
    if (from == null && to == null) return 'Dates TBA';
    if (from != null && to == null) return _fmt(from);
    if (from == null && to != null) return _fmt(to);
    final f = from!, t = to!;
    if (f.year == t.year) {
      if (f.month == t.month) return '${_mon(f)} ${f.day} - ${t.day}';
      return '${_mon(f)} ${f.day} - ${_mon(t)} ${t.day}';
    }
    return '${_fmt(f)} - ${_fmt(t)}';
  }

  static String _fmt(DateTime d) => '${_mon(d)} ${d.day}, ${d.year}';
  static String _mon(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return m[d.month - 1];
  }
}

/// 다이어리 모델(스크린샷 UI용 확장 필드 포함)
class DiaryEntry {
  final String authorInitials;
  final String title;
  final DateTime date;
  final String location;
  final String moodLabel;
  final String weatherLabel;
  final List<String> photos;
  final String body;

  const DiaryEntry({
    required this.authorInitials,
    required this.title,
    required this.date,
    required this.location,
    required this.moodLabel,
    required this.weatherLabel,
    required this.photos,
    required this.body,
  });

  /// "Jan 21" 같은 표시용 날짜
  String get dateLabel {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[date.month - 1]} ${date.day}';
  }
}

/// 상단 통계용 모델
class JourneyStats {
  final int countries;
  final int trips;
  final int milesFlown;
  final int diaryEntries;

  const JourneyStats({
    required this.countries,
    required this.trips,
    required this.milesFlown,
    required this.diaryEntries,
  });
}
