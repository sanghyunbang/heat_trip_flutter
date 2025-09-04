import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/foryou/presentation/widget/local_destination_card.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/context.dart' as dom;
import '../../domain/entities/local_destination.dart';
import '../../domain/foryou_repository.dart';

/// 카테고리 상세(/foryou/detail/:categoryId) — 해당 카테고리 아이템 목록
class CategoryDetailPage extends StatefulWidget {
  final String category; // 'cafe' | 'nature' | ...
  final dom.Context contextModel; // 동일 컨텍스트(보상/피드백 일관성)
  const CategoryDetailPage({
    super.key,
    required this.category,
    required this.contextModel,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  List<LocalDestination> items = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final repo = context.read<ForYouRepository>();
    items = await repo.getByCategory(widget.category, limit: 20);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final titleKo = _toKo(widget.category);

    return Scaffold(
      appBar: AppBar(title: Text(titleKo)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => LocalDestinationCard(d: items[i]),
            ),
    );
  }

  String _toKo(String id) => switch (id) {
    'nature' => '자연',
    'city' => '도시',
    'coastal' => '해안',
    'cultural' => '문화',
    'cafe' => '카페',
    'healing' => '힐링',
    _ => '여행지',
  };
}
