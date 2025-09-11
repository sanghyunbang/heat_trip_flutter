// schedule_response.dart

import 'package:heat_trip_flutter/features/journey/domain/models.dart';

class ScheduleResponse {
  final int scheduleId;
  final String title;
  final String? content;
  final DateTime dateFrom;
  final DateTime dateTo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;
  final int journeyCount;

  ScheduleResponse({
    required this.scheduleId,
    required this.title,
    required this.content,
    required this.dateFrom,
    required this.dateTo,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.journeyCount,
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
      journeyCount: json['journeyCount'] ?? 0,
    );
  }
}

extension ScheduleResponseMapper on ScheduleResponse {
  Schedule toSchedule() {
    return Schedule(
      id: this.scheduleId,
      title: this.title,
      content: this.content,
      dateFrom: this.dateFrom,
      dateTo: this.dateTo,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      userId: this.user?.userId ?? 0,
      location: null, // API에 없으면 null or 기본값
      tags: const [], // API에 없으면 빈 리스트
      memoriesCount: this.journeyCount, // API에 없으면 0
      heroImageUrl: null, // API에 없으면 null
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
