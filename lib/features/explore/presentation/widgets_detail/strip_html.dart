/// strip_html.dart
/// - API의 overview/homepage 등에 태그가 섞여 올 경우 텍스트만 뽑을 때 사용
String stripHtml(String s) =>
    s.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll('&nbsp;', ' ').trim();
