import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/theme_bundle_dto.dart';
import '../models/theme_image_overrides.dart';

class ThemeBundleApi {
  final http.Client client;
  final Uri base; // 예: Uri.parse('https://your.api.host')
  ThemeBundleApi({required this.client, required this.base});

  /// GET /api/theme-bundles?page=&size=
  Future<List<ThemeBundleDto>> fetchBundles({
    int page = 0,
    int size = 20,
  }) async {
    final uri = base.replace(
      path: '${base.path}/api/theme-bundles',
      queryParameters: {'page': '$page', 'size': '$size'},
    );
    final resp = await client.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Theme bundles failed: ${resp.statusCode}');
    }

    final decoded = jsonDecode(utf8.decode(resp.bodyBytes));
    final List list = (decoded is List) ? decoded : (decoded['content'] ?? []);
    return list
        .map(
          (e) =>
              ThemeBundleDto.fromJson(e as Map<String, dynamic>)
              // preview가 비어 있으면 우리가 지정한 이미지로 채움. [④]
              .withPreviewOverrideIfEmpty(kThemeImageOverrides),
        )
        .toList();
  }
}
