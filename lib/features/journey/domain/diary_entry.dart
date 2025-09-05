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
    return DiaryEntry(
      scheduleId: json['scheduleId'],
      authorInitials: json['authorInitials'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      moodLabel: json['moodLabel'],
      weatherLabel: json['weatherLabel'],
      photos: List<String>.from(json['photos'] ?? []),
      body: json['body'],
    );
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
