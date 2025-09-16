import 'package:flutter/material.dart';

/// ⚠️ NOTE
/// - 이 방침은 보편적 조항을 담은 템플릿입니다. 실제 배포 전 법률 검토가 필요합니다.
/// - 아래 TODO 상수들을 실제 서비스 정보로 교체하세요.
const String kAppName = 'Heat Trip';             // TODO
const String kCompanyName = 'CetaceaLab';     // TODO
const String kContactEmail = 'privacy@example.com';  // TODO
const String kContactAddress = 'Seoul, Republic of Korea'; // TODO
const String kPrivacyVersion = 'v1.0';               // TODO
const String kEffectiveDate = '2025-09-19';          // TODO (YYYY-MM-DD)
const String kLastUpdated = '2025-09-19';            // TODO (YYYY-MM-DD)
const String kDPOName = '홍길동';                      // TODO(개인정보 보호책임자)
const String kDPOEmail = 'dpo@example.com';          // TODO
const String kDefaultRetention = '회원 탈퇴 후 최대 30일'; // TODO(내부정책)

/// 간단한 불릿 텍스트 유틸
String _bul(List<String> items) => items.map((e) => '• $e').join('\n');

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      height: 1.5,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('개인정보처리방침')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$kAppName 개인정보처리방침',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('버전: $kPrivacyVersion · 시행일: $kEffectiveDate · 최종 업데이트: $kLastUpdated',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                Text(
                  '본 개인정보처리방침(이하 “본 방침”)은 $kCompanyName(이하 “회사”)가 제공하는 $kAppName(이하 “서비스”)에서 '
                      '회원의 개인정보를 어떤 방식으로 수집·이용·보관·제공·파기하는지에 대해 설명합니다. 회사는 관련 법령을 준수합니다.',
                  style: bodyStyle,
                ),

                const SizedBox(height: 24),
                _Section(
                  title: '1. 수집하는 개인정보 항목',
                  body: '''
다음 항목 중 실제 서비스에 필요한 범위 내에서만 수집합니다(필수/선택 구분 운영 권장).

[회원가입/인증]
${_bul([
                    '필수: 이메일/아이디, 비밀번호(해시처리), 이름/닉네임',
                    '선택: 프로필 이미지, 연락처, 생년월일, 성별'
                  ])}

[이용 과정에서 자동 수집]
${_bul([
                    '기기정보(모델명, OS, 앱버전), 앱 이용기록, 접속 IP/로그',
                    '광고식별자(필요 시), 충돌/성능 로그(Crashlytics 등)'
                  ])}

[결제/유료 서비스 이용 시]
${_bul([
                    '결제 수단 정보(토큰 형태), 거래 내역, 환불 계좌(환불 시)',
                  ])}

[고객센터/문의]
${_bul([
                    '이메일, 문의 내용/첨부 파일, 로그 스냅샷(선택)',
                  ])}
''',
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '2. 개인정보의 이용 목적',
                  body: _bul([
                    '회원가입, 본인확인 및 계정 관리',
                    '서비스 제공, 맞춤형 기능 제공 및 품질 개선',
                    '결제/환불 및 구매 내역 관리',
                    '고객 문의 응대, 민원 처리 및 공지 전달',
                    '부정이용 방지, 보안 및 서비스 안정성 확보',
                    '법령 준수, 분쟁 대응 및 기록 보존',
                  ]),
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '3. 수집 방법',
                  body: _bul([
                    '회원가입/로그인, 프로필 설정 등 이용자가 직접 입력',
                    '앱 사용 시 자동 생성 정보 수집',
                    '고객센터/문의 처리 과정에서 수집',
                    '제휴 서비스/소셜 로그인 연동 시 동의 범위 내 수집',
                  ]),
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '4. 보관 및 파기',
                  body: '''
[일반 원칙] 서비스 목적 달성 시 지체 없이 파기하며, 내부 정책에 따라 $kDefaultRetention 후 파기할 수 있습니다.

[법령에 따른 보관(예시, 서비스에 맞게 조정 필요)]
${_bul([
                    '계약/대금결제/재화공급 관련 기록: 5년 (전자상거래법 등)',
                    '소비자 불만 또는 분쟁처리 기록: 3년 (전자상거래법 등)',
                    '표시/광고에 관한 기록: 6개월 (전자상거래법 등)',
                    '전자금융거래에 관한 기록: 5년 (전자금융거래법 등)',
                  ])}

[파기 절차/방법]
${_bul([
                    '전자파일: 복구 불가능한 기술적 방법으로 완전 삭제',
                    '인쇄물: 파쇄 또는 소각',
                  ])}
''',
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '5. 제3자 제공',
                  body:
                  '회사는 이용자 동의가 있거나 법령에 근거가 있는 경우를 제외하고 개인정보를 제3자에게 제공하지 않습니다. '
                      '제공이 필요한 경우 제공받는 자, 제공 목적, 제공 항목, 보유·이용 기간 등을 사전에 고지하고 동의를 받습니다.',
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '6. 처리의 위탁',
                  body: '''
회사는 원활한 서비스 제공을 위해 일부 업무를 외부 전문업체에 위탁할 수 있습니다. 위탁 시 개인정보보호 관련 계약 체결 및 감독을 수행합니다.

[예시 위탁처(서비스에 맞게 실제 이름/목록 기재 필요)]
${_bul([
                    '결제대행(PG): ○○페이먼츠 — 결제 처리',
                    '분석/로그: ○○Analytics, ○○Crash — 서비스 개선/오류 분석',
                    '클라우드/호스팅: ○○Cloud — 데이터 저장/운영',
                  ])}
''',
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '7. 이용자(및 법정대리인)의 권리',
                  body: _bul([
                    '개인정보 열람·정정·삭제·처리정지 요구',
                    '동의 철회 및 마케팅 수신 거부',
                    '권리 행사는 앱 설정/고객센터/이메일($kContactEmail)로 신청',
                    '만 14세 미만 아동의 경우 법정대리인이 권리 행사 가능',
                  ]),
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '8. 쿠키 및 유사기술',
                  body: _bul([
                    '맞춤 서비스 제공, 접속 빈도 파악 등을 위해 쿠키를 사용할 수 있습니다.',
                    '이용자는 브라우저/OS 설정에서 쿠키 저장 거부 또는 삭제가 가능합니다.',
                    '쿠키 거부 시 일부 서비스 이용에 제한이 있을 수 있습니다.',
                  ]),
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '9. 안전성 확보 조치',
                  body: _bul([
                    '관리적 조치: 내부 관리계획 수립, 임직원 교육, 접근 권한 최소화',
                    '기술적 조치: 암호화 저장/전송, 접근통제/로그감사, 보안패치',
                    '물리적 조치: 전산실/자료보관실 출입통제, 백업/복구 체계',
                  ]),
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '10. 아동의 개인정보',
                  body:
                  '만 14세 미만 아동의 회원가입·서비스 이용에는 법정대리인의 동의가 필요합니다. '
                      '회사는 필요한 범위에서 법정대리인의 동의 여부를 확인할 수 있습니다.',
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '11. 자동화된 의사결정/프로파일링',
                  body:
                  '회사는 원칙적으로 자동화된 의사결정에만 전적으로 의존하여 법적 효과 또는 중대한 영향을 미치는 결정을 내리지 않습니다. '
                      '향후 해당 기능 도입 시 목적·항목·거부권 등을 사전 고지합니다.',
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '12. 개인정보 보호책임자 및 연락처',
                  body: '''
개인정보 보호책임자: $kDPOName
이메일: $kDPOEmail
고객 문의: $kContactEmail
주소: $kContactAddress
''',
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '13. 본 방침의 변경',
                  body:
                  '법령 또는 서비스 변경 사항을 반영하기 위해 본 방침이 변경될 수 있으며, 중요한 변경 시 최소 7일 이전(이용자 권리에 중대한 영향이 있는 경우 30일 이전)부터 앱 내 공지사항 등을 통해 고지합니다. '
                      '시행일 및 변경 내용을 명확히 안내합니다.',
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                const SizedBox(height: 12),
                Divider(color: Theme.of(context).dividerColor),
                const SizedBox(height: 12),
                Text(
                  '※ 본 방침은 서비스 화면에 게시함으로써 효력이 발생합니다. 회사는 관련 법령을 준수하며, 이용자의 권리 보호를 위해 최선을 다합니다.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  final TextStyle? titleStyle;
  final TextStyle? bodyStyle;

  const _Section({
    required this.title,
    required this.body,
    this.titleStyle,
    this.bodyStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          const SizedBox(height: 8),
          Text(body, style: bodyStyle),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
//
// /// 개인정보처리방침 화면 (더미 텍스트)
// class PrivacyPolicyScreen extends StatelessWidget {
//   const PrivacyPolicyScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     const lorem =
//         '여기에 개인정보처리방침 전문이 들어갑니다. 예시 텍스트...\n\n1. 수집 항목\n2. 이용 목적\n3. 보관 및 파기\n...';
//     return Scaffold(
//       appBar: AppBar(title: const Text('개인정보처리방침')),
//       body: const Padding(
//         padding: EdgeInsets.all(16),
//         child: SingleChildScrollView(child: Text(lorem)),
//       ),
//     );
//   }
// }
