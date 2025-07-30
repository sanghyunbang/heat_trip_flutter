import 'package:flutter/material.dart';
import 'feed_create_screen.dart';
import 'package:intl/intl.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String selectedFilter = '감정별보기';
  String? selectedSubFilter;

  final Map<String, List<String>> subFilters = {
    '감정별보기': ['신나요', '평온해요', '따뜻해요', '포근해요'],
    '지역별보기': ['제주도', '강원도', '서울', '부산'],
    '게시물보기': ['최신순', '인기순'],
    '피드만보기': ['나의 피드', '팔로우 피드'],
  };

  final List<Map<String, dynamic>> posts = [
    {
      'title': '행복한 여행!',
      'author': '홍길동',
      'mood': '😊',
      'content': '정말 즐거운 여행이었어요!',
      'location': '제주도',
      'likes': 12,
      'date': DateTime(2025, 7, 28),
      'imageUrl': 'https://cdn.pixabay.com/photo/2024/05/31/12/16/bridge-8800485_1280.jpg',
    },
    {
      'title': '조용한 휴식',
      'author': '김철수',
      'mood': '😌',
      'content': '한적한 시골에서 마음을 달래다 왔어요.',
      'location': '강원도',
      'likes': 5,
      'date': DateTime(2025, 7, 25),
      'imageUrl': 'https://cdn.pixabay.com/photo/2024/08/29/10/01/nature-9006428_1280.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 186, 215),
      appBar: AppBar(
        title: const Text('모두의 여행'),
        backgroundColor: const Color.fromARGB(255, 255, 186, 215),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeedCreateScreen()),
              );
            },
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text('피드 작성', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📌 상위 필터',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: subFilters.keys.map((filter) {
                    final isSelected = selectedFilter == filter;
                    return ChoiceChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Colors.pinkAccent,
                      backgroundColor: Colors.grey[200],
                      onSelected: (_) {
                        setState(() {
                          selectedFilter = filter;
                          selectedSubFilter = null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                if (subFilters[selectedFilter] != null) ...[
                  const Text(
                    '📂 하위 필터',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: subFilters[selectedFilter]!.map((sub) {
                      final isSelected = selectedSubFilter == sub;
                      return ChoiceChip(
                        label: Text(
                          sub,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: Colors.deepPurpleAccent,
                        backgroundColor: Colors.grey[100],
                        onSelected: (_) {
                          setState(() {
                            selectedSubFilter = sub;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          const Divider(),

          // 게시물 리스트
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];

                // 필터링 예시 (감정별보기일 때만 적용됨 — 실제 로직은 필요한 조건으로 확장 가능)
                if (selectedFilter == '감정별보기' && selectedSubFilter != null) {
                  if (!post['title'].toString().contains(selectedSubFilter!)) {
                    return const SizedBox.shrink();
                  }
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(post['author'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(formatter.format(post['date']),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${post['mood']} ${post['title']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        if (post['imageUrl'] != null &&
                            (post['imageUrl'] as String).isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              post['imageUrl'],
                              height: 240,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Container(
                            height: 240,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(child: Text('이미지 없음')),
                          ),
                        const SizedBox(height: 16),
                        Text(post['content'] ?? '',
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.favorite, color: Colors.red, size: 20),
                            const SizedBox(width: 4),
                            Text('${post['likes']}',
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
