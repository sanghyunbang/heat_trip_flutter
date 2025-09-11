// lib/features/auth/data/dto/register_request.dart
class RegisterRequest {
  final String email;
  final String password;
  final String nickname;
  final String name;
  final String gender;

  // ⬇️ 추가
  final String ageGroup;           // 'over14' | 'under14'
  final bool agreeTos;             // 필수
  final bool agreePrivacy;         // 필수
  final bool agreeMarketing;       // 선택
  final String tosVersion;         // 예: 'v1.0'
  final String privacyVersion;     // 예: 'v1.0'
  final String? marketingVersion;  // 동의했을 때만 'v1.0', 아니면 null

  RegisterRequest({
    required this.email,
    required this.password,
    required this.nickname,
    required this.name,
    required this.gender,
    required this.ageGroup,
    required this.agreeTos,
    required this.agreePrivacy,
    required this.agreeMarketing,
    required this.tosVersion,
    required this.privacyVersion,
    this.marketingVersion,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'nickname': nickname,
        'name': name,
        'gender': gender,
        'ageGroup': ageGroup,
        'agreeTos': agreeTos,
        'agreePrivacy': agreePrivacy,
        'agreeMarketing': agreeMarketing,
        'tosVersion': tosVersion,
        'privacyVersion': privacyVersion,
        'marketingVersion': marketingVersion,
      };
}
