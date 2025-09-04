// lib/features/auth/data/dto/update_profile_request.dart
class UpdateProfileRequest {
  final String? name;
  final String? nickname;
  final String? gender;        // "FEMALE" | "MALE" | "OTHER"
  final int? age;
  final String? imageUrl;
  final String? travelType;

  UpdateProfileRequest({
    this.name,
    this.nickname,
    this.gender,
    this.age,
    this.imageUrl,
    this.travelType,
  });

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'name': name,
      'nickname': nickname,
      'gender': gender,
      'age': age,
      'imageUrl': imageUrl,
      'travelType': travelType,
    };
    m.removeWhere((key, value) => value == null);
    return m;
  }
}
