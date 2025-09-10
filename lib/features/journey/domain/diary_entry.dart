class DiaryEntry {
  final int? scheduleId;
  final String authorInitials;
  final String title;
  final DateTime date;
  final String location;
  final String moodLabel;
  final String weatherLabel;
  final List<String> photos;
  final String body;

  const DiaryEntry({
    this.scheduleId,
    required this.authorInitials,
    required this.title,
    required this.date,
    required this.location,
    required this.moodLabel,
    required this.weatherLabel,
    required this.photos,
    required this.body,
  });

  /// 표시용 날짜 ("Jan 21")
  String get dateLabel {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${m[date.month - 1]} ${date.day}';
  }

  /// JSON → DiaryEntry
  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    final journey = json['journey'] ?? {};

    return DiaryEntry(
      scheduleId: null, // 서버 응답에 없으면 null 처리
      authorInitials: _initials(journey['userNickname'] ?? ''),
      title: journey['title'] ?? '',
      date: DateTime.tryParse(journey['date'] ?? '') ?? DateTime.now(),
      location: journey['location'] ?? '',
      moodLabel: journey['moodLabel'] ?? '',
      weatherLabel: journey['weatherLabel'] ?? '',
      photos: List<String>.from(journey['photos'] ?? []),
      body: journey['body'] ?? '',
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return parts.map((p) => p.substring(0, 1).toUpperCase()).join();
  }

  /// DiaryEntry → JSON
  Map<String, dynamic> toJson() => {
    if (scheduleId != null) 'scheduleId': scheduleId,
    'authorInitials': authorInitials,
    'title': title,
    'date': date.toIso8601String(), // .split('T')[0], LocalDate 대응
    'location': location,
    'moodLabel': moodLabel,
    'weatherLabel': weatherLabel,
    'photos': photos,
    'body': body,
  };
}
