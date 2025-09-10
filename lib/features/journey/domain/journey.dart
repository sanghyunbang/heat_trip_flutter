class Journey {
  final int id;
  final String title;
  final String? content;
  final DateTime dateFrom;
  final DateTime dateTo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<JourneyImage> images;

  Journey({
    required this.id,
    required this.title,
    this.content,
    required this.dateFrom,
    required this.dateTo,
    required this.createdAt,
    required this.updatedAt,
    required this.images,
  });

  factory Journey.fromJson(Map<String, dynamic> json) {
    final journey = json['journey'];
    final images = (json['images'] as List<dynamic>)
        .map((e) => JourneyImage.fromJson(e))
        .toList();

    return Journey(
      id: journey['id'],
      title: journey['title'],
      content: journey['content'],
      dateFrom: DateTime.parse(journey['dateFrom']),
      dateTo: DateTime.parse(journey['dateTo']),
      createdAt: DateTime.parse(journey['createdAt']),
      updatedAt: DateTime.parse(journey['updatedAt']),
      images: images,
    );
  }
}

class JourneyImage {
  final int id;
  final String key;
  final String url;
  final String contentType;
  final int size;

  JourneyImage({
    required this.id,
    required this.key,
    required this.url,
    required this.contentType,
    required this.size,
  });

  factory JourneyImage.fromJson(Map<String, dynamic> json) {
    return JourneyImage(
      id: json['id'],
      key: json['key'],
      url: json['url'],
      contentType: json['contentType'],
      size: json['size'],
    );
  }
}
