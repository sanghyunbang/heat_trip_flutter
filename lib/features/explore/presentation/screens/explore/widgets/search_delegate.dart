// lib/features/explore/presentation/screens/explore/widgets/search_delegate.dart
//
// Flutter SearchDelegate를 분리
// - 검색어를 close(context, query)로 반환해 상위에서 처리

import 'package:flutter/material.dart';

class SearchDelegateWithReturn extends SearchDelegate<String> {
  SearchDelegateWithReturn({String? initialQuery}) {
    query = initialQuery ?? '';
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
        TextButton(onPressed: () => query = '', child: const Text('모두 지우기')),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, query),
      );

  @override
  Widget buildResults(BuildContext context) => _ResultList(query: query);

  @override
  Widget buildSuggestions(BuildContext context) => _ResultList(query: query);
}

class _ResultList extends StatelessWidget {
  final String query;
  const _ResultList({required this.query});

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      '서울',
      '부산',
      '제주',
      '강릉',
    ].where((s) => s.contains(query)).toList();

    if (suggestions.isEmpty) {
      return Center(child: Text('검색어: $query'));
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (_, i) => ListTile(
        title: Text(suggestions[i]),
        onTap: () => Navigator.of(context).pop(suggestions[i]),
      ),
    );
  }
}
