/// 회원가입 시, 서버로 전달할 요청 정보를 담는 모델 클래스
/// 이메일, 비밀번호, 닉네임, (이름, 성별) 포함

class RegisterRequest {
  final String email; // 회원가입 이메일
  final String password; // 비밀번호
  final String nickname; // 사용자 닉네임
  final String name; // 사용자 이름
  final String gender; // 사용자 성별

  RegisterRequest({
    required this.email,
    required this.password,
    required this.gender,
    required this.name,
    required this.nickname,
  });

  /// 서버에 보낼 JSON 형태로 변환해주는 메서드
  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'name': name,
    'nickname': nickname,
    'gender': gender,
  };
}
