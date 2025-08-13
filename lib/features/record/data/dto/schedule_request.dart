/// 스케쥴 작성시 서버로 전달할 요청 정보를 담는 모델 클래스
/// 이메일, 비밀번호, 닉네임, (이름, 성별) 포함

class ScheduleRequest {
  final String title;
  final String content;
  final String datefrom;
  final String dateto;

  ScheduleRequest({
    required this.title,
    required this.content,
    required this.datefrom,
    required this.dateto,
  });

  /// 서버에 보낼 JSON 형태로 변환해주는 메서드
  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'datefrom': datefrom,
    'dateto': dateto,
  };
}
