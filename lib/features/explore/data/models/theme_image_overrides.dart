// lib/features/explore/data/models/theme_image_overrides.dart
// 원하는 테마 키(id)별로 "대표/미리보기" 이미지를 고정해두는 맵입니다.
// 백엔드가 preview 이미지를 아직 안 내려줘도, 여기 값이 있으면 대체로 씁니다.
// [①]
const Map<String, List<String>> kThemeImageOverrides = {
  // 예) 이전 예시에서 쓰던 이미지들 (URL은 임시 샘플)
  'ear-piercings-men': [
    'https://images.unsplash.com/photo-1600180758890-6b94519a8baa?w=1080',
    'https://images.unsplash.com/photo-1516573982281-773c6c2f48f2?w=1080',
    'https://images.unsplash.com/photo-1616469829424-56f3334b7117?w=1080',
    'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=1080',
  ],
  'spf-beauty': [
    'https://images.unsplash.com/photo-1604908554075-0a4fcead7618?w=1080',
    'https://images.unsplash.com/photo-1598440947619-2c35fc9c1c05?w=1080',
    'https://images.unsplash.com/photo-1598440947611-19b51a78b8a1?w=1080',
    'https://images.unsplash.com/photo-1598440947608-50b6f1bb4a1e?w=1080',
  ],
  // 필요한 테마들 계속 추가…
};
