import 'package:flutter/material.dart';

/// ⚠️ NOTE
/// - 이 약관은 보편적 조항을 담은 템플릿입니다. 실제 배포 전 법률 검토가 필요합니다.
/// - 아래 TODO 상수들을 실제 서비스 정보로 교체하세요.
const String kAppName = 'Heat Trip';          // TODO
const String kCompanyName = 'hit다Hit';  // TODO
const String kContactEmail = 'support@example.com'; // TODO
const String kContactAddress = 'Seoul, Republic of Korea'; // TODO
const String kTermsVersion = 'v1.0';              // TODO
const String kEffectiveDate = '2025-09-19';       // TODO (YYYY-MM-DD)

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      height: 1.5,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('이용약관')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text('$kAppName 이용약관', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('버전: $kTermsVersion · 시행일: $kEffectiveDate', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                Text(
                  '본 약관은 $kCompanyName(이하 “회사”)가 제공하는 $kAppName 서비스(이하 “서비스”)의 이용과 관련하여 회사와 이용자(이하 “회원”)'
                      ' 간의 권리·의무 및 책임 사항, 기타 필요한 사항을 규정합니다.',
                  style: bodyStyle,
                ),

                const SizedBox(height: 24),
                _Section(
                  title: '1. 목적',
                  body:
                  '이 약관은 회원이 회사가 제공하는 서비스를 이용함에 있어 회사와 회원의 권리, 의무 및 책임 사항, 서비스 이용 절차 및 기타 필요한 사항을 정함을 목적으로 합니다.',
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '2. 용어의 정의',
                  body: '''
① “서비스”란 $kAppName 모바일 앱 및 이에 부수된 제반 서비스를 의미합니다.
② “회원”이란 본 약관에 동의하고 서비스 이용계약을 체결하여 서비스를 이용하는 자를 말합니다.
③ “콘텐츠”란 회원이 서비스 내에서 생성·업로드·게시하는 텍스트, 이미지, 데이터 등 일체의 정보를 의미합니다.
④ 기타 본 약관에서 정하지 아니한 용어는 관계 법령 및 일반 관례에 따릅니다.
''',
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '3. 약관의 효력 및 변경',
                  body: '''
① 본 약관은 서비스 화면에 게시하거나 기타의 방법으로 공지함으로써 효력이 발생합니다.
② 회사는 관련 법령을 위반하지 않는 범위에서 약관을 변경할 수 있으며, 변경 시 적용일자 및 개정 사유를 명시하여 최소 7일 이전(회원에게 불리하거나 중대한 변경은 30일 이전)부터 공지합니다.
③ 회원이 개정 약관의 적용일까지 명시적으로 거부 의사를 표시하지 않거나 서비스를 계속 이용하는 경우 변경에 동의한 것으로 봅니다.
''',
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '4. 이용계약의 성립 및 계정 관리',
                  body: '''
① 이용계약은 회원이 본 약관에 동의하고 가입 절차를 완료함으로써 성립합니다.
② 회원은 본인 명의의 정확하고 최신의 정보로 계정을 생성·관리해야 하며, 계정의 관리 책임은 회원에게 있습니다.
③ 계정의 무단 사용, 보안 침해가 의심되는 경우 즉시 회사에 통지해야 합니다.
''',
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '5. 서비스의 제공, 변경 및 중단',
                  body: '''
① 회사는 서비스 운영상·기술상의 필요에 따라 서비스의 전부 또는 일부를 변경할 수 있습니다.
② 회사는 설비 보수·점검·교체 또는 통신 장애 등의 사유로 서비스 제공을 일시 중단할 수 있습니다. 이 경우 사전 공지를 원칙으로 하되, 불가피한 경우 사후에 공지할 수 있습니다.
''',
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '6. 유료 서비스 및 결제',
                  body: '''
① 서비스의 일부는 유료로 제공될 수 있으며, 이용 요금·결제 수단·과금 주기 등은 별도 화면 또는 결제 페이지에 고지합니다.
② 앱마켓(예: Google Play, App Store) 정책이 적용되는 경우 해당 정책이 우선 적용될 수 있습니다.
''',
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '7. 청약철회 및 환불',
                  body: '''
① 관련 법령 및 앱마켓 정책에 따라 청약철회가 제한될 수 있습니다.
② 환불 가능 여부, 기준, 절차는 결제 화면 또는 고객센터 안내에 따릅니다.
''',
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '8. 콘텐츠 및 지적재산권',
                  body: '''
① 서비스 및 그에 수반되는 소프트웨어·디자인·UI/UX 등 일체의 지식재산권은 회사 또는 정당한 권리자에게 귀속됩니다.
② 회원이 서비스에 게시한 콘텐츠의 저작권은 회원에게 있으나, 회사는 서비스 운영·개선을 위해 해당 콘텐츠를 비독점적·무상으로 이용(저장, 복제, 수정, 전송, 공개 표시 등)할 수 있는 라이선스를 가집니다(회원 탈퇴 후에도 백업·분쟁 해결·법령 준수 목적 범위 내에서는 존속).
③ 회원은 타인의 권리를 침해하지 않도록 주의해야 하며, 침해로 인한 분쟁·손해에 대한 책임은 회원 본인에게 있습니다.
''',
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '9. 회원의 의무 및 금지행위',
                  body: '''
회원은 다음 행위를 하여서는 안 됩니다.
① 법령·약관·공공질서에 위반하는 행위
② 타인의 정보 도용, 계정 거래·공유, 사칭 행위
③ 저작권·상표권 등 제3자의 권리를 침해하는 행위
④ 악성 코드 유포, 서비스 장애를 유발하는 기술적 행위(스크래핑·크롤링 포함)
⑤ 음란·폭력적·차별적·혐오 표현, 불법 정보 유통
⑥ 광고·스팸·다단계 등 영리 목적의 무단 홍보
⑦ 기타 서비스의 정상적 운영을 방해하는 행위
위반 시 회사는 사전 통지 없이 콘텐츠 삭제, 이용 제한, 계정 해지 등의 조치를 할 수 있습니다.
''',
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '10. 개인정보 보호',
                  body: '''
개인정보의 수집·이용·제공·보관 등 처리에 관한 사항은 회사의 개인정보처리방침에 따릅니다. 앱 내 “개인정보 처리방침” 화면을 확인하십시오.
''',
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '11. 서비스 보증의 부인 및 면책',
                  body: '''
① 회사는 서비스가 중단되지 않거나 오류가 없음을 보증하지 않습니다.
② 회사는 천재지변, 전쟁, 정전, 통신망 장애, 국가기관의 명령 또는 앱마켓 정책 등 불가항력으로 인한 손해에 대하여 책임을 지지 않습니다.
③ 회사는 회원 상호 간 또는 회원과 제3자 간에 발생한 분쟁에 개입하지 않으며, 그로 인한 손해에 대해 책임을 지지 않습니다.
''',
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '12. 제3자 서비스 및 링크',
                  body: '''
서비스에는 제3자가 제공하는 서비스 또는 링크가 포함될 수 있습니다. 제3자 서비스는 해당 제공자의 약관·정책이 적용되며, 회사는 이에 대해 보증하거나 책임을 부담하지 않습니다.
''',
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '13. 계약 해지(회원 탈퇴) 및 이용 제한',
                  body: '''
① 회원은 언제든지 앱 내 설정 메뉴 등을 통해 탈퇴할 수 있습니다. 탈퇴 시 법령 및 개인정보처리방침에 따라 일정 기간 데이터가 보관될 수 있습니다.
② 회원이 약관 또는 법령을 위반한 경우 회사는 사전 통지 없이 서비스 이용을 제한하거나 계약을 해지할 수 있습니다.
''',
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '14. 통지',
                  body: '''
회사는 회원이 제공한 이메일, 앱 내 알림, 팝업, 공지사항 등을 통해 통지할 수 있습니다. 회원은 연락처 정보가 정확하도록 최신 상태로 유지해야 합니다.
''',
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '15. 준거법 및 관할',
                  body: '''
본 약관은 대한민국 법령을 준거법으로 합니다. 서비스 이용과 관련하여 회사와 회원 간 분쟁이 발생한 경우 민사소송법 등 관련 법령에 따른 관할법원을 전속 관할로 합니다.
''',
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                _Section(
                  title: '16. 고객센터',
                  body: '''
회사명: $kCompanyName
이메일: $kContactEmail
주소: $kContactAddress
운영시간 및 응답 지연 등 세부 사항은 앱 내 공지사항을 참고하세요.
''',
                  titleStyle: titleStyle,
                  bodyStyle: bodyStyle,
                ),

                const SizedBox(height: 12),
                Divider(color: Theme.of(context).dividerColor),
                const SizedBox(height: 12),
                Text(
                  '※ 본 약관은 서비스 화면에 게시함으로써 효력이 발생합니다. 회사는 필요한 경우 관련 법령을 준수하여 약관을 변경할 수 있습니다.',
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
// /// 이용약관 화면 (더미 텍스트)
// class TermsScreen extends StatelessWidget {
//   const TermsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     const lorem =
//         '여기에 이용약관 전문이 들어갑니다. 예시 텍스트...\n\n1. 약관의 목적\n2. 서비스 이용\n3. 금지행위\n...';
//     return Scaffold(
//       appBar: AppBar(title: const Text('이용약관')),
//       body: const Padding(
//         padding: EdgeInsets.all(16),
//         child: SingleChildScrollView(child: Text(lorem)),
//       ),
//     );
//   }
// }
