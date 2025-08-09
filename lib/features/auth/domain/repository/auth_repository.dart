// 추상 인터페이스

abstract class AuthRepository {
  Future<bool> login(String email, String password());
  Future<void> logout();
  Future<bool> isLoggedIn();
}
