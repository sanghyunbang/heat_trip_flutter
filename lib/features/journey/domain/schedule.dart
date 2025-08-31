// features/journey/domain/schedule.dart

class Schedule {
  final int id;
  final String title;
  final String? content;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int userId;
  final String? location;
  final List<String> tags;
  final int memoriesCount;
  final String? heroImageUrl;

  Schedule({
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

  factory Schedule.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());

    int parseInt(dynamic v) => (v is int) ? v : int.tryParse(v.toString()) ?? 0;

    return Schedule(
      id: parseInt(json['schedule_id'] ?? json['id']),
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString(),
      dateFrom: parseDate(json['date_from'] ?? json['dateFrom']),
      dateTo: parseDate(json['date_to'] ?? json['dateTo']),
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: parseDate(json['updated_at'] ?? json['updatedAt']),
      userId: parseInt(json['user_id'] ?? json['userId']),
      location:
          json['location']?.toString() ?? json['countryOrCity']?.toString(),
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      memoriesCount: parseInt(json['memories_count'] ?? json['memoriesCount']),
      heroImageUrl:
          json['thumbnail_url']?.toString() ?? json['heroImageUrl']?.toString(),
    );
  }
}
