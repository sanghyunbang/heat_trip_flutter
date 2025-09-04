// lib/features/foryou/presentation/states/foryou_vm.dart
//
// ViewModel(ChangeNotifier)
// - 감정 기록(Diagnosis) 보관
// - 추천 목록 로딩 & 카테고리 선택 상태
import 'package:flutter/foundation.dart';
import '../../domain/entities/context.dart' as dom;
import '../../domain/entities/diagnosis.dart';
import '../../domain/entities/local_destination.dart';
import '../../domain/foryou_repository.dart';

class ForYouVM extends ChangeNotifier {
  final ForYouRepository repo;
  ForYouVM({required this.repo});

  Diagnosis? diagnosis; // 8 mood + energy/social
  String selectedCategoryId = 'all';
  bool loading = false;
  List<LocalDestination> items = [];

  Future<void> load(dom.Context ctx, int k) async {
    loading = true;
    notifyListeners();
    items = await repo.getTopK(ctx, k: k);
    loading = false;
    notifyListeners();
  }

  void setCategory(String id) {
    selectedCategoryId = id;
    notifyListeners();
  }

  void setDiagnosis(Diagnosis d) {
    diagnosis = d;
    notifyListeners();
  }
}
