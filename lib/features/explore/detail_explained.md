features/explore/presentation/screens/
  explore_detail_screen.dart             ← 얇은 오케스트레이터 (상태/Back/슬리버 리스트만)

features/explore/presentation/widgets_detail/
  detail_appbars.dart                    ← 로딩/에러용 AppBar + SliverAppBar
  gallery.dart                           ← 이미지 갤러리
  header_info.dart                       ← 상단 기본 정보
  contact_card.dart                      ← 연락처/위치/길찾기
  hours_card.dart                        ← 운영시간
  amenities_card.dart                    ← 편의시설
  reviews_card.dart                      ← 리뷰
  strip_html.dart                        ← 작은 유틸


[감정 탭 관련 추가]
lib/features/explore/
  data_detail/
    emotion_api.dart            // 백엔드 REST 호출
    emotion_repository.dart     // API → Domain 매핑
  domain_detail/
    emotion_models.dart         // EmotionScore, EmotionalReview, PlaceFeatures
  presentation/
    widgets_detail/
      emotion/
        emotion_tab.dart        // 감정경험 탭 (리뷰+변화도)
        features_tab.dart       // 공간특성 탭 (DB값 표시)
        feedback_tab.dart       // 나의 경험 탭 (제출)
    state/
      detail_emotion_vm.dart    // 탭 상태 + 데이터 로딩/제출
