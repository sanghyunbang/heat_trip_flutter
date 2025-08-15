[0814]
1. 오늘 한 것
- cat3 별로 pad, 혼잡도, 사회성, 소음도 등 정보 생성
- 테마기반 묶음 (다만, cat3의 값과 테마 자체 features값들이 통일성 없을 지도-> llm이 만든 것 그대로 받음)
- gemini로 입력값 받는 UI 만들어 놓음

2. 내일 할 것
- 입력값 UI 구현하기
- 향후 사용자 정보 LOG 어떻게 받을지 구상
- 결과값 표출과 관련해 최적 테마 혹은 관광지 추천 알고리즘 작성(multiarmed bandit / LambdaMART / LTR ?? 등등 기법 쓰나?)
    (랭킹 알고리즘으로 테마 랭킹 상위 2-3개 추천 및 관광지 표출?)
- 알고리즘 모델링 정리 다시 해보기

3. 추가 까먹으면 안될거 같은것

- 이미지 호출 시 느림 -> CDN 쓰기



확장 포인트

상태관리 교체: CurationState를 Riverpod/Bloc으로 변경해도 프레젠테이션 위젯 수정 최소화

데이터 원천: BuiltInSubEmotionSource → 원격 API 교체, CurationRepository 구현 추가

웹 호환: Flutter Web에서 주소창 동기화/딥링크(go_router 기본 제공) 활용 가능

