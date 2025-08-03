// 로그인 시 서버로 전달할 요처 정보를 담는 모델 클래스
// 사용자의 이메일과 비밀번호를 포함

class LoginRequest {
  final String email; // 사용자의 이메일
  final String password; // 사용자의 비밀번호

  LoginRequest({required this.email, required this.password});

  /// 서버에서 보낼 JSON ㅎ여식으로 변환해주는 메서드
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}
