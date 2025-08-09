lib/
├─ core/                  # 공통 모듈 (전역적으로 사용)
│   ├─ constants/         # 앱 전역 상수, 색상, 스타일
│   ├─ network/           # Dio, Retrofit 설정, API base client
│   ├─ widgets/           # 공통 UI 위젯 (버튼, 로딩 인디케이터 등)
│   └─ utils/             # 헬퍼 함수, 날짜 포맷 등
│
├─ features/
│   ├─ auth/              # 인증/로그인 관련
│   │   ├─ data/          # API 통신, DTO, Repository 구현
│   │   ├─ domain/        # 엔티티, 추상 Repository, UseCase
│   │   └─ presentation/  # 로그인 화면, 상태관리, 뷰모델
│   │
│   ├─ explore/           # 관광지 탐색 기능
│   │   ├─ data/
│   │   ├─ domain/
│   │   └─ presentation/
│   │
│   ├─ curation/           # 감정 기반 정보 제공 기능
│   │   ├─ data/
│   │   ├─ domain/
│   │   └─ presentation/
│   │
│   └─ ...                # 다른 기능(record, profile 등)
│
├─ presentation/
│   └─ screens/           # 앱 전역 화면 모음 폴더
│       └─ ...            # 특정 기능(feature)에 속하지 않고 앱 전체 흐름(App Flow)에서 사용되는 화면들(예시: 인트로 화면 / 전역 네트워크 장애, 공통 에러 처리 화면 / 전역 설정 페이지 (기능별 설정이 아닌 앱 전체 설정) / 서버 점검, 강제 업데이트 안내 화면)
│
├─ app.dart               # MaterialApp, 라우트 설정
├─ di.dart                # 의존성 주입 (get_it, Riverpod 등)
└─ main.dart


[ 📣 기본 원칙 ]
 1. 화면(UI) 중심이 아니라 기능(Feature) 중심으로 폴더를 나눈다.
 2. 각 기능 폴더 안에는 presentation / domain / data 레이어를 둔다.
 3. API 호출, 상태관리, 모델 정의를 기능 폴더 내부에서 해결하도록 한다.
 4. 공통으로 쓰는 부분(예: API 클라이언트, 색상, 버튼 스타일)은 core 또는 common 디렉토리에 둔다.


[ 📣 레이어별 역할 ]
   레이어         |   역할	                                         |   예시
 presentation	 | UI, 상태관리(BLoC, Riverpod, Provider 등)           | 로그인 화면, 상태 변화
 domain	         | 비즈니스 로직, 엔티티, 추상화된 Repository, UseCase	 | LoginUseCase, User 엔티티
 data	         | API 통신, DTO, Repository 구현체                    | AuthApiService, AuthRepositoryImpl

[ 📣 실무에서 좋은 인상 주는 팁 ]
1. 폴더 네이밍: 무조건 소문자 + _(snake_case)
2. 레이어 분리: 기능별로 최소한 data / presentation은 구분
3. 공통 위젯 정리: 같은 버튼/카드 디자인이 여러 곳에서 반복되면 core/widgets에 두기
4. 네트워크 처리 일관성: Dio, Retrofit, http 중 하나를 통일하고 core/network에서 세팅
5. 상태관리 패턴 통일: Provider, Riverpod, BLoC 중 하나만 사용
