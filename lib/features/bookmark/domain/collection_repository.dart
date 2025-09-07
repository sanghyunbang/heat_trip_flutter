class CollectionSummary {
  final int id;
  final String name;
  final int count;
  final String? latestItemContentId;
  CollectionSummary({required this.id, required this.name, required this.count, this.latestItemContentId});

  factory CollectionSummary.fromJson(Map<String, dynamic> j) => CollectionSummary(
    id: (j['id'] as num).toInt(),
    name: (j['name'] ?? '').toString(),
    count: (j['count'] as num?)?.toInt() ?? 0,
    latestItemContentId: j['latestItemContentId'] == null ? null : j['latestItemContentId'].toString(),
  );
}

abstract class CollectionRepository {
  Future<List<CollectionSummary>> list();
  Future<CollectionSummary> create(String name);
  Future<void> rename(int id, String name);
  Future<void> delete(int id);
}
