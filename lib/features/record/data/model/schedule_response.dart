// schedule_response.dart

class ScheduleResponse {
  final int scheduleId;
  final String title;
  final String? content;
  final DateTime dateFrom;
  final DateTime dateTo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;

  ScheduleResponse({
    required this.scheduleId,
    required this.title,
    required this.content,
    required this.dateFrom,
    required this.dateTo,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory ScheduleResponse.fromJson(Map<String, dynamic> json) {
    return ScheduleResponse(
      scheduleId: json['scheduleId'],
      title: json['title'],
      content: json['content'] as String?,
      dateFrom: DateTime.parse(json['dateFrom']),
      dateTo: DateTime.parse(json['dateTo']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class User {
  final int userId;
  final String? email;
  final String nickname;

  User({required this.userId, required this.email, required this.nickname});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      email: json['email'] as String?,
      nickname: json['nickname'],
    );
  }
}
