import '../models/theme_bundle_dto.dart';
import '../remote/theme_bundle_api.dart';

abstract class IThemeBundleRepository {
  Future<List<ThemeBundleDto>> list({int page, int size});
}

class ThemeBundleRepository implements IThemeBundleRepository {
  final ThemeBundleApi api;
  ThemeBundleRepository(this.api);

  @override
  Future<List<ThemeBundleDto>> list({int page = 0, int size = 20}) {
    return api.fetchBundles(page: page, size: size);
  }
}
