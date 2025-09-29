// core/errors/app_exception.dart
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);
  @override
  String toString() => message;
}

/// 단순 메시지 용
class AppMessageException extends AppException {
  const AppMessageException(String message) : super(message);
}

// 상황별로 더 세분화도 가능
class AuthRequiredException extends AppException {
  const AuthRequiredException() : super('로그인이 필요합니다.');
}

class NoScheduleException extends AppException {
  const NoScheduleException() : super('스케줄이 없는 것 같아요. 스케줄을 생성해 보세요!');
}

class NetworkException extends AppException {
  const NetworkException(String message) : super(message);
}

class ServerException extends AppException {
  const ServerException(String message) : super(message);
}

class UnknownException extends AppException {
  const UnknownException() : super('알 수 없는 오류가 발생했습니다.');
}

class AppTimeoutException extends AppException {
  const AppTimeoutException() : super('네트워크 연결이 지연되고 있습니다. 잠시 후 다시 시도해주세요.');
}

class CancelException extends AppException {
  const CancelException() : super('요청이 취소되었습니다.');
}

class AppFormatException extends AppException {
  const AppFormatException() : super('데이터 형식이 올바르지 않습니다.');
}

class NotFoundException extends AppException {
  const NotFoundException() : super('요청한 리소스를 찾을 수 없습니다.');
}

class ConflictException extends AppException {
  const ConflictException() : super('데이터 충돌이 발생했습니다. 다시 시도해주세요.');
}

class BadRequestException extends AppException {
  const BadRequestException() : super('잘못된 요청입니다. 요청을 다시 확인해주세요.');
}

class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('인증되지 않은 요청입니다. 다시 로그인해주세요.');
}

class ForbiddenException extends AppException {
  const ForbiddenException() : super('접근 권한이 없습니다. 권한을 확인해주세요.');
}

class InternalServerException extends AppException {
  const InternalServerException() : super('서버 내부 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
}

class ServiceUnavailableException extends AppException {
  const ServiceUnavailableException()
    : super('서비스를 사용할 수 없습니다. 잠시 후 다시 시도해주세요.');
}

class GatewayTimeoutException extends AppException {
  const GatewayTimeoutException() : super('서버 응답이 지연되고 있습니다. 잠시 후 다시 시도해주세요.');
}

class RateLimitException extends AppException {
  const RateLimitException() : super('요청이 너무 많습니다. 잠시 후 다시 시도해주세요.');
}

class DatabaseException extends AppException {
  const DatabaseException(String message) : super(message);
}

class CacheException extends AppException {
  const CacheException(String message) : super(message);
}

class ValidationException extends AppException {
  const ValidationException(String message) : super(message);
}

class PaymentRequiredException extends AppException {
  const PaymentRequiredException() : super('결제가 필요합니다. 결제 정보를 확인해주세요.');
}

class NotImplementedException extends AppException {
  const NotImplementedException() : super('요청한 기능은 구현되지 않았습니다.');
}

class ConflictResourceException extends AppException {
  const ConflictResourceException() : super('요청한 리소스에 충돌이 발생했습니다.');
}

class PreconditionFailedException extends AppException {
  const PreconditionFailedException() : super('전제 조건이 실패했습니다. 요청을 다시 확인해주세요.');
}

// HTTP 상태코드 포함 서버 오류
class HttpFailureException extends AppException {
  final int status;
  const HttpFailureException(this.status, [String message = '서버 응답 오류'])
    : super('$message (HTTP $status)');
}
