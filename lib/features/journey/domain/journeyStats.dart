// features/journey/domain/journey_stats.dart

class JourneyStats {
  final int countries;
  final int trips;
  final int milesFlown;
  final int diaryEntries;

  JourneyStats({
    required this.countries,
    required this.trips,
    required this.milesFlown,
    required this.diaryEntries,
  });

  factory JourneyStats.fromJson(Map<String, dynamic> json) {
    return JourneyStats(
      countries: json['countries'] ?? 0,
      trips: json['trips'] ?? 0,
      milesFlown: json['milesFlown'] ?? 0,
      diaryEntries: json['diaryEntries'] ?? 0,
    );
  }
}
