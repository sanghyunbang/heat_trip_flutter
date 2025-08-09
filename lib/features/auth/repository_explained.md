| 폴더              | 역할                           |
| --------------- | ---------------------------- |
| `data/`         | 실제 데이터 통신/처리 (API 호출 등)      |
| `domain/`       | 핵심 비즈니스 로직 계층, 인터페이스 및 모델 정의 |
| `presentation/` | UI 화면 구성                     |
| `service/`      | 인증 흐름, 로그인/로그아웃 기능 통합 관리     |


lib/
└── auth/
    ├── presentation/
    │   ├── login_screen.dart              // 자체 로그인 UI
    │   ├── register_screen.dart ✨         // 회원가입 UI
    │   ├── widgets/
    │   │   └── social_login_button.dart   // 소셜 로그인 버튼 UI
    ├── service/
    │   ├── auth_flow_manager.dart         // 로그인 여부에 따른 초기 진입 판단
    │   ├── social_login_service.dart      // 소셜 로그인 전용
    │   ├── token_storage.dart             // JWT 저장소
    │   └── auth_service.dart ✨            // 자체 로그인/회원가입 API 호출 로직
    ├── data/
    │   ├── dto/
    │   │   ├── login_request.dart ✨
    │   │   └── register_request.dart ✨
    │   └── repository/auth_repository_impl.dart ✨
    └── domain/
        └── repository/auth_repository.dart ✨

